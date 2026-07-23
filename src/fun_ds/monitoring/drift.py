"""Population Stability Index and drift detection utilities.

Implements the PSI formula taught in Lecture 9:
    PSI = Σ (p_curr - p_ref) · ln(p_curr / p_ref)

Thresholds (conventional):
    PSI < 0.10  → no significant drift
    PSI < 0.25  → moderate drift, investigate
    PSI ≥ 0.25  → severe drift, model likely needs retraining
"""

from __future__ import annotations

import numpy as np
import pandas as pd


def population_stability_index(
    reference: np.ndarray | pd.Series,
    current: np.ndarray | pd.Series,
    *,
    n_bins: int = 10,
    epsilon: float = 1e-4,
) -> float:
    """Compute the Population Stability Index between two distributions.

    Bins are determined from the reference distribution and applied to
    both, so the comparison is consistent.

    Parameters
    ----------
    reference : array-like
        Baseline distribution (e.g. training data).
    current : array-like
        Production distribution to compare against the baseline.
    n_bins : int, default 10
        Number of equal-frequency bins derived from reference.
    epsilon : float, default 1e-4
        Small constant added to bin proportions to avoid log(0).

    Returns
    -------
    float
        PSI value. Higher → more drift.
    """
    ref = np.asarray(reference, dtype=float)
    cur = np.asarray(current, dtype=float)

    # Build bins from reference quantiles (equal-frequency binning)
    quantiles = np.linspace(0, 100, n_bins + 1)
    bin_edges = np.unique(np.percentile(ref, quantiles))

    # Clip current data to reference range so edge bins absorb extremes
    ref_counts, _ = np.histogram(ref, bins=bin_edges)
    cur_clipped = np.clip(cur, bin_edges[0], bin_edges[-1])
    cur_counts, _ = np.histogram(cur_clipped, bins=bin_edges)

    p_ref = ref_counts / ref_counts.sum() + epsilon
    p_cur = cur_counts / cur_counts.sum() + epsilon

    return float(np.sum((p_cur - p_ref) * np.log(p_cur / p_ref)))


def drift_severity(psi: float) -> str:
    """Map a PSI value to a human-readable severity label.

    Parameters
    ----------
    psi : float

    Returns
    -------
    str
        "stable", "moderate", or "severe".
    """
    if psi < 0.10:
        return "stable"
    if psi < 0.25:
        return "moderate"
    return "severe"


def feature_drift_report(
    reference_df: pd.DataFrame,
    current_df: pd.DataFrame,
    *,
    n_bins: int = 10,
    epsilon: float = 1e-4,
) -> pd.DataFrame:
    """Compute PSI for every shared numeric column.

    Parameters
    ----------
    reference_df : pd.DataFrame
        Reference (baseline) dataset.
    current_df : pd.DataFrame
        Current (production) dataset.
    n_bins : int, default 10
        Bins for PSI calculation.
    epsilon : float, default 1e-4
        Smoothing constant for PSI.

    Returns
    -------
    pd.DataFrame
        Columns: feature, psi, severity.
        Sorted descending by psi.
    """
    shared = [
        c
        for c in reference_df.columns
        if c in current_df.columns and pd.api.types.is_numeric_dtype(reference_df[c])
    ]
    rows = []
    for col in shared:
        psi = population_stability_index(
            reference_df[col], current_df[col], n_bins=n_bins, epsilon=epsilon
        )
        rows.append({"feature": col, "psi": psi, "severity": drift_severity(psi)})

    return pd.DataFrame(rows).sort_values("psi", ascending=False).reset_index(drop=True)
