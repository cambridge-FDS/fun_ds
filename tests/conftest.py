"""Shared test fixtures."""

import numpy as np
import pandas as pd
import pytest


@pytest.fixture
def sample_df() -> pd.DataFrame:
    """Small DataFrame for unit tests."""
    rng = np.random.default_rng(42)
    return pd.DataFrame(
        {
            "feature_a": rng.normal(5, 2, size=100),
            "feature_b": rng.normal(0, 1, size=100),
            "target": rng.normal(10, 3, size=100),
        }
    )
