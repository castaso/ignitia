"""Bulk employee import helpers — CSV and Excel parsing + row validation."""

import csv
import io

REQUIRED_COLUMNS = [
    "employee_id", "name", "email", "designation", "department_id", "joining_date"
]


# ---------------------------------------------------------------------------
# Date normalisation
# ---------------------------------------------------------------------------

def normalize_date(value: str) -> str | None:
    """Try multiple date formats and return yyyy-MM-dd, or None on failure."""
    if not value or not value.strip():
        return None
    value = value.strip()
    formats = [
        ("%Y-%m-%d", lambda s: s),
        ("%d/%m/%Y", lambda s: s),
        ("%m/%d/%Y", lambda s: s),
        ("%d-%m-%Y", lambda s: s),
        ("%Y/%m/%d", lambda s: s),
    ]
    from datetime import datetime
    for fmt, _ in formats:
        try:
            return datetime.strptime(value, fmt).strftime("%Y-%m-%d")
        except ValueError:
            continue
    return None


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------

def parse_csv(file_bytes: bytes) -> list[dict]:
    """Parse CSV bytes into a list of row dicts.  Tries UTF-8 then latin-1."""
    for encoding in ("utf-8-sig", "utf-8", "latin-1"):
        try:
            text = file_bytes.decode(encoding)
            reader = csv.DictReader(io.StringIO(text))
            return [dict(row) for row in reader]
        except (UnicodeDecodeError, Exception):
            continue
    raise ValueError("File CSV tidak dapat didekode (coba simpan sebagai UTF-8)")


def parse_excel(file_bytes: bytes) -> list[dict]:
    """Parse Excel (.xlsx) bytes into a list of row dicts (first sheet only)."""
    try:
        import openpyxl
    except ImportError:
        raise ImportError("openpyxl diperlukan untuk membaca file Excel")

    wb = openpyxl.load_workbook(io.BytesIO(file_bytes), read_only=True, data_only=True)
    ws = wb.worksheets[0]
    rows = list(ws.iter_rows(values_only=True))
    if not rows:
        return []
    headers = [str(h).strip() if h is not None else "" for h in rows[0]]
    result = []
    for row in rows[1:]:
        if all(v is None for v in row):
            continue  # skip blank rows
        result.append({headers[i]: (str(v).strip() if v is not None else "") for i, v in enumerate(row)})
    return result


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

def validate_row(row: dict, required_cols: list[str] | None = None) -> list[str]:
    """Return a list of error messages for the given row.
    Empty list means the row is valid."""
    cols = required_cols or REQUIRED_COLUMNS
    errors = []
    for col in cols:
        val = row.get(col, "")
        if not str(val).strip():
            errors.append(f"Field '{col}' wajib diisi")

    # joining_date format check
    jd = row.get("joining_date", "")
    if jd and str(jd).strip() and normalize_date(str(jd).strip()) is None:
        errors.append("Format joining_date tidak valid (gunakan yyyy-MM-dd, dd/MM/yyyy, atau MM/dd/yyyy)")

    # department_id must be numeric
    dept = row.get("department_id", "")
    if dept and str(dept).strip():
        try:
            int(str(dept).strip())
        except ValueError:
            errors.append("department_id harus berupa angka")

    return errors
