"""Cross-validation helpers for model selection."""
import pandas as pd
from numpy.typing import ArrayLike
from sklearn.model_selection import cross_validate


def cross_val_summary(
    estimator,
    X: ArrayLike,
    y: ArrayLike,
    *,
    cv: int = 5,
    scoring: list[str] | None = None,
) -> pd.DataFrame:
    """Run k-fold cross-validation and return a mean/std summary table.

    Parameters
    ----------
    estimator : sklearn estimator
    X : array-like
    y : array-like
    cv : int, default 5
    scoring : list of str, optional
        Defaults to ["r2", "neg_mean_squared_error"].

    Returns
    -------
    pd.DataFrame
        Index: metric name. Columns: mean, std.
    """
    if scoring is None:
        scoring = ["r2", "neg_mean_squared_error"]
    results = cross_validate(estimator, X, y, cv=cv, scoring=scoring)
    summary = {}
    for metric in scoring:
        vals = results[f"test_{metric}"]
        summary[metric] = {"mean": vals.mean(), "std": vals.std()}
    return pd.DataFrame(summary).T


def compare_models(
    models: dict,
    X: ArrayLike,
    y: ArrayLike,
    *,
    cv: int = 5,
    scoring: str = "r2",
) -> pd.DataFrame:
    """Compare multiple estimators via cross-validation.

    Parameters
    ----------
    models : dict[str, estimator]
    X : array-like
    y : array-like
    cv : int, default 5
    scoring : str, default "r2"

    Returns
    -------
    pd.DataFrame
        Index: model name. Columns: mean, std. Sorted by mean descending.
    """
    rows = []
    for name, est in models.items():
        res = cross_validate(est, X, y, cv=cv, scoring=[scoring])
        vals = res[f"test_{scoring}"]
        rows.append({"model": name, "mean": vals.mean(), "std": vals.std()})
    return pd.DataFrame(rows).set_index("model").sort_values("mean", ascending=False)
