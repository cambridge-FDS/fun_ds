"""Feature-engineering playground for Lecture 5 (D100).

Launch with ``pixi run fe-app``. Students switch feature-engineering steps on
and off for a Ridge regression and see which columns the model receives, what
each transformation does to the data, and how the cross-validated RMSE moves.
The test set is rationed to three submissions per session.
"""

from __future__ import annotations

from typing import Any

import altair as alt
import numpy as np
import pandas as pd
import streamlit as st
from sklearn.base import clone
from sklearn.metrics import root_mean_squared_error
from sklearn.model_selection import KFold, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import SplineTransformer
from threadpoolctl import threadpool_limits

from fun_ds.data import load_california_housing
from fun_ds.features import GEO_CITIES, GeoFeatures, GridCell, build_fe_pipeline
from fun_ds.transforms import OutlierClipper, TargetEncoder

MAX_SUBMISSIONS = 3
CV = KFold(n_splits=5, shuffle=True, random_state=0)
BLUE, GREY, INK = "#2a78d6", "#898781", "#52514e"
SEQUENTIAL = ["#cde2fb", "#0d366b"]  # one hue, light -> dark
DIVERGING = ["#e34948", "#f0efec", "#2a78d6"]

RAW_COLUMNS = {
    "MedInc": "Median household income in the district ($10k)",
    "HouseAge": "Median age of the houses (years, capped at 52)",
    "AveRooms": "Average rooms per household",
    "AveBedrms": "Average bedrooms per household",
    "Population": "People living in the district",
    "AveOccup": "Average people per household",
    "Latitude": "District centre, degrees north",
    "Longitude": "District centre, degrees east (negative = west)",
}
SKEWED = ["AveRooms", "AveBedrms", "Population", "AveOccup"]

# One entry per switch: what it does to which columns, and why it can help Ridge.
STEPS: dict[str, dict[str, str]] = {
    "log_skewed": {
        "label": "log(1 + x) of skewed counts",
        "inputs": "AveRooms, AveBedrms, Population, AveOccup (and the ratios)",
        "what": "Replaces each value x by log(1 + x). Same number of columns.",
        "why": "A few huge districts dominate a linear fit; the log compresses "
        "the long right tail so that a 10% change counts the same everywhere.",
    },
    "clip_outliers": {
        "label": "Winsorise skewed counts (1% / 99%)",
        "inputs": "AveRooms, AveBedrms, Population, AveOccup",
        "what": "Caps each column at its 1st and 99th training percentile. "
        "Same number of columns.",
        "why": "Stops a handful of extreme values (e.g. AveOccup > 1000) from "
        "tilting the whole regression line.",
    },
    "ratios": {
        "label": "Ratios: rooms/person, bedrooms/room",
        "inputs": "AveRooms, AveBedrms, AveOccup",
        "what": "Adds rooms_per_person = AveRooms / AveOccup and "
        "bedrooms_per_room = AveBedrms / AveRooms. +2 columns.",
        "why": "A linear model can add and scale columns but not divide them. "
        "Crowding and housing quality are ratios.",
    },
    "splines": {
        "label": "Splines for MedInc and HouseAge",
        "inputs": "MedInc, HouseAge",
        "what": "Replaces each column by a set of smooth bump functions "
        "(a B-spline basis). Each column becomes n_knots + 2 columns.",
        "why": "Ridge fits one weight per bump, so the effect of income can bend "
        "instead of being a straight line.",
    },
    "geo_splines": {
        "label": "Splines for Latitude and Longitude",
        "inputs": "Latitude, Longitude",
        "what": "Replaces each coordinate by a 10-knot B-spline basis. "
        "2 columns become 24.",
        "why": "Prices do not rise steadily from south to north; splines let "
        "Ridge learn a wiggly north–south and east–west profile.",
    },
    "city_distances": {
        "label": "Distances to SF, LA, San Diego, Sacramento",
        "inputs": "Latitude, Longitude",
        "what": "Adds log-distance to each of the four cities and to the "
        "nearest one. +5 columns.",
        "why": "'Close to a big city' is a single number for a linear model, "
        "but a curved region in latitude/longitude.",
    },
    "n_clusters": {
        "label": "KMeans regions",
        "inputs": "Latitude, Longitude",
        "what": "Groups districts into k regions by location (centroids learned "
        "on the training folds) and one-hot encodes the region. +k columns.",
        "why": "Each region gets its own intercept: a coarse 'neighbourhood' effect.",
    },
    "area_encoding": {
        "label": "Target-encoded grid cell",
        "inputs": "Latitude, Longitude",
        "what": "Assigns each district to a lat/lon grid cell and replaces the "
        "cell by the (smoothed) average house value of the *other* districts in "
        "it, computed with 5-fold cross-fitting. +1 column.",
        "why": "A very fine neighbourhood effect in a single column. Cross-fitting "
        "keeps a district's own price out of its encoding (no leakage).",
    },
}

