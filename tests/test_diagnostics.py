"""Tests for fun_ds.model.diagnostics."""

import numpy as np
from sklearn.linear_model import LinearRegression

from fun_ds.model import OLSDiagnostics


def _fit(n: int = 60, p: int = 3):
    rng = np.random.default_rng(0)
    X = rng.normal(size=(n, p))
    y = X @ np.arange(1, p + 1) + rng.normal(size=n)
    return LinearRegression().fit(X, y), X, y


def test_leverage_sums_to_number_of_parameters():
    model, X, y = _fit()
    diag = OLSDiagnostics(model, X, y)
    # tr(H) = number of columns of the design matrix, intercept included
    assert np.isclose(diag.leverage_.sum(), X.shape[1] + 1)


def test_cooks_distance_matches_leave_one_out_definition():
    model, X, y = _fit()
    diag = OLSDiagnostics(model, X, y)
    n, p = X.shape
    k = p + 1
    y_hat = model.predict(X)
    s2 = np.sum((y - y_hat) ** 2) / (n - k)

    expected = np.empty(n)
    for i in range(n):
        mask = np.arange(n) != i
        y_hat_i = LinearRegression().fit(X[mask], y[mask]).predict(X)
        expected[i] = np.sum((y_hat - y_hat_i) ** 2) / (k * s2)

    np.testing.assert_allclose(diag.cooks_distance_, expected, rtol=1e-8)


def test_influential_points_flags_planted_outlier():
    model, X, y = _fit()
    X = np.vstack([X, [[6.0, 6.0, 6.0]]])
    y = np.append(y, -50.0)
    model = LinearRegression().fit(X, y)
    diag = OLSDiagnostics(model, X, y)
    assert diag.summary().index[0] == len(y) - 1
    assert len(y) - 1 in diag.influential_points().index
