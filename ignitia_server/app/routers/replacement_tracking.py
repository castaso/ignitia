"""Replacement Tracking endpoints.

Wire contract:
  POST /api/ReplacementTrackings          -> create (admin)
  GET  /api/ReplacementTrackings          -> list with optional filters
  PUT  /api/ReplacementTrackings/{id}     -> update status (admin)
"""

from datetime import date

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee, require_admin
from ..models import Employee, ReplacementTracking
from ..schemas import fail, ok

router = APIRouter()

VALID_REASONS = {"Resign", "Long_Leave", "Transfer"}
VALID_STATUSES = {"Open", "Filled", "Cancelled"}


class ReplacementTrackingIn(BaseModel):
    departing_employee_id: int
    replacement_employee_id: int | None = None
    department_id: int
    designation: str
    departure_reason: str
    effective_date: str
    expected_fill_date: str

    model_config = ConfigDict(extra="ignore")


class ReplacementUpdateIn(BaseModel):
    replacement_employee_id: int | None = None
    fill_date: str | None = None
    status: str
    cancellation_reason: str | None = None

    model_config = ConfigDict(extra="ignore")


def _is_overdue(record: ReplacementTracking) -> bool:
    if record.status != "Open":
        return False
    try:
        exp = date.fromisoformat(record.expected_fill_date)
        return exp < date.today()
    except (ValueError, TypeError):
        return False


def _tracking_json(r: ReplacementTracking) -> dict:
    return {
        "id": r.id,
        "departing_employee_id": r.departing_employee_id,
        "replacement_employee_id": r.replacement_employee_id,
        "department_id": r.department_id,
        "designation": r.designation,
        "departure_reason": r.departure_reason,
        "effective_date": r.effective_date,
        "expected_fill_date": r.expected_fill_date,
        "fill_date": r.fill_date,
        "status": r.status,
        "cancellation_reason": r.cancellation_reason,
        "is_overdue": _is_overdue(r),
        "created_by": r.created_by,
        "created_at": r.created_at.isoformat() if r.created_at else None,
    }


@router.post("/ReplacementTrackings")
def create_replacement_tracking(
    payload: ReplacementTrackingIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    if db.get(Employee, payload.departing_employee_id) is None:
        return fail("Karyawan yang akan digantikan tidak ditemukan")

    if payload.departure_reason not in VALID_REASONS:
        return fail(
            f"Alasan kepergian harus salah satu dari: {', '.join(sorted(VALID_REASONS))}"
        )

    record = ReplacementTracking(
        departing_employee_id=payload.departing_employee_id,
        replacement_employee_id=payload.replacement_employee_id,
        department_id=payload.department_id,
        designation=payload.designation,
        departure_reason=payload.departure_reason,
        effective_date=payload.effective_date,
        expected_fill_date=payload.expected_fill_date,
        status="Open",
        created_by=auth.id,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return ok(data=_tracking_json(record), message="Kebutuhan penggantian berhasil dicatat")


@router.get("/ReplacementTrackings")
def list_replacement_trackings(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
    department_id: int = Query(0),
    status: str = Query(""),
):
    query = db.query(ReplacementTracking)
    if department_id:
        query = query.filter(ReplacementTracking.department_id == department_id)
    if status and status in VALID_STATUSES:
        query = query.filter(ReplacementTracking.status == status)
    records = query.order_by(ReplacementTracking.created_at.desc()).all()
    return ok(data=[_tracking_json(r) for r in records])


@router.put("/ReplacementTrackings/{id}")
def update_replacement_tracking(
    id: int,
    payload: ReplacementUpdateIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    record = db.get(ReplacementTracking, id)
    if record is None:
        return fail("Data penggantian tidak ditemukan")

    if payload.status not in VALID_STATUSES:
        return fail(f"Status harus salah satu dari: {', '.join(sorted(VALID_STATUSES))}")

    if payload.status == "Filled":
        if payload.replacement_employee_id:
            if db.get(Employee, payload.replacement_employee_id) is None:
                return fail("Karyawan pengganti tidak ditemukan")
            record.replacement_employee_id = payload.replacement_employee_id
        record.fill_date = payload.fill_date
        record.status = "Filled"

    elif payload.status == "Cancelled":
        record.status = "Cancelled"
        record.cancellation_reason = payload.cancellation_reason

    else:
        record.status = payload.status

    db.commit()
    return ok(message="Status penggantian berhasil diperbarui")
