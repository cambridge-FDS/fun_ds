"""Data loading utilities for the course."""

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
