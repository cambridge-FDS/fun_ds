"""Tests for fun_ds.data module."""

import pandas as pd

from fun_ds.data import load_california_housing


def test_load_california_housing_default():
    df = load_california_housing()
    assert isinstance(df, pd.DataFrame)
    assert "MedHouseVal" in df.columns
    assert len(df) == 20640


def test_load_california_housing_no_target():
    df = load_california_housing(include_target=False)
    assert "MedHouseVal" not in df.columns


def test_load_california_housing_with_ratios():
    df = load_california_housing(add_ratios=True)
    assert "rooms_per_household" in df.columns
    assert "bedrooms_per_room" in df.columns