st.set_page_config(page_title="D100 · Feature-engineering playground", layout="wide")


# --------------------------------------------------------------------------- data
@st.cache_data
def load_split() -> tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series]:
    """Load the data with the Lecture 5 80/20 split, so numbers are comparable."""
    df = load_california_housing()
    X, y = df.drop(columns="MedHouseVal"), df["MedHouseVal"]
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=0
    )
    return X_train, X_test, y_train, y_test


def make_pipeline(config: tuple) -> Pipeline:
    """Build the Ridge pipeline for a (hashable) config."""
    return build_fe_pipeline("ridge", **dict(config))


@st.cache_data(show_spinner="Cross-validating …")
def evaluate(config: tuple) -> tuple[np.ndarray, np.ndarray]:
    """Return per-fold RMSE and out-of-fold predictions on the training set."""
    X_train, _, y_train, _ = load_split()
    pipe = make_pipeline(config)
    fold_rmse, oof = [], np.empty(len(y_train))
    with threadpool_limits(limits=1):
        for train_idx, val_idx in CV.split(X_train):
            fitted = clone(pipe).fit(X_train.iloc[train_idx], y_train.iloc[train_idx])
            oof[val_idx] = fitted.predict(X_train.iloc[val_idx])
            fold_rmse.append(
                root_mean_squared_error(y_train.iloc[val_idx], oof[val_idx])
            )
    return np.array(fold_rmse), oof


@st.cache_resource(show_spinner=False)
def fit_full(config: tuple) -> Pipeline:
    """Fit on the whole training set (for inspection, not for scoring)."""
    X_train, _, y_train, _ = load_split()
    with threadpool_limits(limits=1):
        return make_pipeline(config).fit(X_train, y_train)


@st.cache_data(show_spinner="Scoring on the test set …")
def test_rmse(config: tuple) -> float:
    """Score the fully fitted recipe once on the held-out test set."""
    _, X_test, _, y_test = load_split()
    return float(root_mean_squared_error(y_test, fit_full(config).predict(X_test)))


def describe(config: dict) -> str:
    """Short human-readable summary of the active switches."""
    parts = [STEPS[k]["label"] for k, v in config.items() if v is True]
    if config["splines"]:
        parts.append(f"{config['n_knots']} knots")
    if config["n_clusters"]:
        parts.append(f"{config['n_clusters']} KMeans regions")
    if config["area_encoding"]:
        parts.append(f"grid {config['area_resolution']}°")
    if config["alpha"] != 1.0:
        parts.append(f"α={config['alpha']}")
    return "; ".join(parts) or "raw columns"


# ------------------------------------------------------------------------ charts
def histogram(values: pd.Series, title: str) -> alt.Chart:
    """Single-series histogram."""
    return (
        alt.Chart(pd.DataFrame({"value": values.to_numpy()}))
        .mark_bar(color=BLUE, cornerRadiusTopLeft=2, cornerRadiusTopRight=2)
        .encode(
            x=alt.X("value:Q", bin=alt.Bin(maxbins=50), title=title),
            y=alt.Y("count():Q", title="districts"),
            tooltip=[alt.Tooltip("count():Q", title="districts")],
        )
        .properties(height=220)
    )


