"""Shift CRUD — re-added to match Flutter client contract ShiftModel."""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee
from ..models import Employee, Shift
from ..schemas import ShiftIn, fail, ok, shift_json

router = APIRouter()


@router.get("/Shift/getShiftList")
def get_shift_list(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    rows = db.query(Shift).order_by(Shift.id).all()
    return ok(data=[shift_json(r) for r in rows])


@router.post("/Shift")
def add_shift(payload: ShiftIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), employeeName: str = Query("")):
    if not payload.shift_name or not payload.shift_name.strip():
        return fail("Shift name is required")
    row = Shift(
        shift_name=payload.shift_name.strip(),
        start_time=payload.start_time or "09:00",
        end_time=payload.end_time or "18:00",
        description=payload.description or "",
        status_id=payload.status_id or 1,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return ok(data=shift_json(row), message="Shift created")


@router.put("/Shift")
def update_shift(payload: ShiftIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), employeeName: str = Query("")):
    row = db.get(Shift, payload.id)
    if row is None:
        return fail("Shift not found")
    if payload.shift_name is not None:
        row.shift_name = payload.shift_name
    if payload.start_time is not None:
        row.start_time = payload.start_time
    if payload.end_time is not None:
        row.end_time = payload.end_time
    if payload.description is not None:
        row.description = payload.description
    if payload.status_id is not None:
        row.status_id = payload.status_id
    db.commit()
    return ok(data=shift_json(row), message="Shift updated")


@router.delete("/Shift")
def delete_shift(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), id: int = Query(0), employeeName: str = Query("")):
    row = db.get(Shift, id)
    if row is None:
        return fail("Shift not found")
    db.delete(row)
    db.commit()
    return ok(message="Shift deleted")
