"""Regression evaluation metrics."""
import numpy as np
import pandas as pd
from numpy.typing import ArrayLike


def regression_report(
    y_true: ArrayLike,
    y_pred: ArrayLike,
    *,
    n_features: int | None = None,
) -> pd.DataFrame:
    """Return a one-row DataFrame with standard regression metrics.

    Parameters
    ----------
    y_true : array-like
    y_pred : array-like
    n_features : int, optional
        Required to compute adjusted R². Omit for R² only.

    Returns
    -------
    pd.DataFrame
        Columns: rmse, mae, mape, r2, adjusted_r2 (if n_features given).

    Notes
    -----
    MAPE is set to NaN when any y_true == 0 (undefined).
    """
    yt = np.asarray(y_true, dtype=float)
    yp = np.asarray(y_pred, dtype=float)
    residuals = yt - yp
    n = len(yt)

    ss_res = np.sum(residuals**2)
    ss_tot = np.sum((yt - yt.mean()) ** 2)
    r2 = 1.0 - ss_res / ss_tot if ss_tot > 0 else float("nan")

    row: dict = {
        "rmse": float(np.sqrt(np.mean(residuals**2))),
        "mae": float(np.mean(np.abs(residuals))),
        "mape": float(np.mean(np.abs(residuals / yt))) if np.all(yt != 0) else float("nan"),
        "r2": r2,
    }

    if n_features is not None:
        # Adjusted R² = 1 - (1 - R²)(n - 1) / (n - p - 1)
        denom = n - n_features - 1
        row["adjusted_r2"] = (
            1.0 - (1.0 - r2) * (n - 1) / denom if denom > 0 else float("nan")
        )

    return pd.DataFrame([row])