def district_map(
    frame: pd.DataFrame, colour: str, title: str, *, diverging: bool = False
) -> alt.Chart:
    """Scatter of districts on the map, coloured by ``colour``."""
    if diverging:
        bound = float(np.nanquantile(np.abs(frame[colour]), 0.98))
        scale = alt.Scale(
            domain=[-bound, 0, bound], range=DIVERGING, interpolate="rgb", clamp=True
        )
    else:
        scale = alt.Scale(range=SEQUENTIAL, interpolate="rgb")
    return (
        alt.Chart(frame)
        .mark_circle(size=10, opacity=0.8)
        .encode(
            x=alt.X("Longitude:Q", scale=alt.Scale(zero=False)),
            y=alt.Y("Latitude:Q", scale=alt.Scale(zero=False)),
            color=alt.Color(f"{colour}:Q", title=title, scale=scale),
            tooltip=[
                alt.Tooltip("Latitude:Q", format=".2f"),
                alt.Tooltip("Longitude:Q", format=".2f"),
                alt.Tooltip(f"{colour}:Q", title=title, format=".3f"),
            ],
        )
        .properties(height=420)
    )


def city_layer() -> alt.Chart:
    """Black markers and labels for the cities in ``GEO_CITIES``."""
    cities = pd.DataFrame(
        [
            {"city": name.replace("_", " ").title(), "Latitude": lat, "Longitude": lon}
            for name, (lat, lon) in GEO_CITIES.items()
        ]
    )
    base = alt.Chart(cities).encode(x="Longitude:Q", y="Latitude:Q")
    return base.mark_point(shape="diamond", size=90, filled=True, color="#0b0b0b") + (
        base.mark_text(align="left", dx=8, fontSize=11, color="#0b0b0b").encode(
            text="city:N"
        )
    )


def reference_rows(X: pd.DataFrame, vary: list[str]) -> pd.DataFrame:
    """Copy of X with every column except ``vary`` set to its training median."""
    ref = X.copy()
    for col in ref.columns.difference(vary):
        ref[col] = X[col].median()
    return ref


def location_effect(pipe: Pipeline, X: pd.DataFrame) -> pd.DataFrame:
    """Prediction per district when only its location differs from the median."""
    ref = reference_rows(X, ["Latitude", "Longitude"])
    return pd.DataFrame(
        {
            "Latitude": X["Latitude"].to_numpy(),
            "Longitude": X["Longitude"].to_numpy(),
            "effect": pipe.predict(ref),
        }
    )


def learned_curve(
    column: str, current: Pipeline, raw: Pipeline, X: pd.DataFrame, y: pd.Series
) -> alt.Chart:
    """Ridge's learned effect of one column, current recipe vs raw, vs the data."""
    lo, hi = X[column].quantile([0.01, 0.99])
    grid = np.linspace(lo, hi, 120)
    ref = pd.DataFrame([X.median()] * len(grid), columns=X.columns)
    ref[column] = grid
    curves = pd.concat(
        [
            pd.DataFrame(
                {column: grid, "prediction": raw.predict(ref), "recipe": "raw columns"}
            ),
            pd.DataFrame(
                {
                    column: grid,
                    "prediction": current.predict(ref),
                    "recipe": "your recipe",
                }
            ),
        ]
    )
    bins = pd.qcut(X[column], 20, duplicates="drop")
    avg = (
        pd.DataFrame({column: X[column], "y": y})
        .groupby(bins, observed=True)
        .mean()
        .reset_index(drop=True)
    )
    lines = (
        alt.Chart(curves)
        .mark_line(strokeWidth=2)
        .encode(
            x=alt.X(f"{column}:Q", title=column),
            y=alt.Y("prediction:Q", title="predicted house value ($100k)"),
            color=alt.Color(
                "recipe:N",
                title=None,
                scale=alt.Scale(
                    domain=["raw columns", "your recipe"], range=[GREY, BLUE]
                ),
                legend=alt.Legend(orient="top"),
            ),
            strokeDash=alt.StrokeDash(
                "recipe:N",
                scale=alt.Scale(
                    domain=["raw columns", "your recipe"], range=[[5, 3], [1, 0]]
                ),
                legend=None,
            ),
        )
    )
    dots = (
        alt.Chart(avg)
        .mark_point(size=60, filled=True, color=INK, opacity=0.6)
        .encode(
            x=f"{column}:Q",
            y="y:Q",
            tooltip=[
                alt.Tooltip(f"{column}:Q", format=".2f"),
                alt.Tooltip("y:Q", title="average house value", format=".2f"),
            ],
        )
    )
    return (lines + dots).properties(height=320)


