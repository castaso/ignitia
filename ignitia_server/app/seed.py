"""Seed reference / demo data.

Called from ``main.py`` lifespan on every startup — all functions are
idempotent (they skip existing records).
"""

from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from .models import Employee, PtkpStatus
from .security import hash_password

# ---------------------------------------------------------------------------
# PTKP statuses — DJP Indonesia (PMK 101/PMK.010/2016)
# ---------------------------------------------------------------------------

_PTKP_DATA = [
    ("TK/0", "Tidak Kawin, 0 tanggungan",  54_000_000.0),
    ("TK/1", "Tidak Kawin, 1 tanggungan",  58_500_000.0),
    ("TK/2", "Tidak Kawin, 2 tanggungan",  63_000_000.0),
    ("TK/3", "Tidak Kawin, 3 tanggungan",  67_500_000.0),
    ("K/0",  "Kawin, 0 tanggungan",         58_500_000.0),
    ("K/1",  "Kawin, 1 tanggungan",         63_000_000.0),
    ("K/2",  "Kawin, 2 tanggungan",         67_500_000.0),
    ("K/3",  "Kawin, 3 tanggungan",         72_000_000.0),
]


def seed_ptkp_statuses(db: Session) -> None:
    """Insert PTKP rows that don't already exist (idempotent by code)."""
    existing = {row.code for row in db.query(PtkpStatus.code).all()}
    for code, desc, value in _PTKP_DATA:
        if code not in existing:
            db.add(PtkpStatus(code=code, description=desc, annual_value=value))
    db.commit()


# ---------------------------------------------------------------------------
# Dashboard chart dimensions — backfill demo values for legacy rows
# ---------------------------------------------------------------------------


def seed_employee_dashboard_fields(db: Session) -> None:
    """Fill demo values for gender / job_level / employment_status /
    contract_end_date / permanent_date on employees that still have NULLs.

    Idempotent: every field is only written when NULL, and the values are
    deterministic per row position so restarts never re-shuffle the data.
    """
    today = datetime.now(timezone.utc).replace(tzinfo=None)
    changed = False
    for i, emp in enumerate(db.query(Employee).order_by(Employee.id).all(), start=1):
        if emp.gender is None:
            emp.gender = "Male" if i % 2 else "Female"
            changed = True
        if emp.job_level is None:
            if emp.type_id == 1:
                emp.job_level = "Manager"
            elif i % 7 == 0:
                emp.job_level = "Supervisor"
            else:
                emp.job_level = "Staff"
            changed = True
        if emp.employment_status is None:
            emp.employment_status = (
                "Contract" if i % 6 == 0
                else "Intern" if i % 9 == 0
                else "Full-time"
            )
            changed = True
        if (
            emp.contract_end_date is None
            and emp.employment_status == "Contract"
        ):
            # Deterministic end date; some fall inside the 30-day
            # contract/probation dashboard window on purpose.
            emp.contract_end_date = (
                today + timedelta(days=10 + (i % 45))
            ).strftime("%Y-%m-%d")
            changed = True
        if emp.permanent_date is None and emp.joining_date is not None:
            # Demo employees (i % 5 == 0) get a probation end date near
            # today so the "Contract & Probation" card has data; everyone
            # else gets the classic joining_date + 3 months.
            if i % 5 == 0:
                emp.permanent_date = today + timedelta(days=(i % 25) - 5)
            else:
                emp.permanent_date = emp.joining_date + timedelta(days=90)
            changed = True
    if changed:
        db.commit()


SSO_ADMIN_EMAIL = "castasoft@gmail.com"


def seed_sso_admin(db: Session) -> None:
    """Ensure the Google SSO account can log in (idempotent by email)."""
    existing = (
        db.query(Employee)
        .filter(Employee.email == SSO_ADMIN_EMAIL)
        .first()
    )
    if existing is not None:
        if existing.status_id != 1:
            existing.status_id = 1
            db.commit()
        return
    emp = Employee(
        employee_id="ADM-SSO",
        name="Casta Soft",
        designation="Administrator",
        email=SSO_ADMIN_EMAIL,
        type_id=1,
        status_id=1,
        joining_date=datetime(2024, 1, 1),
        basic_salary=0.0,
    )
    emp.password_hash = hash_password("castasoft1234")
    db.add(emp)
    db.commit()
