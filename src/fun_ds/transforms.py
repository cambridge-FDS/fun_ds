"""Custom scikit-learn transformers for feature engineering."""

import numpy as np
from numpy.typing import ArrayLike
from sklearn.base import BaseEstimator, TransformerMixin


class LogTransformer(TransformerMixin, BaseEstimator):
    """Apply log(x + offset) transformation.

    Parameters
    ----------
    offset : float, default 1.0
        Value added before taking the logarithm to handle zeros.
    """

    def __init__(self, offset: float = 1.0) -> None:
        self.offset = offset

    def fit(self, X: ArrayLike, y: ArrayLike | None = None) -> "LogTransformer":
        """No fitting required."""
        return self

    def transform(self, X: ArrayLike) -> np.ndarray:
        """Apply log(X + offset)."""
        X_arr = np.asarray(X, dtype=np.float64)
        return np.log(X_arr + self.offset)

    def inverse_transform(self, X: ArrayLike) -> np.ndarray:
        """Invert the log transformation."""
        X_arr = np.asarray(X, dtype=np.float64)
        return np.exp(X_arr) - self.offset


class OutlierClipper(TransformerMixin, BaseEstimator):
    """Clip values outside quantile-based bounds (winsorization).

    Parameters
    ----------
    lower_quantile : float, default 0.01
        Lower quantile for clipping.
    upper_quantile : float, default 0.99
        Upper quantile for clipping.
    """

    def __init__(
        self, lower_quantile: float = 0.01, upper_quantile: float = 0.99
    ) -> None:
        self.lower_quantile = lower_quantile
        self.upper_quantile = upper_quantile

    def fit(self, X: ArrayLike, y: ArrayLike | None = None) -> "OutlierClipper":
        """Compute quantile bounds from training data."""
        X_arr = np.asarray(X, dtype=np.float64)
        self.lower_bound_ = np.quantile(X_arr, self.lower_quantile, axis=0)
        self.upper_bound_ = np.quantile(X_arr, self.upper_quantile, axis=0)
        return self

    def transform(self, X: ArrayLike) -> np.ndarray:
        """Clip values to the fitted bounds."""
        X_arr = np.asarray(X, dtype=np.float64)
        return np.clip(X_arr, self.lower_bound_, self.upper_bound_)
