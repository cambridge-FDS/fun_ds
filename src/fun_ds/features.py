"""Feature-engineering recipes for the California Housing thread.

One source of truth for the Lecture 5 scoreboard and the Streamlit
feature-engineering playground (``apps/fe_playground``): every recipe is a
single scikit-learn ``Pipeline`` built from boolean switches, so each step is
fitted inside cross-validation and can never leak test information.
"""

from __future__ import annotations

from typing import Any, Literal

import numpy as np
import pandas as pd
from numpy.typing import ArrayLike
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.cluster import KMeans
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import HistGradientBoostingRegressor
from sklearn.linear_model import Ridge
from sklearn.model_selection import KFold, cross_val_score
from sklearn.pipeline import Pipeline, make_pipeline
from sklearn.preprocessing import FunctionTransformer, SplineTransformer, StandardScaler
from threadpoolctl import threadpool_limits

from fun_ds.transforms import LogTransformer, OutlierClipper, TargetEncoder

#: (latitude, longitude) of California's largest metropolitan centres.
GEO_CITIES: dict[str, tuple[float, float]] = {
    "san_francisco": (37.77, -122.42),
    "los_angeles": (34.05, -118.24),
    "san_diego": (32.72, -117.16),
    "sacramento": (38.58, -121.49),
}

SKEWED_COLUMNS = ["AveRooms", "AveBedrms", "Population", "AveOccup"]
SHAPE_COLUMNS = ["MedInc", "HouseAge"]
COORD_COLUMNS = ["Latitude", "Longitude"]


def _ratio_features(X: pd.DataFrame) -> pd.DataFrame:
    """Rooms per person and bedrooms per room (row-wise, so leakage-free)."""
    return pd.DataFrame(
        {
            "rooms_per_person": X["AveRooms"] / X["AveOccup"],
            "bedrooms_per_room": X["AveBedrms"] / X["AveRooms"],
        },
        index=X.index,
    )


def _ratio_names(transformer: Any, input_features: Any) -> list[str]:
    """Output names of ``_ratio_features`` (for ``get_feature_names_out``)."""
    return ["rooms_per_person", "bedrooms_per_room"]


class GeoFeatures(TransformerMixin, BaseEstimator):
    """Derive geographic features from (Latitude, Longitude).

    Parameters
    ----------
    city_distances : bool, default True
        Add log-distance to each city in ``GEO_CITIES`` and to the nearest one.
    rotations : tuple of float, default ()
        Angles in degrees. Each adds two rotated coordinates. Trees split on
        one axis at a time, so rotating the map lets them draw diagonal
        boundaries (e.g. the coastline) in fewer splits.
    n_clusters : int, default 0
        If positive, one-hot encode a KMeans clustering of the coordinates.
        The centroids are learned in ``fit``, i.e. on training folds only.

    Notes
    -----
    Expects two columns in the order (Latitude, Longitude).
    """

    def __init__(
        self,
        city_distances: bool = True,
        rotations: tuple[float, ...] = (),
        n_clusters: int = 0,
    ) -> None:
        self.city_distances = city_distances
        self.rotations = rotations
        self.n_clusters = n_clusters

    def fit(self, X: ArrayLike, y: ArrayLike | None = None) -> GeoFeatures:
        """Fit the KMeans centroids (if requested)."""
        coords = np.asarray(X, dtype=np.float64)
        self.n_features_in_ = coords.shape[1]
        if self.n_clusters > 0:
            self.kmeans_ = KMeans(
                n_clusters=self.n_clusters, n_init=4, random_state=0
            ).fit(coords)
        return self

    def transform(self, X: ArrayLike) -> np.ndarray:
        """Return the stacked geographic features."""
        coords = np.asarray(X, dtype=np.float64)
        lat, lon = coords[:, 0], coords[:, 1]
        blocks: list[np.ndarray] = [np.empty((len(coords), 0))]
        if self.city_distances:
            dist = np.column_stack(
                [
                    np.hypot(lat - c_lat, lon - c_lon)
                    for c_lat, c_lon in GEO_CITIES.values()
                ]
            )
            blocks.append(np.log1p(np.column_stack([dist, dist.min(axis=1)])))
        for angle in self.rotations:
            theta = np.deg2rad(angle)
            blocks.append(
                np.column_stack(
                    [
                        lon * np.cos(theta) - lat * np.sin(theta),
                        lon * np.sin(theta) + lat * np.cos(theta),
                    ]
                )
            )
        if self.n_clusters > 0:
            labels = self.kmeans_.predict(coords)
            blocks.append(np.eye(self.n_clusters)[labels])
        return np.hstack(blocks)

    def get_feature_names_out(
        self, input_features: ArrayLike | None = None
    ) -> np.ndarray:
        """Return names in the column order produced by ``transform``."""
        names: list[str] = []
        if self.city_distances:
            names += [f"log_dist_{city}" for city in GEO_CITIES] + ["log_dist_nearest"]
        for angle in self.rotations:
            names += [f"rot{angle:g}_x", f"rot{angle:g}_y"]
        names += [f"region_{k}" for k in range(self.n_clusters)]
        return np.asarray(names, dtype=object)


