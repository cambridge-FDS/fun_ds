"""Fairness metrics for binary classification models.

Implements the metrics discussed in Lecture 8 (Interpretability & Fairness):
- Demographic parity (group-wise positive prediction rates)
- Equalised odds (group-wise TPR and FPR parity)

References
----------
Hardt, M., Price, E., & Srebro, N. (2016). Equality of opportunity in
supervised learning. NeurIPS 29. [hardt2016equality]
"""

from __future__ import annotations

import numpy as np
import pandas as pd
from numpy.typing import ArrayLike


def _binary_rates(y_true: np.ndarray, y_pred: np.ndarray) -> tuple[float, float]:
    """Return (TPR, FPR) for a single group."""
    pos = y_true == 1
    neg = y_true == 0
    tpr = float(y_pred[pos].mean()) if pos.any() else float("nan")
    fpr = float(y_pred[neg].mean()) if neg.any() else float("nan")
    return tpr, fpr


def demographic_parity_difference(
    y_pred: ArrayLike,
    sensitive_attr: ArrayLike,
) -> float:
    """Difference in positive prediction rates between the two largest groups.

    Demographic parity requires P(ŷ=1 | A=a) to be equal across groups.
    A value of 0 means perfect parity; positive means the first group
    (by label order) receives more positive predictions.

    Parameters
    ----------
    y_pred : array-like of int {0, 1}
        Binary predictions.
    sensitive_attr : array-like
        Group membership for each sample.

    Returns
    -------
    float
        P(ŷ=1 | A=group_0) - P(ŷ=1 | A=group_1).
    """
    yp = np.asarray(y_pred, dtype=int)
    sa = np.asarray(sensitive_attr)
    groups = np.unique(sa)
    if len(groups) < 2:
        raise ValueError("sensitive_attr must contain at least two distinct groups.")
    rates = {g: float(yp[sa == g].mean()) for g in groups}
    sorted_groups = sorted(rates.keys())
    return rates[sorted_groups[0]] - rates[sorted_groups[1]]


def equalised_odds_difference(
    y_true: ArrayLike,
    y_pred: ArrayLike,
    sensitive_attr: ArrayLike,
) -> float:
    """Maximum of |ΔTPR| and |ΔFPR| across the two largest groups.

    Equalised odds (Hardt et al., 2016) requires both TPR and FPR to
    be equal across groups. This scalar summary is the *worst* of the
    two gap statistics.

    Parameters
    ----------
    y_true : array-like of int {0, 1}
        Ground-truth labels.
    y_pred : array-like of int {0, 1}
        Binary predictions.
    sensitive_attr : array-like
        Group membership.

    Returns
    -------
    float
        max(|TPR_0 - TPR_1|, |FPR_0 - FPR_1|). Lower is fairer.
    """
    yt = np.asarray(y_true, dtype=int)
    yp = np.asarray(y_pred, dtype=int)
    sa = np.asarray(sensitive_attr)
    groups = sorted(np.unique(sa))
    if len(groups) < 2:
        raise ValueError("sensitive_attr must contain at least two distinct groups.")

    tpr0, fpr0 = _binary_rates(yt[sa == groups[0]], yp[sa == groups[0]])
    tpr1, fpr1 = _binary_rates(yt[sa == groups[1]], yp[sa == groups[1]])
    return float(max(abs(tpr0 - tpr1), abs(fpr0 - fpr1)))


def fairness_report(
    y_true: ArrayLike,
    y_pred: ArrayLike,
    sensitive_attr: ArrayLike,
) -> pd.DataFrame:
    """Return a DataFrame summarising fairness metrics per group.

    Parameters
    ----------
    y_true : array-like
    y_pred : array-like
    sensitive_attr : array-like

    Returns
    -------
    pd.DataFrame
        Index: group label. Columns: n, positive_rate, tpr, fpr.
    """
    yt = np.asarray(y_true, dtype=int)
    yp = np.asarray(y_pred, dtype=int)
    sa = np.asarray(sensitive_attr)

    rows = []
    for g in sorted(np.unique(sa)):
        mask = sa == g
        tpr, fpr = _binary_rates(yt[mask], yp[mask])
        rows.append(
            {
                "group": g,
                "n": int(mask.sum()),
                "positive_rate": float(yp[mask].mean()),
                "tpr": tpr,
                "fpr": fpr,
            }
        )
    return pd.DataFrame(rows).set_index("group")
