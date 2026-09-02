"""Unit tests for bulk_import utility functions."""
import io
import base64
import pytest

from app.utils.bulk_import import (
    normalize_date,
    parse_csv,
    parse_excel,
    validate_row,
    REQUIRED_COLUMNS,
)


# ---------------------------------------------------------------------------
# normalize_date
# ---------------------------------------------------------------------------

def test_normalize_date_iso():
    assert normalize_date("2024-03-15") == "2024-03-15"


def test_normalize_date_dmy_slash():
    assert normalize_date("15/03/2024") == "2024-03-15"


def test_normalize_date_mdy_slash():
    assert normalize_date("03/15/2024") == "2024-03-15"


def test_normalize_date_invalid():
    assert normalize_date("not-a-date") is None


def test_normalize_date_empty():
    assert normalize_date("") is None


def test_normalize_date_none():
    assert normalize_date(None) is None


# ---------------------------------------------------------------------------
# parse_csv
# ---------------------------------------------------------------------------

_VALID_CSV = (
    "employee_id,name,email,designation,department_id,joining_date\n"
    "EMP100,Alice,alice@test.com,Engineer,1,2024-01-01\n"
    "EMP101,Bob,bob@test.com,Designer,2,2024-02-01\n"
)


def test_parse_csv_valid():
    rows = parse_csv(_VALID_CSV.encode())
    assert len(rows) == 2
    assert rows[0]["name"] == "Alice"
    assert rows[1]["employee_id"] == "EMP101"


def test_parse_csv_utf8_bom():
    bom_csv = "\ufeff" + _VALID_CSV
    rows = parse_csv(bom_csv.encode("utf-8-sig"))
    assert len(rows) == 2


def test_parse_csv_latin1():
    latin1_csv = "employee_id,name,email,designation,department_id,joining_date\nEMP200,Caf\xe9,cafe@test.com,Eng,1,2024-01-01\n"
    rows = parse_csv(latin1_csv.encode("latin-1"))
    assert len(rows) == 1


def test_parse_csv_empty():
    rows = parse_csv(b"employee_id,name,email,designation,department_id,joining_date\n")
    assert rows == []


# ---------------------------------------------------------------------------
# parse_excel
# ---------------------------------------------------------------------------

def _make_xlsx_bytes(rows_data: list[list]) -> bytes:
    """Create a minimal xlsx in-memory."""
    openpyxl = pytest.importorskip("openpyxl")
    wb = openpyxl.Workbook()
    ws = wb.active
    for row in rows_data:
        ws.append(row)
    buf = io.BytesIO()
    wb.save(buf)
    return buf.getvalue()


def test_parse_excel_basic():
    data = [
        ["employee_id", "name", "email", "designation", "department_id", "joining_date"],
        ["EMP300", "Carol", "carol@test.com", "PM", "1", "2024-06-01"],
    ]
    rows = parse_excel(_make_xlsx_bytes(data))
    assert len(rows) == 1
    assert rows[0]["name"] == "Carol"


def test_parse_excel_empty_rows_skipped():
    data = [
        ["employee_id", "name", "email", "designation", "department_id", "joining_date"],
        [None, None, None, None, None, None],
        ["EMP301", "Dave", "dave@test.com", "Dev", "1", "2024-01-01"],
    ]
    rows = parse_excel(_make_xlsx_bytes(data))
    assert len(rows) == 1


# ---------------------------------------------------------------------------
# validate_row
# ---------------------------------------------------------------------------

_VALID_ROW = {
    "employee_id": "EMP999",
    "name": "Test",
    "email": "test@test.com",
    "designation": "Dev",
    "department_id": "1",
    "joining_date": "2024-01-01",
}


def test_validate_row_valid():
    assert validate_row(_VALID_ROW) == []


def test_validate_row_missing_email():
    row = {**_VALID_ROW, "email": ""}
    errors = validate_row(row)
    assert any("email" in e for e in errors)


def test_validate_row_missing_employee_id():
    row = {**_VALID_ROW, "employee_id": ""}
    errors = validate_row(row)
    assert any("employee_id" in e for e in errors)


def test_validate_row_bad_date():
    row = {**_VALID_ROW, "joining_date": "not-a-date"}
    errors = validate_row(row)
    assert any("joining_date" in e for e in errors)


def test_validate_row_non_numeric_dept():
    row = {**_VALID_ROW, "department_id": "abc"}
    errors = validate_row(row)
    assert any("department_id" in e for e in errors)
