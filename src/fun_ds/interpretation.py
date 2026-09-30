"""Model-agnostic feature-effect curves: PDP, ICE and first-order ALE.

These are small, readable reference implementations for teaching (Lecture 8).
For production work use ``sklearn.inspection.partial_dependence`` or a
dedicated package; the numbers agree for the simple cases covered here.
"""

from __future__ import annotations

from typing import Any

import numpy as np
import pandas as pd
from numpy.typing import ArrayLike


def feature_grid(
    X: pd.DataFrame, feature: str, grid_resolution: int = 50
) -> np.ndarray:
    """Return an evenly spaced grid over the observed range of ``feature``."""
    return np.linspace(X[feature].min(), X[feature].max(), grid_resolution)


def ice_matrix(
    model: Any, X_rows: pd.DataFrame, feature: str, grid: ArrayLike
) -> np.ndarray:
    """Predictions for every (row, grid value) pair.

    Each row of ``X_rows`` is copied once per grid value, with ``feature`` set
    to that value. Stacking all copies into one DataFrame means ``predict`` is
    called once, which is much faster than looping over rows and grid values.

    Parameters
    ----------
    model : fitted estimator with a ``predict`` method
    X_rows : pd.DataFrame
        The observations whose ICE curves to compute.
    feature : str
        Column to vary.
    grid : array-like of shape (n_grid,)
        Values to set ``feature`` to.

    Returns
    -------
    np.ndarray of shape (len(X_rows), n_grid)
        Row ``i`` is the ICE curve of observation ``i``.
    """
    grid_arr = np.asarray(grid)
    n, g = len(X_rows), len(grid_arr)
    stacked = X_rows.iloc[np.repeat(np.arange(n), g)].copy()
    stacked[feature] = np.tile(grid_arr, n)
    return np.asarray(model.predict(stacked)).reshape(n, g)


def partial_dependence_1d(
    model: Any, X: pd.DataFrame, feature: str, grid_resolution: int = 50
) -> tuple[np.ndarray, np.ndarray]:
    """One-dimensional partial dependence: the average ICE curve.

    Returns
    -------
    grid : np.ndarray of shape (grid_resolution,)
    pdp : np.ndarray of shape (grid_resolution,)
        Mean prediction over all rows of ``X`` at each grid value.
    """
    grid = feature_grid(X, feature, grid_resolution)
    return grid, ice_matrix(model, X, feature, grid).mean(axis=0)


def ale_1d(
    model: Any, X: pd.DataFrame, feature: str, bins: int = 20
) -> tuple[np.ndarray, np.ndarray]:
    """First-order accumulated local effects (ALE) for a numeric feature.

    1. Bin ``feature`` by quantiles (equal-frequency bins).
    2. In each bin, average ``f(z_k, x_C) - f(z_{k-1}, x_C)`` over the rows
       that fall in that bin only, so no unrealistic feature combinations are
       created.
    3. Accumulate the bin effects and centre them to mean zero over the data.

    Parameters
    ----------
    model : fitted estimator with a ``predict`` method
    X : pd.DataFrame
    feature : str
        Numeric column.
    bins : int, default 20
        Number of quantile bins (fewer if the feature has ties).

    Returns
    -------
    edges : np.ndarray of shape (K + 1,)
        Bin edges ``z_0, ..., z_K``.
    ale : np.ndarray of shape (K + 1,)
        Centred ALE value at each edge.

    Raises
    ------
    ValueError
        If the feature has too few distinct values to form two bins.
    """
    x = X[feature].to_numpy()
    edges = np.unique(np.quantile(x, np.linspace(0, 1, bins + 1)))
    if len(edges) < 3:
        raise ValueError(f"Not enough unique values to bin {feature!r} for ALE.")
    n_bins = len(edges) - 1

    deltas = np.zeros(n_bins)
    counts = np.zeros(n_bins, dtype=int)
    for k in range(n_bins):
        lo, hi = edges[k], edges[k + 1]
        mask = (x > lo) & (x <= hi) if k > 0 else (x >= lo) & (x <= hi)
        idx = np.flatnonzero(mask)
        counts[k] = len(idx)
        if counts[k] == 0:
            continue
        X_lo = X.iloc[idx].copy()
        X_hi = X.iloc[idx].copy()
        X_lo[feature] = lo
        X_hi[feature] = hi
        deltas[k] = np.mean(model.predict(X_hi) - model.predict(X_lo))

    # 0 at z_0, then the running sum of the local effects
    ale = np.concatenate([[0.0], np.cumsum(deltas)])
    # Centre: each bin's rows are approximated by the mean ALE at its two edges
    bin_means = 0.5 * (ale[:-1] + ale[1:])
    return edges, ale - np.average(bin_means, weights=counts)
