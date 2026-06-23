"""Plotting utilities for consistent lecture figures."""

from typing import Any

import matplotlib.pyplot as plt
import numpy as np
from numpy.typing import ArrayLike

LECTURE_STYLE: dict[str, Any] = {
    "figure.figsize": (10, 6),
    "axes.grid": True,
    "grid.alpha": 0.3,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "font.size": 12,
    "axes.titlesize": 14,
    "axes.labelsize": 12,
}


def set_lecture_style() -> None:
    """Apply the course's standard matplotlib style."""
    plt.rcParams.update(LECTURE_STYLE)


def plot_residuals(
    y_true: ArrayLike,
    y_pred: ArrayLike,
    *,
    ax: plt.Axes | None = None,
    title: str = "Residual Plot",
) -> plt.Axes:
    """Plot residuals (y_true - y_pred) against predicted values.

    Parameters
    ----------
    y_true : array-like
        True target values.
    y_pred : array-like
        Predicted values.
    ax : matplotlib Axes, optional
        Axes to draw on. Created if None.
    title : str, default "Residual Plot"
        Plot title.

    Returns
    -------
    matplotlib.axes.Axes
    """
    y_true_arr = np.asarray(y_true)
    y_pred_arr = np.asarray(y_pred)
    residuals = y_true_arr - y_pred_arr

    if ax is None:
        _, ax = plt.subplots()

    ax.scatter(y_pred_arr, residuals, alpha=0.4, s=10)
    ax.axhline(0, color="red", linestyle="--", linewidth=1)
    ax.set_xlabel("Predicted")
    ax.set_ylabel("Residual")
    ax.set_title(title)
    return ax


def plot_feature_importance(
    importances: ArrayLike,
    feature_names: list[str],
    *,
    top_n: int = 15,
    ax: plt.Axes | None = None,
    title: str = "Feature Importance",
) -> plt.Axes:
    """Plot horizontal bar chart of feature importances.

    Parameters
    ----------
    importances : array-like
        Importance values (e.g., from model.feature_importances_).
    feature_names : list of str
        Corresponding feature names.
    top_n : int, default 15
        Number of top features to display.
    ax : matplotlib Axes, optional
        Axes to draw on. Created if None.
    title : str, default "Feature Importance"
        Plot title.

    Returns
    -------
    matplotlib.axes.Axes
    """
    importances_arr = np.asarray(importances)
    idx = np.argsort(importances_arr)[-top_n:]

    if ax is None:
        _, ax = plt.subplots()

    ax.barh(
        [feature_names[i] for i in idx],
        importances_arr[idx],
    )
    ax.set_xlabel("Importance")
    ax.set_title(title)
    return ax
