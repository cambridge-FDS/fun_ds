"""Smoke test for the Streamlit feature-engineering playground."""

from pathlib import Path

import pytest

pytest.importorskip("streamlit")
from streamlit.testing.v1 import AppTest  # noqa: E402

APP = Path(__file__).parents[1] / "apps" / "fe_playground" / "app.py"


def test_app_runs_and_records_attempts():
    at = AppTest.from_file(str(APP), default_timeout=120).run()
    assert not at.exception
    assert len(at.session_state["history"]) == 1

    at.checkbox[0].check().run()  # log(1 + x) of skewed counts
    assert not at.exception
    history = at.session_state["history"]
    assert len(history) == 2
    assert history[1]["cv_rmse"] < history[0]["cv_rmse"]


def test_test_set_submission_is_rationed():
    at = AppTest.from_file(str(APP), default_timeout=120).run()
    at.button[0].click().run()
    assert not at.exception
    assert len(at.session_state["submissions"]) == 1
    # Resubmitting the same recipe is blocked.
    assert at.button[0].disabled


def test_every_transformation_view_renders():
    at = AppTest.from_file(str(APP), default_timeout=120).run()
    at.checkbox[3].check().run()  # splines, so the learned curve bends
    for option in at.selectbox[0].options:
        at.selectbox[0].select(option).run()
        assert not at.exception, option
