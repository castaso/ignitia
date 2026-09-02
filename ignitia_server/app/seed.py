"""Seed reference / demo data.

Called from ``main.py`` lifespan on every startup — all functions are
idempotent (they skip existing records).
"""

from sqlalchemy.orm import Session

from .models import PtkpStatus

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
