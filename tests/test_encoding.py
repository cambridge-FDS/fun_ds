"""Tests for fun_ds.transforms.encoding."""

import numpy as np
import pandas as pd
import pytest
from sklearn.compose import ColumnTransformer
from sklearn.utils.validation import check_is_fitted

from fun_ds.transforms import CyclicalEncoder, TargetEncoder


def test_cyclical_encoder_wraps_around():
    out = CyclicalEncoder(period=24).fit_transform([[0], [6], [12], [24]])
    assert out.shape == (4, 2)
    np.testing.assert_allclose(out[0], out[3], atol=1e-12)  # hour 0 == hour 24
    np.testing.assert_allclose(out[1], [1.0, 0.0], atol=1e-12)
    np.testing.assert_allclose(out[2], [0.0, -1.0], atol=1e-12)


def test_cyclical_encoder_keeps_rows_for_multi_column_input():
    X = np.array([[0.0, 6.0], [12.0, 18.0]])
    enc = CyclicalEncoder(period=24).fit(X)
    out = enc.transform(X)
    assert enc.n_features_in_ == 2
    assert out.shape == (2, 4)
    np.testing.assert_allclose(out[1], [0.0, -1.0, -1.0, 0.0], atol=1e-12)


def test_cyclical_encoder_feature_names_from_dataframe():
    df = pd.DataFrame({"hour": [0, 6], "minute_of_hour": [0, 30]})
    enc = CyclicalEncoder(period=24).fit(df)
    assert list(enc.get_feature_names_out()) == [
        "hour_sin",
        "hour_cos",
        "minute_of_hour_sin",
        "minute_of_hour_cos",
    ]


def test_cyclical_encoder_rejects_wrong_column_count():
    enc = CyclicalEncoder().fit(np.zeros((3, 1)))
    with pytest.raises(ValueError, match="columns"):
        enc.transform(np.zeros((3, 2)))


def test_cyclical_encoder_in_column_transformer():
    df = pd.DataFrame({"hour": [0, 6, 12], "month": [1, 4, 7]})
    ct = ColumnTransformer([("hour", CyclicalEncoder(period=24), ["hour"])])
    out = ct.fit_transform(df)
    assert out.shape == (3, 2)
    assert list(ct.get_feature_names_out()) == ["hour__hour_sin", "hour__hour_cos"]


def test_cyclical_encoder_transform_requires_fit():
    from sklearn.exceptions import NotFittedError

    with pytest.raises(NotFittedError):
        CyclicalEncoder().transform([[1.0]])


def test_target_encoder_cross_fitting_differs_from_global():
    rng = np.random.default_rng(0)
    x = rng.choice(list("abc"), size=200)
    y = (x == "a") * 2.0 + rng.normal(size=200)
    enc = TargetEncoder(n_splits=5, smoothing=0.0)
    cross_fitted = enc.fit_transform(x.reshape(-1, 1), y)
    global_fit = enc.transform(x.reshape(-1, 1))
    check_is_fitted(enc, "encoding_")
    assert cross_fitted.shape == global_fit.shape == (200, 1)
    assert not np.allclose(cross_fitted, global_fit)
    assert enc.encoding_["a"] > enc.encoding_["b"]


def test_target_encoder_unknown_category():
    enc = TargetEncoder().fit(np.array(["a", "b", "a"]), np.array([1.0, 0.0, 1.0]))
    np.testing.assert_allclose(enc.transform(np.array(["z"])), [[enc.global_mean_]])
    with pytest.raises(ValueError, match="Unknown"):
        TargetEncoder(handle_unknown="raise").fit(["a"], [1.0]).transform(["z"])
