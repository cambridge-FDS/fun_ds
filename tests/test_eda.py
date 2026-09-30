"""Tests for fun_ds.eda."""

import numpy as np
import pandas as pd
import pytest

from fun_ds.eda import DataProfiler


def test_high_correlation_pairs_finds_correlated_columns(sample_df):
    df = sample_df.assign(feature_c=2 * sample_df["feature_a"] + 1)
    pairs = DataProfiler().fit(df).high_correlation_pairs(threshold=0.9)
    assert len(pairs) == 1
    assert set(pairs.loc[0, ["feature_a", "feature_b"]]) == {"feature_a", "feature_c"}
    assert np.isclose(pairs.loc[0, "correlation"], 1.0)


def test_high_correlation_pairs_empty_when_nothing_passes(sample_df):
    pairs = DataProfiler().fit(sample_df).high_correlation_pairs(threshold=0.99)
    assert pairs.empty
    assert list(pairs.columns) == ["feature_a", "feature_b", "correlation"]


def test_missing_summary_only_reports_columns_with_missing(sample_df):
    df = sample_df.copy()
    df.loc[:9, "feature_b"] = np.nan
    summary = DataProfiler().fit(df).missing_summary()
    assert list(summary.index) == ["feature_b"]
    assert summary.loc["feature_b", "pct"] == pytest.approx(10.0)


def test_unfitted_profiler_raises():
    with pytest.raises(RuntimeError):
        DataProfiler().missing_summary()


def test_distribution_summary_counts_outliers():
    df = pd.DataFrame({"x": [1.0, 2.0, 3.0, 4.0, 100.0]})
    summary = DataProfiler().fit(df).distribution_summary()
    assert summary.loc["x", "outlier_pct"] == pytest.approx(20.0)