class GridCell(TransformerMixin, BaseEstimator):
    """Map (Latitude, Longitude) to a grid-cell label, e.g. ``"378_-1224"``.

    A high-cardinality categorical: at ``resolution=0.1`` degrees California
    Housing has roughly 2,000 cells, many with a handful of districts. Pair it
    with target encoding rather than one-hot encoding.

    Parameters
    ----------
    resolution : float, default 0.1
        Cell width in degrees.
    """

    def __init__(self, resolution: float = 0.1) -> None:
        self.resolution = resolution

    def fit(self, X: ArrayLike, y: ArrayLike | None = None) -> GridCell:
        """No-op: the grid is fixed."""
        self.n_features_in_ = np.asarray(X).shape[1]
        return self

    def transform(self, X: ArrayLike) -> np.ndarray:
        """Return one string label per row. Shape: (n_samples, 1)."""
        cells = np.round(np.asarray(X, dtype=np.float64) / self.resolution).astype(int)
        return np.array([f"{a}_{b}" for a, b in cells], dtype=object).reshape(-1, 1)

    def get_feature_names_out(
        self, input_features: ArrayLike | None = None
    ) -> np.ndarray:
        """Return the single output name, ``grid_cell``."""
        return np.asarray(["grid_cell"], dtype=object)


