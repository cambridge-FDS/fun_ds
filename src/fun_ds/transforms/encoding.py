"""Categorical and cyclic feature encoders."""

from __future__ import annotations

import numpy as np
import pandas as pd
from numpy.typing import ArrayLike
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.model_selection import KFold
from sklearn.utils.validation import check_is_fitted


class CyclicalEncoder(TransformerMixin, BaseEstimator):
    """Encode a cyclic feature as a (sin, cos) pair.

    Cyclic features — hour of day, day of week, month of year — wrap
    around: hour 23 is adjacent to hour 0. A raw integer encoding breaks
    this topology. The (sin, cos) transformation maps each value to a
    point on the unit circle, preserving cyclical proximity.

    Parameters
    ----------
    period : float
        Full period of the cycle. E.g. 24 for hours, 7 for days, 12 for months.

    Examples
    --------
    >>> enc = CyclicalEncoder(period=24)
    >>> enc.fit_transform([[0], [6], [12], [18]])  # midnight, 6am, noon, 6pm
    """

    def __init__(self, period: float = 24.0) -> None:
        self.period = period

    def fit(self, X: ArrayLike, y: ArrayLike | None = None) -> CyclicalEncoder:
        """No-op."""
        return self

    def transform(self, X: ArrayLike) -> np.ndarray:
        """Return stacked (sin, cos) columns. Shape: (n_samples, 2)."""
        x = np.asarray(X, dtype=np.float64).ravel()
        theta = 2.0 * np.pi * x / self.period
        return np.column_stack([np.sin(theta), np.cos(theta)])

    def get_feature_names_out(
        self, input_features: list[str] | None = None
    ) -> list[str]:
        """Return output feature names (`<name>_sin`, `<name>_cos`)."""
        name = input_features[0] if input_features else "x"
        return [f"{name}_sin", f"{name}_cos"]


class TargetEncoder(TransformerMixin, BaseEstimator):
    """Mean target encoding with k-fold cross-fitting to prevent leakage.

    Naïve mean encoding — replacing each category with its global target
    mean — leaks the target into the features during training, inflating
    in-sample performance. This encoder uses k-fold cross-fitting:
    for each training sample, the encoding is estimated from the *other*
    k-1 folds, never from its own fold.

    At inference time (`transform`), the globally fitted encoding is used.

    Parameters
    ----------
    n_splits : int, default 5
        Number of cross-fitting folds.
    smoothing : float, default 10.0
        Shrinkage towards the global mean for low-frequency categories.
        Encoding = (n_cat * mean_cat + smoothing * mean_global) / (n_cat + smoothing)
    handle_unknown : {"global_mean", "raise"}, default "global_mean"
        How to handle categories not seen during fit.

    Attributes
    ----------
    encoding_ : dict
        Mapping from category value to smoothed mean (for inference).
    global_mean_ : float
        Global target mean (fallback for unseen categories).

    References
    ----------
    Micci-Barreca, D. (2001). A preprocessing scheme for high-cardinality
    categorical attributes in classification and prediction problems.
    ACM SIGKDD Explorations, 3(1), 27–32.
    """

    def __init__(
        self,
        n_splits: int = 5,
        smoothing: float = 10.0,
        handle_unknown: str = "global_mean",
    ) -> None:
        self.n_splits = n_splits
        self.smoothing = smoothing
        self.handle_unknown = handle_unknown

    def _smoothed_mean(
        self, series: pd.Series, target: pd.Series, global_mean: float
    ) -> dict:
        """Compute per-category smoothed means."""
        stats = target.groupby(series).agg(["mean", "count"])
        encoding = (stats["count"] * stats["mean"] + self.smoothing * global_mean) / (
            stats["count"] + self.smoothing
        )
        return encoding.to_dict()

    def fit(self, X: ArrayLike, y: ArrayLike) -> TargetEncoder:
        """Fit global encoding for use at inference time.

        Parameters
        ----------
        X : array-like of shape (n_samples,) or (n_samples, 1)
            Categorical feature.
        y : array-like of shape (n_samples,)
            Regression or binary classification target.
        """
        x_series = pd.Series(np.asarray(X).ravel())
        y_series = pd.Series(np.asarray(y, dtype=float))
        self.global_mean_ = float(y_series.mean())
        self.encoding_ = self._smoothed_mean(x_series, y_series, self.global_mean_)
        return self

    def fit_transform(self, X: ArrayLike, y: ArrayLike | None = None) -> np.ndarray:
        """Fit and return cross-fitted encodings to avoid target leakage.

        Each sample is encoded using statistics from the k-1 folds that
        *exclude* that sample — preventing the target value from leaking
        into its own encoding.
        """
        if y is None:
            raise ValueError("TargetEncoder.fit_transform requires y.")
        x_arr = np.asarray(X).ravel()
        y_arr = np.asarray(y, dtype=float)
        x_series = pd.Series(x_arr)
        y_series = pd.Series(y_arr)

        self.global_mean_ = float(y_series.mean())
        out = np.full(len(x_arr), self.global_mean_)

        kf = KFold(n_splits=self.n_splits, shuffle=True, random_state=0)
        for train_idx, val_idx in kf.split(x_arr):
            fold_enc = self._smoothed_mean(
                x_series.iloc[train_idx], y_series.iloc[train_idx], self.global_mean_
            )
            for i in val_idx:
                cat = x_arr[i]
                out[i] = fold_enc.get(cat, self.global_mean_)

        # Also fit global encoding for future transform() calls
        self.encoding_ = self._smoothed_mean(x_series, y_series, self.global_mean_)
        return out.reshape(-1, 1)

    def transform(self, X: ArrayLike) -> np.ndarray:
        """Apply fitted encoding to new data."""
        check_is_fitted(self, "encoding_")
        x_arr = np.asarray(X).ravel()
        if self.handle_unknown == "raise":
            unknown = set(x_arr) - set(self.encoding_)
            if unknown:
                raise ValueError(f"Unknown categories: {unknown}")
        result = np.array(
            [self.encoding_.get(v, self.global_mean_) for v in x_arr], dtype=float
        )
        return result.reshape(-1, 1)
