"""Tests for fun_ds.evaluation module."""

import pandas as pd
from sklearn.linear_model import LinearRegression, Ridge

from fun_ds.evaluation import compare_models, cross_val_summary


def test_cross_val_summary(sample_df):
    X = sample_df[["feature_a", "feature_b"]]
    y = sample_df["target"]
    result = cross_val_summary(LinearRegression(), X, y, cv=3)
    assert isinstance(result, pd.DataFrame)
    assert "mean" in result.columns
    assert "std" in result.columns


def test_compare_models(sample_df):
    X = sample_df[["feature_a", "feature_b"]]
    y = sample_df["target"]
    models = {"lr": LinearRegression(), "ridge": Ridge(alpha=1.0)}
    result = compare_models(models, X, y, cv=3)
    assert isinstance(result, pd.DataFrame)
    assert len(result) == 2
    assert result.index.name == "model"