# ------------------------------------------------------------------------ sidebar
st.sidebar.header("Model: Ridge regression")
alpha = st.sidebar.select_slider(
    "Penalty α",
    options=[0.01, 0.1, 1.0, 10.0, 100.0],
    value=1.0,
    help="Features are standardised, then Ridge shrinks every weight towards "
    "zero. Larger α = stronger shrinkage (Lecture 7).",
)


def switch(key: str) -> bool:
    """Draw a sidebar checkbox whose tooltip explains the transformation."""
    step = STEPS[key]
    return st.sidebar.checkbox(step["label"], help=f"{step['what']}\n\n{step['why']}")


st.sidebar.header("Numerical features")
log_skewed = switch("log_skewed")
clip_outliers = switch("clip_outliers")
ratios = switch("ratios")
splines = switch("splines")
n_knots = st.sidebar.slider("Spline knots", 3, 20, 6, disabled=not splines)

st.sidebar.header("Geography")
geo_splines = switch("geo_splines")
city_distances = switch("city_distances")
n_clusters = st.sidebar.slider(
    "KMeans regions (0 = off)",
    0,
    50,
    0,
    step=5,
    help=f"{STEPS['n_clusters']['what']}\n\n{STEPS['n_clusters']['why']}",
)
area_encoding = switch("area_encoding")
area_resolution = st.sidebar.select_slider(
    "Grid-cell width (degrees)",
    options=[0.02, 0.05, 0.1, 0.2, 0.5],
    value=0.1,
    disabled=not area_encoding,
)

config: dict[str, Any] = {
    "log_skewed": log_skewed,
    "clip_outliers": clip_outliers,
    "ratios": ratios,
    "splines": splines,
    "n_knots": n_knots,
    "geo_splines": geo_splines,
    "city_distances": city_distances,
    "n_clusters": n_clusters,
    "area_encoding": area_encoding,
    "area_resolution": area_resolution,
    "alpha": alpha,
}
key = tuple(sorted(config.items()))
active = [k for k in STEPS if (config[k] > 0 if k == "n_clusters" else config[k])]

# -------------------------------------------------------------------- evaluation
X_train, _, y_train, _ = load_split()
fold_rmse, oof = evaluate(key)
baseline = float(evaluate(())[0].mean())
cv_mean, cv_sd = float(fold_rmse.mean()), float(fold_rmse.std())
pipe = fit_full(key)
raw_pipe = fit_full(())
feature_names = pipe[:-1].get_feature_names_out()

state = st.session_state
state.setdefault("history", [])
state.setdefault("submissions", [])
if not state.history or state.history[-1]["key"] != key:
    state.history.append(
        {
            "attempt": len(state.history) + 1,
            "key": key,
            "recipe": describe(config),
            "columns": len(feature_names),
            "cv_rmse": cv_mean,
        }
    )

