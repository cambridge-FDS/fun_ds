"""Fundamentals of Data Science — illustrative library.

Subpackages
-----------
data        : dataset loaders and synthetic generators
eda         : exploratory data analysis (DataProfiler)
transforms  : sklearn-compatible feature transformers and encoders
model       : model selection and OLS diagnostics
metrics     : regression and fairness evaluation metrics
monitoring  : data drift detection (PSI, feature drift report)
plotting    : consistent lecture-style matplotlib figures
"""

from importlib.metadata import PackageNotFoundError, version

try:
    __version__ = version("fun_ds")
except PackageNotFoundError:
    __version__ = "unknown"

# Flat convenience imports — one line to get the most common utilities
from fun_ds.data import load_california_housing, make_regression_dataset
from fun_ds.eda import DataProfiler
from fun_ds.metrics import (
    demographic_parity_difference,
    equalised_odds_difference,
    regression_report,
)
from fun_ds.model import OLSDiagnostics, compare_models, cross_val_summary
from fun_ds.monitoring import feature_drift_report, population_stability_index
from fun_ds.plotting import plot_feature_importance, plot_residuals, set_lecture_style
from fun_ds.transforms import (
    CyclicalEncoder,
    LogTransformer,
    OutlierClipper,
    TargetEncoder,
)

__all__ = [
    # data
    "load_california_housing",
    "make_regression_dataset",
    # eda
    "DataProfiler",
    # transforms
    "LogTransformer",
    "OutlierClipper",
    "CyclicalEncoder",
    "TargetEncoder",
    # model
    "cross_val_summary",
    "compare_models",
    "OLSDiagnostics",
    # metrics
    "regression_report",
    "demographic_parity_difference",
    "equalised_odds_difference",
    # monitoring
    "population_stability_index",
    "feature_drift_report",
    # plotting
    "set_lecture_style",
    "plot_residuals",
    "plot_feature_importance",
]
