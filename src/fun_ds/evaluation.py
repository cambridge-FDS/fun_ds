"""Model evaluation utilities."""

import pandas as pd
from numpy.typing import ArrayLike
from sklearn.model_selection import cross_validate


def cross_val_summary(
    estimator: object,
    X: ArrayLike,
    y: ArrayLike,
    *,
    cv: int = 5,
    scoring: list[str] | None = None,
) -> pd.DataFrame:
    """Run cross-validation and return a summary DataFrame.

    Parameters
    ----------
    estimator : sklearn estimator
        Model to evaluate.
    X : array-like
        Feature matrix.
    y : array-like
        Target vector.
    cv : int, default 5
        Number of cross-validation folds.
    scoring : list of str, optional
        Scoring metrics. Defaults to ["r2", "neg_mean_squared_error"].

    Returns
    -------
    pd.DataFrame
        Summary with mean and std for each metric.
    """
    if scoring is None:
        scoring = ["r2", "neg_mean_squared_error"]

    results = cross_validate(estimator, X, y, cv=cv, scoring=scoring)

    summary = {}
    for metric in scoring:
        key = f"test_{metric}"
        values = results[key]
        summary[metric] = {"mean": values.mean(), "std": values.std()}

    return pd.DataFrame(summary).T


def compare_models(
    models: dict[str, object],
    X: ArrayLike,
    y: ArrayLike,
    *,
    cv: int = 5,
    scoring: str = "r2",
) -> pd.DataFrame:
    """Compare multiple models via cross-validation.

    Parameters
    ----------
    models : dict
        Mapping of model name to estimator.
    X : array-like
        Feature matrix.
    y : array-like
        Target vector.
    cv : int, default 5
        Number of folds.
    scoring : str, default "r2"
        Scoring metric.

    Returns
    -------
    pd.DataFrame
        Comparison table with mean and std for each model.
    """
    rows = []
    for name, estimator in models.items():
        results = cross_validate(estimator, X, y, cv=cv, scoring=[scoring])
        values = results[f"test_{scoring}"]
        rows.append({"model": name, "mean": values.mean(), "std": values.std()})

    return pd.DataFrame(rows).set_index("model").sort_values("mean", ascending=False)
