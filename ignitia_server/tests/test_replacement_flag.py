"""Unit tests for replacement tracking is_overdue flag logic."""
from datetime import date, timedelta

from app.routers.replacement_tracking import _is_overdue
from app.models import ReplacementTracking


def _make_record(status: str, expected_fill_date: str) -> ReplacementTracking:
    r = ReplacementTracking()
    r.status = status
    r.expected_fill_date = expected_fill_date
    return r


def test_open_overdue():
    yesterday = (date.today() - timedelta(days=1)).isoformat()
    assert _is_overdue(_make_record("Open", yesterday)) is True


def test_open_not_overdue():
    tomorrow = (date.today() + timedelta(days=1)).isoformat()
    assert _is_overdue(_make_record("Open", tomorrow)) is False


def test_open_today_not_overdue():
    today = date.today().isoformat()
    assert _is_overdue(_make_record("Open", today)) is False


def test_filled_never_overdue():
    yesterday = (date.today() - timedelta(days=1)).isoformat()
    assert _is_overdue(_make_record("Filled", yesterday)) is False


def test_cancelled_never_overdue():
    yesterday = (date.today() - timedelta(days=1)).isoformat()
    assert _is_overdue(_make_record("Cancelled", yesterday)) is False


def test_invalid_date_not_overdue():
    assert _is_overdue(_make_record("Open", "not-a-date")) is False


def test_empty_date_not_overdue():
    assert _is_overdue(_make_record("Open", "")) is False
