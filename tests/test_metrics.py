"""Tests for fun_ds.metrics."""

import numpy as np
import pytest
from sklearn.metrics import (
    mean_absolute_error,
    mean_absolute_percentage_error,
    r2_score,
    root_mean_squared_error,
)

from fun_ds.metrics import regression_report


def test_regression_report_matches_sklearn():
    rng = np.random.default_rng(0)
    y = rng.uniform(1, 5, size=200)
    y_pred = y + rng.normal(scale=0.3, size=200)
    row = regression_report(y, y_pred).iloc[0]
    assert row["rmse"] == pytest.approx(root_mean_squared_error(y, y_pred))
    assert row["mae"] == pytest.approx(mean_absolute_error(y, y_pred))
    assert row["mape"] == pytest.approx(mean_absolute_percentage_error(y, y_pred))
    assert row["r2"] == pytest.approx(r2_score(y, y_pred))
    assert "adjusted_r2" not in row


def test_regression_report_adjusted_r2():
    rng = np.random.default_rng(0)
    y = rng.normal(size=50)
    y_pred = y + rng.normal(scale=0.5, size=50)
    row = regression_report(y, y_pred, n_features=4).iloc[0]
    expected = 1 - (1 - row["r2"]) * (50 - 1) / (50 - 4 - 1)
    assert row["adjusted_r2"] == pytest.approx(expected)


def test_regression_report_undefined_cases_are_nan():
    row = regression_report([0.0, 1.0, 2.0], [0.0, 1.0, 2.5], n_features=5).iloc[0]
    assert np.isnan(row["mape"])  # y_true contains 0
    assert np.isnan(row["adjusted_r2"])  # n - p - 1 <= 0
    assert np.isnan(regression_report([1.0, 1.0], [1.0, 2.0]).iloc[0]["r2"])