# ------------------------------------------------------------------------- header
st.title("Feature-engineering playground")
st.caption(
    "California Housing, 80/20 split as in Lecture 5. The model is always a Ridge "
    "regression on standardised features; only the features change. Scores are "
    "5-fold cross-validated RMSE on the **training** set, in $100k. The test set "
    "stays locked until you submit."
)

best = min(h["cv_rmse"] for h in state.history)
c1, c2, c3, c4 = st.columns(4)
c1.metric(
    "CV RMSE",
    f"{cv_mean:.4f}",
    f"± {cv_sd:.4f} across folds",
    delta_color="off",
    delta_arrow="off",
)
c2.metric(
    "vs raw columns",
    f"{cv_mean - baseline:+.4f}",
    f"{(cv_mean / baseline - 1) * 100:+.1f}%",
    delta_color="inverse",
)
c3.metric("Best so far", f"{best:.4f}")
c4.metric(
    "Columns Ridge sees",
    f"{len(feature_names)}",
    "from 8 raw columns",
    delta_arrow="off",
    delta_color="off",
)

tab_sees, tab_does, tab_miss, tab_test = st.tabs(
    [
        "What the model sees",
        "What a transformation does",
        "Where it still misses",
        "Attempts and test set",
    ]
)

# ---------------------------------------------------------- tab: what it sees
with tab_sees:
    left, right = st.columns([2, 3])
    with left:
        st.subheader("Input: 8 raw columns")
        st.dataframe(
            pd.DataFrame(
                {
                    "column": list(RAW_COLUMNS),
                    "meaning": list(RAW_COLUMNS.values()),
                    "median": [X_train[c].median() for c in RAW_COLUMNS],
                    "max": [X_train[c].max() for c in RAW_COLUMNS],
                }
            ).style.format({"median": "{:.2f}", "max": "{:.1f}"}),
            hide_index=True,
        )
        st.caption(
            "One row per census district (block group). Target: MedHouseVal, "
            "the median house value in $100k (capped at 5)."
        )
    with right:
        st.subheader("Your recipe")
        if not active:
            st.info(
                "No transformations switched on: Ridge sees the 8 raw columns, "
                "standardised. Switch something on in the sidebar."
            )
        else:
            st.dataframe(
                pd.DataFrame(
                    [
                        {
                            "step": STEPS[k]["label"],
                            "applied to": STEPS[k]["inputs"],
                            "what it does": STEPS[k]["what"],
                        }
                        for k in active
                    ]
                ),
                hide_index=True,
            )

    st.subheader(f"Output: the {len(feature_names)} columns Ridge is fitted on")
    ridge = pipe.named_steps["model"][-1]
    block_labels = {
        "counts": "count columns",
        "shape": "MedInc, HouseAge",
        "coords": "Latitude, Longitude",
        "ratios": "ratios",
        "geo": "geographic features",
        "area": "grid-cell encoding",
    }
    cols = pd.DataFrame(
        {
            "block": [block_labels[n.split("__")[0]] for n in feature_names],
            "column": [n.split("__", 1)[1] for n in feature_names],
            "weight": ridge.coef_,
        }
    )
    summary = (
        cols.groupby("block", sort=False)
        .agg(columns=("column", "size"), example=("column", "first"))
        .reset_index()
    )
    s_left, s_right = st.columns([2, 3])
    s_left.dataframe(summary, hide_index=True)
    weights = (
        alt.Chart(cols.assign(abs_weight=cols["weight"].abs()))
        .mark_bar(color=BLUE, cornerRadiusEnd=2)
        .encode(
            x=alt.X("abs_weight:Q", title="|weight| on the standardised column"),
            y=alt.Y("column:N", sort=None, title=None),
            tooltip=["block", "column", alt.Tooltip("weight:Q", format="+.3f")],
        )
        .properties(height=max(180, 16 * len(cols)))
    )
    s_right.altair_chart(weights, width="stretch")
    st.caption(
        "Every output column is standardised, so the weight sizes are comparable: "
        "they show where Ridge puts its trust. Spline columns only make sense "
        "together — the 'What a transformation does' tab shows the curve they add up "
        "to. Weights come from a fit on the whole training set."
    )

