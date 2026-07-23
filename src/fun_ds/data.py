"""Data loading utilities for the course."""

import numpy as np
import pandas as pd
from sklearn.datasets import fetch_california_housing


def load_california_housing(
    *, include_target: bool = True, add_ratios: bool = False
) -> pd.DataFrame:
    """Load the California Housing dataset as a clean DataFrame.

    Parameters
    ----------
    include_target : bool, default True
        Whether to include the target column (MedHouseVal).
    add_ratios : bool, default False
        Whether to add domain-specific ratio features
        (rooms_per_household, bedrooms_per_room).

    Returns
    -------
    pd.DataFrame
        The California Housing dataset.
    """
    housing = fetch_california_housing(as_frame=True)
    df = housing.frame if include_target else housing.data

    if add_ratios:
        df = df.copy()
        df["rooms_per_household"] = df["AveRooms"] / df["AveOccup"]
        df["bedrooms_per_room"] = df["AveBedrms"] / df["AveRooms"]

    return df


def make_regression_dataset(
    n_samples: int = 500,
    n_informative: int = 5,
    n_noise: int = 10,
    noise: float = 0.3,
    interaction: bool = True,
    random_state: int = 42,
) -> tuple[pd.DataFrame, pd.Series]:
    """Generate a synthetic regression dataset for teaching.

    Creates a dataset with a known ground-truth structure so students
    can verify that feature selection, regularisation, or importance
    methods correctly recover the signal.

    Parameters
    ----------
    n_samples : int, default 500
    n_informative : int, default 5
        Number of features with true signal.
    n_noise : int, default 10
        Number of irrelevant features (pure noise).
    noise : float, default 0.3
        Standard deviation of Gaussian noise added to y.
    interaction : bool, default True
        If True, adds a x0*x1 interaction term to y.
    random_state : int, default 42

    Returns
    -------
    X : pd.DataFrame
        Feature matrix with columns x0, x1, ..., x{n_informative+n_noise-1}.
        Informative features are x0..x{n_informative-1}; noise features follow.
    y : pd.Series
        Regression target.
    """
    rng = np.random.default_rng(random_state)
    n_total = n_informative + n_noise

    X_arr = rng.standard_normal((n_samples, n_total))
    coefs = rng.uniform(0.5, 2.0, size=n_informative) * rng.choice([-1, 1], size=n_informative)
    y_arr = X_arr[:, :n_informative] @ coefs

    if interaction and n_informative >= 2:
        y_arr += X_arr[:, 0] * X_arr[:, 1]

    y_arr += rng.normal(0, noise, size=n_samples)

    col_names = [f"x{i}" for i in range(n_total)]
    X_df = pd.DataFrame(X_arr, columns=col_names)
    return X_df, pd.Series(y_arr, name="target")
