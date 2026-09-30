"""Tests for fun_ds.features module."""

import numpy as np
import pandas as pd
import pytest

from fun_ds.features import (
    FE_STEPS,
    GEO_CITIES,
    SKEWED_COLUMNS,
    GeoFeatures,
    GridCell,
    build_fe_pipeline,
    cumulative_steps,
    cv_rmse,
)


@pytest.fixture
def housing_like() -> tuple[pd.DataFrame, pd.Series]:
    """Small synthetic frame with the California Housing columns."""
    rng = np.random.default_rng(0)
    n = 300
    X = pd.DataFrame(
        {
            "MedInc": rng.lognormal(1.2, 0.4, n),
            "HouseAge": rng.integers(1, 52, n).astype(float),
            "AveRooms": rng.lognormal(1.6, 0.3, n),
            "AveBedrms": rng.lognormal(0.05, 0.1, n),
            "Population": rng.lognormal(7.0, 0.7, n),
            "AveOccup": rng.lognormal(1.0, 0.3, n),
            "Latitude": rng.uniform(32.5, 42.0, n),
            "Longitude": rng.uniform(-124.3, -114.3, n),
        }
    )
    y = pd.Series(0.4 * X["MedInc"] + rng.normal(0, 0.3, n), name="MedHouseVal")
    return X, y


def _width(pipe, X, y) -> int:
    return pipe.named_steps["features"].fit_transform(X, y).shape[1]


def test_raw_pipeline_keeps_eight_columns(housing_like):
    X, y = housing_like
    assert _width(build_fe_pipeline(), X, y) == 8


@pytest.mark.parametrize(
    ("switches", "extra"),
    [
        ({"ratios": True}, 2),
        ({"city_distances": True}, len(GEO_CITIES) + 1),
        ({"rotations": True}, 8),
        ({"n_clusters": 5}, 5),
        ({"area_encoding": True}, 1),
        ({"log_skewed": True, "clip_outliers": True}, 0),
    ],
)
def test_switches_change_width_as_expected(housing_like, switches, extra):
    X, y = housing_like
    assert _width(build_fe_pipeline(**switches), X, y) == 8 + extra


def test_splines_expand_columns(housing_like):
    X, y = housing_like
    assert _width(build_fe_pipeline(splines=True), X, y) > 8


@pytest.mark.parametrize("model", ["ridge", "hgb"])
def test_full_recipe_fits_and_predicts(housing_like, model):
    X, y = housing_like
    config = cumulative_steps()[-1][1]
    pipe = build_fe_pipeline(model, n_clusters=4, clip_outliers=True, **config)
    pred = pipe.fit(X, y).predict(X)
    assert pred.shape == (len(X),)
    assert np.isfinite(pred).all()
    assert np.isfinite(pipe.named_steps["features"].transform(X)).all()


def test_unknown_model_raises():
    with pytest.raises(ValueError, match="ridge"):
        build_fe_pipeline("lasso")  # type: ignore[arg-type]


def test_geo_features_deterministic(housing_like):
    X, _ = housing_like
    coords = X[["Latitude", "Longitude"]]
    a = GeoFeatures(rotations=(30.0,), n_clusters=4).fit_transform(coords)
    b = GeoFeatures(rotations=(30.0,), n_clusters=4).fit_transform(coords)
    np.testing.assert_array_equal(a, b)


def test_rotation_preserves_distance_from_origin():
    coords = np.array([[37.0, -122.0], [34.0, -118.0]])
    rotated = GeoFeatures(city_distances=False, rotations=(45.0,)).fit_transform(coords)
    np.testing.assert_allclose(
        np.hypot(rotated[:, 0], rotated[:, 1]), np.hypot(coords[:, 0], coords[:, 1])
    )


def test_grid_cell_labels():
    cells = GridCell(resolution=0.5).fit_transform(np.array([[37.74, -122.41]]))
    assert cells[0, 0] == "75_-245"


def test_cumulative_steps_accumulate():
    steps = cumulative_steps()
    assert [label for label, _ in steps] == [label for label, _ in FE_STEPS]
    assert steps[0][1] == {}
    for (_, before), (_, after) in zip(steps, steps[1:], strict=False):
        assert set(before) <= set(after)


def test_cv_rmse_returns_one_score_per_fold(housing_like):
    X, y = housing_like
    scores = cv_rmse(build_fe_pipeline(), X, y)
    assert scores.shape == (5,)
    assert (scores > 0).all()


def test_feature_names_follow_switches(housing_like):
    X, y = housing_like
    pipe = build_fe_pipeline(
        ratios=True,
        city_distances=True,
        rotations=True,
        n_clusters=3,
        area_encoding=True,
        log_skewed=True,
        clip_outliers=True,
    ).fit(X, y)
    names = list(pipe[:-1].get_feature_names_out())
    assert len(names) == pipe.named_steps["features"].transform(X).shape[1]
    assert names[:4] == [f"counts__{c}" for c in SKEWED_COLUMNS]
    assert "ratios__rooms_per_person" in names
    assert "geo__log_dist_nearest" in names
    assert "geo__rot45_y" in names
    assert "geo__region_2" in names
    assert names[-1] == "area__grid_cell"


def test_geo_feature_names_match_width(housing_like):
    X, _ = housing_like
    geo = GeoFeatures(rotations=(15.0, 30.0), n_clusters=2)
    out = geo.fit_transform(X[["Latitude", "Longitude"]])
    assert len(geo.get_feature_names_out()) == out.shape[1]
