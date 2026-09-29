"""Tests for fun_ds.interpretation module."""

import numpy as np
import pandas as pd
import pytest
from sklearn.linear_model import LinearRegression

from fun_ds.interpretation import ale_1d, ice_matrix, partial_dependence_1d


@pytest.fixture
def linear_model(sample_df):
    X = sample_df[["feature_a", "feature_b"]]
    # Exact linear target: y = 3 * a - 2 * b + 1
    y = 3 * X["feature_a"] - 2 * X["feature_b"] + 1
    return LinearRegression().fit(X, y), X


def test_ice_matrix_shape_and_values(linear_model):
    model, X = linear_model
    grid = np.array([0.0, 1.0, 2.0])
    ice = ice_matrix(model, X.iloc[:5], "feature_a", grid)
    assert ice.shape == (5, 3)
    # For a linear model every ICE curve has slope equal to the coefficient
    np.testing.assert_allclose(np.diff(ice, axis=1), 3.0, rtol=1e-8)


def test_partial_dependence_is_mean_ice(linear_model):
    model, X = linear_model
    grid, pdp = partial_dependence_1d(model, X, "feature_b", grid_resolution=7)
    assert grid.shape == pdp.shape == (7,)
    np.testing.assert_allclose(pdp, ice_matrix(model, X, "feature_b", grid).mean(0))


def test_ale_recovers_linear_slope_and_is_centred(linear_model):
    model, X = linear_model
    edges, ale = ale_1d(model, X, "feature_a", bins=10)
    assert edges.shape == ale.shape
    np.testing.assert_allclose(np.diff(ale) / np.diff(edges), 3.0, rtol=1e-8)
    # Centred: the count-weighted mean over bins is zero
    x = X["feature_a"].to_numpy()
    counts = np.histogram(x, bins=edges)[0]
    bin_means = 0.5 * (ale[:-1] + ale[1:])
    assert abs(np.average(bin_means, weights=counts)) < 1e-10


def test_ale_rejects_constant_feature(linear_model):
    model, X = linear_model
    X_const = X.assign(feature_a=1.0)
    with pytest.raises(ValueError, match="unique values"):
        ale_1d(model, X_const, "feature_a")


class _ProductModel:
    """Toy model f(x1, x2) = x1 * x2 (no fitting needed)."""

    def predict(self, df):
        return (df["x1"] * df["x2"]).to_numpy()


def test_ale_stays_on_data_under_correlation():
    # With x2 ~ x1, the local slope of x1 * x2 in x1 is x2 ~ x1, so ALE is
    # convex. PDP averages over *all* x2 at every x1 and is a straight line.
    rng = np.random.default_rng(0)
    x1 = rng.uniform(0, 1, 2000)
    X = pd.DataFrame({"x1": x1, "x2": x1 + rng.normal(0, 0.05, 2000)})
    model = _ProductModel()

    edges, ale = ale_1d(model, X, "x1", bins=20)
    ale_slopes = np.diff(ale) / np.diff(edges)
    assert ale_slopes[-1] > ale_slopes[0] + 0.5

    grid, pdp = partial_dependence_1d(model, X, "x1", grid_resolution=20)
    pdp_slopes = np.diff(pdp) / np.diff(grid)
    np.testing.assert_allclose(pdp_slopes, X["x2"].mean(), rtol=1e-8)
