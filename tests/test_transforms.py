"""Tests for fun_ds.transforms module."""

import numpy as np
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

from fun_ds.transforms import LogTransformer, OutlierClipper


def test_log_transformer_values():
    X = np.array([[1.0], [2.0], [3.0]])
    lt = LogTransformer(offset=1.0)
    result = lt.fit_transform(X)
    expected = np.log(X + 1.0)
    np.testing.assert_array_almost_equal(result, expected)


def test_log_transformer_inverse():
    X = np.array([[1.0], [2.0], [3.0]])
    lt = LogTransformer(offset=1.0)
    transformed = lt.fit_transform(X)
    recovered = lt.inverse_transform(transformed)
    np.testing.assert_array_almost_equal(recovered, X)


def test_log_transformer_in_pipeline():
    X = np.array([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
    pipe = Pipeline([("log", LogTransformer()), ("scale", StandardScaler())])
    result = pipe.fit_transform(X)
    assert result.shape == X.shape


def test_outlier_clipper_bounds():
    rng = np.random.default_rng(0)
    X = rng.normal(0, 1, size=(1000, 1))
    clipper = OutlierClipper(lower_quantile=0.05, upper_quantile=0.95)
    clipper.fit(X)
    X_clipped = clipper.transform(X)
    assert X_clipped.min() >= clipper.lower_bound_
    assert X_clipped.max() <= clipper.upper_bound_


def test_outlier_clipper_in_pipeline():
    rng = np.random.default_rng(42)
    X = rng.normal(0, 1, size=(200, 3))
    pipe = Pipeline([("clip", OutlierClipper()), ("scale", StandardScaler())])
    result = pipe.fit_transform(X)
    assert result.shape == X.shape


def test_outlier_clipper_get_params():
    clipper = OutlierClipper(lower_quantile=0.1, upper_quantile=0.9)
    params = clipper.get_params()
    assert params["lower_quantile"] == 0.1
    assert params["upper_quantile"] == 0.9
