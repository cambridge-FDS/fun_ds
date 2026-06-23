"""Fundamentals of Data Science — illustrative library.

This package provides reusable utilities for the course, demonstrating
how to transition from notebook code to a modular Python package.
"""

from importlib.metadata import PackageNotFoundError, version

try:
    __version__ = version("fun_ds")
except PackageNotFoundError:
    __version__ = "unknown"

from fun_ds.data import load_california_housing
from fun_ds.evaluation import compare_models, cross_val_summary
from fun_ds.plotting import plot_feature_importance, plot_residuals, set_lecture_style
from fun_ds.transforms import LogTransformer, OutlierClipper

__all__ = [
    "load_california_housing",
    "LogTransformer",
    "OutlierClipper",
    "set_lecture_style",
    "plot_residuals",
    "plot_feature_importance",
    "cross_val_summary",
    "compare_models",
]
