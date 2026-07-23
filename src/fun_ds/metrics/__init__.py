"""Model evaluation metrics: regression and fairness."""

from fun_ds.metrics.fairness import (
    demographic_parity_difference,
    equalised_odds_difference,
)
from fun_ds.metrics.regression import regression_report

__all__ = [
    "regression_report",
    "demographic_parity_difference",
    "equalised_odds_difference",
]
