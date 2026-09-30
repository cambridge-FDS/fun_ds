"""Tests for fun_ds.monitoring."""

import numpy as np
import pandas as pd
import pytest

from fun_ds.monitoring import feature_drift_report, population_stability_index
from fun_ds.monitoring.drift import drift_severity


@pytest.fixture
def ref() -> np.ndarray:
    return np.random.default_rng(0).normal(size=5_000)


def test_psi_near_zero_for_same_distribution(ref):
    cur = np.random.default_rng(1).normal(size=5_000)
    assert population_stability_index(ref, cur) < 0.01


def test_psi_large_for_shifted_distribution(ref):
    cur = np.random.default_rng(1).normal(loc=3.0, size=5_000)
    assert drift_severity(population_stability_index(ref, cur)) == "severe"


def test_psi_positive_for_small_shift(ref):
    cur = np.random.default_rng(1).normal(loc=0.5, size=5_000)
    assert population_stability_index(ref, cur) > 0


@pytest.mark.parametrize("bad", [np.nan, np.inf])
def test_psi_raises_on_non_finite_reference(ref, bad):
    ref = ref.copy()
    ref[0] = bad
    with pytest.raises(ValueError, match="NaN/inf"):
        population_stability_index(ref, np.zeros(10))


def test_psi_raises_on_non_finite_current(ref):
    cur = np.random.default_rng(1).normal(size=100)
    cur[3] = np.nan
    with pytest.raises(ValueError, match="current"):
        population_stability_index(ref, cur)


def test_psi_raises_on_constant_reference():
    with pytest.raises(ValueError, match="constant"):
        population_stability_index(
            np.ones(100), np.random.default_rng(0).normal(size=100)
        )


def test_psi_raises_on_empty_input(ref):
    with pytest.raises(ValueError, match="empty"):
        population_stability_index(ref, np.array([]))


@pytest.mark.parametrize(
    ("psi", "label"), [(0.05, "stable"), (0.10, "moderate"), (0.25, "severe")]
)
def test_drift_severity_thresholds(psi, label):
    assert drift_severity(psi) == label


def test_feature_drift_report_skips_non_numeric_and_sorts():
    rng = np.random.default_rng(0)
    ref = pd.DataFrame(
        {"a": rng.normal(size=1_000), "b": rng.normal(size=1_000), "c": ["x"] * 1_000}
    )
    cur = pd.DataFrame(
        {
            "a": rng.normal(size=1_000),
            "b": rng.normal(loc=2.0, size=1_000),
            "c": ["y"] * 1_000,
        }
    )
    report = feature_drift_report(ref, cur)
    assert list(report["feature"]) == ["b", "a"]
    assert report["psi"].is_monotonic_decreasing
