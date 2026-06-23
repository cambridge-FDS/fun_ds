"""Tests for fun_ds.plotting module."""

import matplotlib
import numpy as np

matplotlib.use("Agg")

from fun_ds.plotting import plot_feature_importance, plot_residuals, set_lecture_style


def test_set_lecture_style():
    set_lecture_style()
    import matplotlib.pyplot as plt

    assert plt.rcParams["axes.grid"] is True


def test_plot_residuals():
    y_true = np.array([1, 2, 3, 4, 5])
    y_pred = np.array([1.1, 2.2, 2.8, 4.1, 4.9])
    ax = plot_residuals(y_true, y_pred)
    assert ax is not None


def test_plot_feature_importance():
    importances = np.array([0.3, 0.1, 0.5, 0.05, 0.05])
    names = ["a", "b", "c", "d", "e"]
    ax = plot_feature_importance(importances, names, top_n=3)
    assert ax is not None