# ---------------------------------------------------------- tab: what it does
with tab_does:
    choice = st.selectbox(
        "Transformation",
        list(STEPS),
        index=list(STEPS).index(active[-1]) if active else 0,
        format_func=lambda k: ("✓ " if k in active else "   ") + STEPS[k]["label"],
    )
    step = STEPS[choice]
    st.markdown(
        f"**Applied to:** {step['inputs']}  \n**What it does:** {step['what']}  \n"
        f"**Why it can help Ridge:** {step['why']}"
    )
    if choice not in active:
        st.caption(
            "Not in your recipe yet — the pictures show what it *would* do. "
            "Switch it on to see its effect on the score."
        )

    if choice in ("log_skewed", "clip_outliers"):
        column = st.radio("Column", SKEWED, horizontal=True)
        before = X_train[column]
        if choice == "log_skewed":
            after, after_title = np.log1p(before), f"log(1 + {column})"
        else:
            clipper = OutlierClipper().fit(before.to_frame())
            after = pd.Series(clipper.transform(before.to_frame()).ravel())
            after_title = f"{column}, winsorised"
            share = float((before != after.to_numpy()).mean())
            st.caption(
                f"Fences learned on the training data: "
                f"[{clipper.lower_bound_[0]:.2f}, {clipper.upper_bound_[0]:.2f}]. "
                f"{share:.1%} of districts are capped."
            )
        a, b = st.columns(2)
        a.altair_chart(histogram(before, f"{column} (raw)"), width="stretch")
        b.altair_chart(histogram(after, after_title), width="stretch")
        st.caption(
            f"Skewness: {before.skew():.1f} before, {after.skew():.1f} after "
            "(0 = symmetric)."
        )

    elif choice == "ratios":
        frame = X_train.assign(
            rooms_per_person=X_train["AveRooms"] / X_train["AveOccup"],
            bedrooms_per_room=X_train["AveBedrms"] / X_train["AveRooms"],
        )
        corr = (
            frame[
                [
                    "AveRooms",
                    "AveBedrms",
                    "AveOccup",
                    "rooms_per_person",
                    "bedrooms_per_room",
                ]
            ]
            .corrwith(y_train, method="spearman")
            .rename_axis("column")
            .reset_index(name="rho")
        )
        corr["kind"] = ["raw", "raw", "raw", "new ratio", "new ratio"]
        a, b = st.columns(2)
        a.markdown("**Rank correlation with house value**")
        a.altair_chart(
            alt.Chart(corr)
            .mark_bar(cornerRadiusEnd=2)
            .encode(
                x=alt.X("rho:Q", title="Spearman correlation"),
                y=alt.Y("column:N", sort=None, title=None),
                color=alt.Color(
                    "kind:N",
                    title=None,
                    scale=alt.Scale(domain=["raw", "new ratio"], range=[GREY, BLUE]),
                    legend=alt.Legend(orient="top"),
                ),
                tooltip=["column", alt.Tooltip("rho:Q", format="+.2f")],
            )
            .properties(height=220),
            width="stretch",
        )
        b.markdown("**Distribution of the new column**")
        b.altair_chart(
            histogram(np.log1p(frame["rooms_per_person"]), "log(1 + rooms_per_person)"),
            width="stretch",
        )
        st.caption(
            "The ratios are more strongly related to price than the columns they "
            "are built from — information a linear model cannot create by itself."
        )

    elif choice == "splines":
        column = st.radio("Column", ["MedInc", "HouseAge"], horizontal=True)
        spl = SplineTransformer(n_knots=n_knots).fit(X_train[[column]])
        lo, hi = X_train[column].min(), X_train[column].max()
        grid = np.linspace(lo, hi, 200)
        basis = spl.transform(pd.DataFrame({column: grid}))
        long = pd.DataFrame(basis, columns=[f"b{j}" for j in range(basis.shape[1])])
        long[column] = grid
        long = long.melt(id_vars=column, var_name="basis", value_name="value")
        a, b = st.columns(2)
        a.markdown(f"**The {basis.shape[1]} basis functions** ({n_knots} knots)")
        a.altair_chart(
            alt.Chart(long)
            .mark_line(strokeWidth=1.5, color=GREY)
            .encode(
                x=alt.X(f"{column}:Q"),
                y=alt.Y("value:Q", title="basis value"),
                detail="basis:N",
                tooltip=["basis:N"],
            )
            .properties(height=320),
            width="stretch",
        )
        b.markdown("**What Ridge learns from them**")
        b.altair_chart(
            learned_curve(column, pipe, raw_pipe, X_train, y_train), width="stretch"
        )
        st.caption(
            "Left: each bump is one new column. Right: Ridge's prediction as "
            f"{column} varies with every other column held at its median. The raw "
            "model can only draw a straight line; the dots are the average house "
            f"value in 20 {column} bins — the shape the data actually has."
        )

    else:  # geographic transformations
        coords = X_train[["Latitude", "Longitude"]]
        base = coords.reset_index(drop=True)
        a, b = st.columns(2)
        if choice == "geo_splines":
            spl = SplineTransformer(n_knots=10).fit(coords)
            lat_basis = spl.transform(coords)[:, :12]
            frame = base.assign(value=lat_basis[:, 5])
            a.markdown("**One of the 24 new columns** (a latitude bump)")
            a.altair_chart(district_map(frame, "value", "basis value"), width="stretch")
        elif choice == "city_distances":
            geo = GeoFeatures(city_distances=True).fit(coords)
            frame = base.assign(value=geo.transform(coords)[:, -1])
            a.markdown("**log-distance to the nearest city**")
            a.altair_chart(
                district_map(frame, "value", "log-distance") + city_layer(),
                width="stretch",
            )
        elif choice == "n_clusters":
            k = n_clusters or 20
            geo = GeoFeatures(city_distances=False, n_clusters=k).fit(coords)
            centres = pd.DataFrame(
                geo.kmeans_.cluster_centers_, columns=["Latitude", "Longitude"]
            )
            frame = base.assign(value=geo.kmeans_.labels_.astype(float))
            a.markdown(f"**{k} KMeans regions** (black: region centres)")
            a.altair_chart(
                alt.Chart(frame)
                .mark_circle(size=8, color="#c3c2b7")
                .encode(
                    x=alt.X("Longitude:Q", scale=alt.Scale(zero=False)),
                    y=alt.Y("Latitude:Q", scale=alt.Scale(zero=False)),
                )
                .properties(height=420)
                + alt.Chart(centres)
                .mark_point(shape="cross", size=80, filled=True, color="#0b0b0b")
                .encode(x="Longitude:Q", y="Latitude:Q"),
                width="stretch",
            )
        else:  # area_encoding
            cells = GridCell(area_resolution).fit_transform(coords)
            encoded = TargetEncoder().fit_transform(cells, y_train).ravel()
            frame = base.assign(value=encoded)
            n_cells = len(np.unique(cells))
            a.markdown(
                f"**The encoded column** ({n_cells:,} cells of {area_resolution}°, "
                f"median {int(np.median(np.unique(cells, return_counts=True)[1]))} "
                "districts per cell)"
            )
            a.altair_chart(
                district_map(frame, "value", "encoded value ($100k)"), width="stretch"
            )
        b.markdown("**What Ridge learns about location** (your recipe)")
        b.altair_chart(
            district_map(
                location_effect(pipe, X_train), "effect", "prediction ($100k)"
            ),
            width="stretch",
        )
        st.caption(
            "Right: Ridge's prediction for each district when only its location "
            "differs — every other column is held at its median. With the raw "
            "columns this is a flat tilted plane; geographic features let it follow "
            "the coast and the cities."
        )