def build_fe_pipeline(
    model: Literal["ridge", "hgb"] = "ridge",
    *,
    log_skewed: bool = False,
    clip_outliers: bool = False,
    ratios: bool = False,
    splines: bool = False,
    n_knots: int = 6,
    geo_splines: bool = False,
    city_distances: bool = False,
    rotations: bool = False,
    n_clusters: int = 0,
    area_encoding: bool = False,
    area_resolution: float = 0.1,
    alpha: float = 1.0,
) -> Pipeline:
    """Build a feature-engineering + model pipeline for California Housing.

    With every switch off the model sees the eight raw columns unchanged.

    Parameters
    ----------
    model : {"ridge", "hgb"}
        ``"ridge"``: standardise then Ridge. ``"hgb"``: HistGradientBoosting.
    log_skewed : bool
        ``log(1 + x)`` of the right-skewed count columns (and of the ratios).
    clip_outliers : bool
        Winsorise the skewed columns at their 1st/99th training percentiles.
    ratios : bool
        Add rooms per person and bedrooms per room.
    splines : bool
        Replace MedInc and HouseAge by a cubic B-spline basis.
    n_knots : int
        Knots for the MedInc/HouseAge splines.
    geo_splines : bool
        Replace Latitude and Longitude by B-spline bases (10 knots each).
    city_distances : bool
        Add log-distances to the major cities (see ``GeoFeatures``).
    rotations : bool
        Add coordinates rotated by 15°, 30°, 45° and 60°.
    n_clusters : int
        If positive, add a one-hot KMeans region with this many clusters.
    area_encoding : bool
        Add the cross-fitted target encoding of a lat/lon grid cell.
    area_resolution : float
        Grid-cell width in degrees for ``area_encoding``.
    alpha : float
        Ridge penalty (ignored for ``"hgb"``).

    Returns
    -------
    Pipeline
        Steps ``"features"`` (a ``ColumnTransformer``) and ``"model"``.
    """
    skew_steps: list[Any] = []
    if clip_outliers:
        skew_steps.append(OutlierClipper())
    if log_skewed:
        skew_steps.append(LogTransformer(offset=1.0))
    skew = make_pipeline(*skew_steps) if skew_steps else "passthrough"

    transformers: list[tuple[str, Any, list[str]]] = [
        ("counts", skew, SKEWED_COLUMNS),
        (
            "shape",
            SplineTransformer(n_knots=n_knots) if splines else "passthrough",
            SHAPE_COLUMNS,
        ),
        (
            "coords",
            SplineTransformer(n_knots=10) if geo_splines else "passthrough",
            COORD_COLUMNS,
        ),
    ]
    if ratios:
        ratio_steps: list[Any] = [
            FunctionTransformer(_ratio_features, feature_names_out=_ratio_names)
        ]
        if log_skewed:
            ratio_steps.append(LogTransformer(offset=1.0))
        transformers.append(
            (
                "ratios",
                make_pipeline(*ratio_steps),
                ["AveRooms", "AveBedrms", "AveOccup"],
            )
        )
    if city_distances or rotations or n_clusters > 0:
        geo = GeoFeatures(
            city_distances=city_distances,
            rotations=(15.0, 30.0, 45.0, 60.0) if rotations else (),
            n_clusters=n_clusters,
        )
        transformers.append(("geo", geo, COORD_COLUMNS))
    if area_encoding:
        area = make_pipeline(GridCell(area_resolution), TargetEncoder())
        transformers.append(("area", area, COORD_COLUMNS))

    estimator: Any
    if model == "ridge":
        estimator = make_pipeline(StandardScaler(), Ridge(alpha=alpha))
    elif model == "hgb":
        estimator = HistGradientBoostingRegressor(random_state=0)
    else:
        raise ValueError(f"model must be 'ridge' or 'hgb', got {model!r}")

    return Pipeline(
        [("features", ColumnTransformer(transformers)), ("model", estimator)]
    )


#: Cumulative recipe for the Lecture 5 scoreboard: each step keeps the
#: previous switches on and adds one idea.
FE_STEPS: list[tuple[str, dict[str, Any]]] = [
    ("raw columns", {}),
    ("+ log of skewed counts", {"log_skewed": True}),
    ("+ ratio features", {"ratios": True}),
    ("+ splines (MedInc, HouseAge)", {"splines": True}),
    (
        "+ geography (splines, city distances)",
        {"geo_splines": True, "city_distances": True},
    ),
    ("+ rotated coordinates", {"rotations": True}),
    ("+ target-encoded area", {"area_encoding": True}),
]


def cumulative_steps() -> list[tuple[str, dict[str, Any]]]:
    """Return ``FE_STEPS`` with the switches accumulated step by step."""
    out: list[tuple[str, dict[str, Any]]] = []
    config: dict[str, Any] = {}
    for label, switches in FE_STEPS:
        config = {**config, **switches}
        out.append((label, dict(config)))
    return out


def cv_rmse(
    estimator: Any,
    X: pd.DataFrame,
    y: ArrayLike,
    *,
    cv: Any = None,
) -> np.ndarray:
    """Return the per-fold cross-validated RMSE of ``estimator``.

    Defaults to ``KFold(5, shuffle=True, random_state=0)``, as in Lecture 6.
    Native thread pools are limited to one thread: on small data the
    HistGradientBoosting thread start-up otherwise dominates the runtime.
    """
    if cv is None:
        cv = KFold(n_splits=5, shuffle=True, random_state=0)
    with threadpool_limits(limits=1):
        scores = cross_val_score(
            estimator, X, y, cv=cv, scoring="neg_root_mean_squared_error"
        )
    return -scores
