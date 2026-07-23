"""OLS regression diagnostics: leverage, Cook's distance, residual analysis."""

from __future__ import annotations

import numpy as np
import pandas as pd
from numpy.typing import ArrayLike


class OLSDiagnostics:
    """Compute and visualise OLS diagnostics for a fitted linear model.

    Computes the classic set of OLS post-fit diagnostics:
    - **Leverage** h_ii: diagonal of the hat matrix H = X(X'X)⁻¹X'.
      High-leverage points can exert disproportionate influence on the fit.
    - **Standardised residuals**: residual divided by its estimated std,
      accounting for the reduction in variance at high-leverage points.
    - **Cook's distance**: combined measure of leverage and residual size.
      Cook's D_i ≈ 1 flags a point as individually influential.

    Parameters
    ----------
    estimator : fitted sklearn LinearRegression (or compatible)
        Must have been fitted before passing here.
    X : array-like of shape (n_samples, n_features)
        The training features used to fit `estimator`.
    y : array-like of shape (n_samples,)
        The training targets.

    Attributes
    ----------
    leverage_ : np.ndarray of shape (n_samples,)
    standardised_residuals_ : np.ndarray of shape (n_samples,)
    cooks_distance_ : np.ndarray of shape (n_samples,)

    Examples
    --------
    >>> from sklearn.linear_model import LinearRegression
    >>> from fun_ds.data import load_california_housing
    >>> from fun_ds.model.diagnostics import OLSDiagnostics
    >>> df = load_california_housing()
    >>> X = df.drop(columns="MedHouseVal").values
    >>> y = df["MedHouseVal"].values
    >>> diag = OLSDiagnostics(LinearRegression().fit(X, y), X, y)
    >>> diag.summary().head()
    >>> diag.influential_points()
    """

    def __init__(self, estimator, X: ArrayLike, y: ArrayLike) -> None:
        self.estimator = estimator
        X_arr = np.asarray(X, dtype=float)
        y_arr = np.asarray(y, dtype=float)
        n, p = X_arr.shape

        y_pred = estimator.predict(X_arr)
        residuals = y_arr - y_pred

        # Hat matrix diagonal via QR decomposition (numerically stable)
        # H = X (X'X)^{-1} X' => h_ii = ||q_i||^2 where X = QR
        X_aug = np.column_stack([np.ones(n), X_arr])  # add intercept column
        Q, _ = np.linalg.qr(X_aug)
        self.leverage_ = np.sum(Q**2, axis=1)  # h_ii

        # Residual standard error (unbiased)
        dof = n - p - 1
        sigma2 = np.sum(residuals**2) / max(dof, 1)

        # Standardised (internally studentised) residuals
        denom = np.sqrt(sigma2 * np.maximum(1.0 - self.leverage_, 1e-12))
        self.standardised_residuals_ = residuals / denom

        # Cook's distance: D_i = (e_i^2 / (p * sigma^2)) * (h_ii / (1 - h_ii)^2)
        self.cooks_distance_ = (
            residuals**2
            / (max(p, 1) * sigma2)
            * (self.leverage_ / np.maximum((1.0 - self.leverage_) ** 2, 1e-12))
        )

        self._residuals = residuals
        self._y_pred = y_pred
        self._n = n

    def summary(self, index: pd.Index | None = None) -> pd.DataFrame:
        """Return diagnostics as a DataFrame.

        Parameters
        ----------
        index : pd.Index, optional
            Row labels (e.g., df.index). Uses 0..n-1 if None.

        Returns
        -------
        pd.DataFrame
            Columns: y_pred, residual, leverage, std_residual, cooks_d.
            Sorted by cooks_d descending.
        """
        idx = index if index is not None else pd.RangeIndex(self._n)
        return pd.DataFrame(
            {
                "y_pred": self._y_pred,
                "residual": self._residuals,
                "leverage": self.leverage_,
                "std_residual": self.standardised_residuals_,
                "cooks_d": self.cooks_distance_,
            },
            index=idx,
        ).sort_values("cooks_d", ascending=False)

    def influential_points(self, threshold: float | None = None) -> pd.DataFrame:
        """Return rows where Cook's distance exceeds the threshold.

        Parameters
        ----------
        threshold : float, optional
            Defaults to 4/n (conventional rule of thumb).

        Returns
        -------
        pd.DataFrame
            Subset of summary() for influential points.
        """
        cutoff = threshold if threshold is not None else 4.0 / self._n
        df = self.summary()
        return df[df["cooks_d"] > cutoff]

    def plot(self, figsize: tuple[float, float] = (12, 10)) -> object:
        """Draw the classic 2×2 OLS diagnostic plot.

        Panels:
        1. Residuals vs Fitted
        2. Normal Q-Q of standardised residuals
        3. Scale-Location (sqrt|std_residual| vs fitted)
        4. Leverage vs standardised residuals (Cook's contours)

        Returns
        -------
        matplotlib.figure.Figure
        """
        import matplotlib.pyplot as plt
        from scipy import stats

        fig, axes = plt.subplots(2, 2, figsize=figsize)
        fig.suptitle("OLS Regression Diagnostics", fontsize=14)

        sr = self.standardised_residuals_
        lev = self.leverage_
        fitted = self._y_pred

        # 1. Residuals vs Fitted
        ax = axes[0, 0]
        ax.scatter(fitted, self._residuals, alpha=0.3, s=8)
        ax.axhline(0, color="red", linestyle="--", linewidth=1)
        ax.set_xlabel("Fitted values")
        ax.set_ylabel("Residuals")
        ax.set_title("Residuals vs Fitted")

        # 2. Normal Q-Q
        ax = axes[0, 1]
        (osm, osr), _ = stats.probplot(sr, dist="norm")
        ax.scatter(osm, osr, alpha=0.3, s=8)
        ax.plot(osm, osm, color="red", linestyle="--", linewidth=1)
        ax.set_xlabel("Theoretical quantiles")
        ax.set_ylabel("Standardised residuals")
        ax.set_title("Normal Q-Q")

        # 3. Scale-Location
        ax = axes[1, 0]
        ax.scatter(fitted, np.sqrt(np.abs(sr)), alpha=0.3, s=8)
        ax.set_xlabel("Fitted values")
        ax.set_ylabel("√|Standardised residuals|")
        ax.set_title("Scale-Location")

        # 4. Residuals vs Leverage
        ax = axes[1, 1]
        ax.scatter(lev, sr, alpha=0.3, s=8)
        ax.axhline(0, color="grey", linestyle="--", linewidth=0.8)
        ax.set_xlabel("Leverage")
        ax.set_ylabel("Standardised residuals")
        ax.set_title("Residuals vs Leverage")

        # Cook's distance contours at D=0.5 and D=1
        x_range = np.linspace(lev.min(), lev.max(), 200)
        p = self.estimator.coef_.shape[0] if hasattr(self.estimator, "coef_") else 1
        for d in [0.5, 1.0]:
            contour = np.sqrt(d * p * (1 - x_range) / x_range)
            ax.plot(x_range, contour, "r--", linewidth=0.8, label=f"Cook's D={d}")
            ax.plot(x_range, -contour, "r--", linewidth=0.8)
        ax.legend(fontsize=8)

        fig.tight_layout()
        return fig