# --------------------------------------------------------- tab: where it misses
with tab_miss:
    resid = pd.DataFrame(
        {
            "Longitude": X_train["Longitude"].to_numpy(),
            "Latitude": X_train["Latitude"].to_numpy(),
            "residual": y_train.to_numpy() - oof,
        }
    )
    st.altair_chart(
        district_map(
            resid, "residual", "actual − predicted", diverging=True
        ).properties(height=560),
        width="stretch",
    )
    st.caption(
        "Out-of-fold residuals: each district is predicted by a model that never "
        "saw it. Blue = model too low, red = model too high. Switch geography "
        "features on and watch the coastal clusters fade."
    )

# ------------------------------------------------------- tab: attempts and test
with tab_test:
    left, right = st.columns([3, 2])
    with left:
        st.subheader("Your attempts")
        hist = pd.DataFrame(state.history).drop(columns="key")
        st.altair_chart(
            alt.Chart(hist)
            .mark_line(
                point=alt.OverlayMarkDef(size=64, color=BLUE), strokeWidth=2, color=BLUE
            )
            .encode(
                x=alt.X("attempt:O", title="attempt", axis=alt.Axis(labelAngle=0)),
                y=alt.Y("cv_rmse:Q", title="CV RMSE", scale=alt.Scale(zero=False)),
                tooltip=[
                    "attempt",
                    "recipe",
                    "columns",
                    alt.Tooltip("cv_rmse:Q", format=".4f"),
                ],
            )
            .properties(height=260),
            width="stretch",
        )
        st.dataframe(
            hist[["attempt", "cv_rmse", "columns", "recipe"]].style.format(
                {"cv_rmse": "{:.4f}"}
            ),
            hide_index=True,
        )
        st.caption(
            "Every tweak you try is another look at the same five folds. After enough "
            "attempts the best CV score is optimistic — you have partly fitted the "
            "folds."
        )
    with right:
        st.subheader(
            f"Test set · {MAX_SUBMISSIONS - len(state.submissions)} submissions left"
        )
        already = any(s["key"] == key for s in state.submissions)
        if st.button(
            "Submit this recipe to the test set",
            disabled=len(state.submissions) >= MAX_SUBMISSIONS or already,
            type="primary",
        ):
            state.submissions.append(
                {
                    "key": key,
                    "recipe": describe(config),
                    "cv_rmse": cv_mean,
                    "test_rmse": test_rmse(key),
                }
            )
            st.rerun()
        if state.submissions:
            subs = pd.DataFrame(state.submissions).drop(columns="key")
            subs["gap (test − CV)"] = subs["test_rmse"] - subs["cv_rmse"]
            st.dataframe(subs.style.format(precision=4), hide_index=True)
        with st.expander("Why is the test set rationed?"):
            st.markdown(
                "The test set estimates performance on data the modelling process "
                "has **never influenced**. Each time you look at a test score and "
                "change your recipe in response, the test set leaks into your "
                "choices and stops being a fair estimate — the same mechanism that "
                "makes public Kaggle leaderboards drift from private ones. Choose "
                "with cross-validation; use the test set to *confirm*, not to "
                "*search*. Lecture 6 explains the cross-validation mechanics; "
                "Lecture 7 adds tuning."
            )

with st.expander("Challenge (Exercise 5.3)"):
    st.markdown(
        f"""
1. Get the CV RMSE below **0.52** (raw columns: {baseline:.3f}; the Lecture 5
   recipe reaches ≈0.53).
2. Switch on the MedInc/HouseAge splines and raise the knots from 3 to 20.
   Does the CV RMSE keep improving? Use the *What a transformation does* tab
   to explain what you see.
3. For your two most valuable switches, use the same tab to explain in one
   sentence each what they let Ridge represent that it could not before.
4. Spend at most {MAX_SUBMISSIONS} test submissions. Report the CV and test RMSE
   of your final recipe.
"""
    )
