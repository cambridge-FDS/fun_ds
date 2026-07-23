"""Core sklearn-compatible transformers."""
import numpy as np
from numpy.typing import ArrayLike
from sklearn.base import BaseEstimator, TransformerMixin


class LogTransformer(TransformerMixin, BaseEstimator):
    """Apply log(x + offset) transformation.

    Useful for right-skewed features such as income or house prices,
    where the log scale compresses the tail and stabilises variance.

    Parameters
    ----------
    offset : float, default 1.0
        Added before log to handle zeros. Use offset=0 only when
        all values are strictly positive.
    """

    def __init__(self, offset: float = 1.0) -> None:
        self.offset = offset

    def fit(self, X: ArrayLike, y: ArrayLike | None = None) -> "LogTransformer":
        """No-op: transformation has no learnable parameters."""
        return self

    def transform(self, X: ArrayLike) -> np.ndarray:
        """Apply log(X + offset)."""
        return np.log(np.asarray(X, dtype=np.float64) + self.offset)

    def inverse_transform(self, X: ArrayLike) -> np.ndarray:
        """Invert: exp(X) - offset."""
        return np.exp(np.asarray(X, dtype=np.float64)) - self.offset


class OutlierClipper(TransformerMixin, BaseEstimator):
    """Clip values outside quantile-based bounds (Winsorisation).

    Learns the lower and upper fences from training data and applies
    them to any new data — including at inference time, preventing
    extreme outliers from destabilising a fitted model.

    Parameters
    ----------
    lower_quantile : float, default 0.01
    upper_quantile : float, default 0.99

    Attributes
    ----------
    lower_bound_ : np.ndarray
        Per-column lower fence fitted from training data.
    upper_bound_ : np.ndarray
        Per-column upper fence fitted from training data.
    """

    def __init__(
        self,
        lower_quantile: float = 0.01,
        upper_quantile: float = 0.99,
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
        return np.clip(np.asarray(X, dtype=np.float64), self.lower_bound_, self.upper_bound_)
