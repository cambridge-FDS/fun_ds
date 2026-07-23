"""DataFrame profiling for exploratory data analysis."""
import numpy as np
import pandas as pd


class DataProfiler:
    """Compute a structured profile of a pandas DataFrame.

    Parameters
    ----------
    correlation_method : {"pearson", "spearman", "kendall"}, default "pearson"
        Method used for the correlation matrix.
    outlier_iqr_factor : float, default 1.5
        Multiplier for the IQR-based outlier fence (Tukey's rule).

    Examples
    --------
    >>> from fun_ds.data import load_california_housing
    >>> profiler = DataProfiler().fit(load_california_housing())
    >>> profiler.missing_summary()
    >>> profiler.distribution_summary()
    >>> profiler.high_correlation_pairs(threshold=0.7)
    """

    def __init__(
        self,
        correlation_method: str = "pearson",
        outlier_iqr_factor: float = 1.5,
    ) -> None:
        self.correlation_method = correlation_method
        self.outlier_iqr_factor = outlier_iqr_factor

    def fit(self, df: pd.DataFrame) -> "DataProfiler":
        """Compute and cache all profile statistics.

        Parameters
        ----------
        df : pd.DataFrame
            The dataset to profile.

        Returns
        -------
        DataProfiler
            self, for method chaining.
        """
        self._df = df
        self._n_rows, self._n_cols = df.shape
        self._numeric_cols = df.select_dtypes(include="number").columns.tolist()
        self._cat_cols = df.select_dtypes(exclude="number").columns.tolist()
        return self

    def _check_fitted(self) -> None:
        if not hasattr(self, "_df"):
            raise RuntimeError("Call .fit(df) before accessing profile methods.")

    def missing_summary(self) -> pd.DataFrame:
        """Return a DataFrame with missing value counts and percentages per column.

        Returns
        -------
        pd.DataFrame
            Columns: count, pct, dtype.
            Only includes columns that have at least one missing value.
            Sorted descending by count.
        """
        self._check_fitted()
        missing = self._df.isnull().sum()
        result = pd.DataFrame({
            "count": missing,
            "pct": missing / self._n_rows * 100,
            "dtype": self._df.dtypes,
        })
        return result[result["count"] > 0].sort_values("count", ascending=False)

    def distribution_summary(self) -> pd.DataFrame:
        """Return descriptive statistics for all numeric columns.

        Includes: mean, std, skewness, excess kurtosis, IQR, outlier_pct.
        outlier_pct is the fraction of values outside the Tukey fence
        (Q1 - factor*IQR, Q3 + factor*IQR).

        Returns
        -------
        pd.DataFrame
            One row per numeric column.
        """
        self._check_fitted()
        if not self._numeric_cols:
            return pd.DataFrame()

        num = self._df[self._numeric_cols]
        q1 = num.quantile(0.25)
        q3 = num.quantile(0.75)
        iqr = q3 - q1
        lower = q1 - self.outlier_iqr_factor * iqr
        upper = q3 + self.outlier_iqr_factor * iqr
        outlier_mask = (num < lower) | (num > upper)

        return pd.DataFrame({
            "mean": num.mean(),
            "std": num.std(),
            "skewness": num.skew(),
            "kurtosis": num.kurt(),  # excess kurtosis
            "iqr": iqr,
            "outlier_pct": outlier_mask.mean() * 100,
        })

    def high_correlation_pairs(self, threshold: float = 0.8) -> pd.DataFrame:
        """Return pairs of numeric columns whose absolute correlation exceeds threshold.

        Parameters
        ----------
        threshold : float, default 0.8
            Minimum absolute correlation to report.

        Returns
        -------
        pd.DataFrame
            Columns: feature_a, feature_b, correlation.
            Sorted descending by |correlation|. Upper-triangle only (no duplicates).
        """
        self._check_fitted()
        if len(self._numeric_cols) < 2:
            return pd.DataFrame(columns=["feature_a", "feature_b", "correlation"])

        corr = self._df[self._numeric_cols].corr(method=self.correlation_method)
        rows = []
        cols = corr.columns.tolist()
        for i, a in enumerate(cols):
            for b in cols[i + 1:]:
                val = corr.loc[a, b]
                if abs(val) >= threshold:
                    rows.append({"feature_a": a, "feature_b": b, "correlation": val})

        return (
            pd.DataFrame(rows)
            .sort_values("correlation", key=abs, ascending=False)
            .reset_index(drop=True)
        )

    @property
    def shape(self) -> tuple[int, int]:
        """Shape of the fitted DataFrame."""
        self._check_fitted()
        return self._n_rows, self._n_cols

    def __repr__(self) -> str:
        if not hasattr(self, "_df"):
            return "DataProfiler(not fitted)"
        return (
            f"DataProfiler(rows={self._n_rows}, cols={self._n_cols}, "
            f"numeric={len(self._numeric_cols)}, categorical={len(self._cat_cols)})"
        )
