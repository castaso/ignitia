"""Timesheet — daily aggregation, weekly approval, export."""

import csv
import io
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, Query
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from ..database import get_db
from ..dates import date_key
from ..deps import get_current_employee
from ..models import Attendance, BreakSession, Employee, TimesheetEntry
from ..schemas import TimesheetIn, fail, ok, timesheet_json

router = APIRouter()


def _calc_work_minutes(check_in: str | None, check_out: str | None, break_minutes: int) -> tuple[int, int, int]:
    try:
        if not check_in or not check_out:
            return 0, 0, 0
        ci = datetime.strptime(check_in, "%Y-%m-%dT%H:%M:%S")
        co = datetime.strptime(check_out, "%Y-%m-%dT%H:%M:%S")
        total = int((co - ci).total_seconds() // 60)
        work = max(0, total - (break_minutes or 0))
        # overtime: beyond 8h (480m) example
        overtime = max(0, work - 480)
        return work, overtime, total
    except Exception:
        return 0, 0, 0


@router.get("/Timesheet")
def list_timesheet(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), employee_id: int = Query(0), startDate: str = Query(""), endDate: str = Query("")):
    eid = employee_id or auth.id
    q = db.query(TimesheetEntry).filter(TimesheetEntry.employee_id == eid)
    s = date_key(startDate)
    e = date_key(endDate)
    if s:
        q = q.filter(TimesheetEntry.date >= s)
    if e:
        q = q.filter(TimesheetEntry.date <= e)
    rows = q.order_by(TimesheetEntry.date.desc()).all()
    return ok(data=[timesheet_json(r) for r in rows])


@router.post("/Timesheet/generate")
def generate_timesheet(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), employee_id: int = Query(0), startDate: str = Query(""), endDate: str = Query("")):
    """Generate/update TimesheetEntry from Attendance+Break for range."""
    eid = employee_id or auth.id
    s = date_key(startDate)
    e = date_key(endDate) or datetime.now().strftime("%Y-%m-%d")
    if not s:
        return fail("startDate is required (yyyy-MM-dd)")
    start_dt = datetime.strptime(s, "%Y-%m-%d")
    end_dt = datetime.strptime(e, "%Y-%m-%d")
    cursor = start_dt
    created = 0
    while cursor <= end_dt:
        day = cursor.strftime("%Y-%m-%d")
        att = db.query(Attendance).filter(Attendance.employee_id == eid, Attendance.date_time == day).first()
        breaks = db.query(BreakSession).filter(BreakSession.employee_id == eid, BreakSession.date_time == day).all()
        break_mins = sum(b.duration_minutes or 0 for b in breaks if b.duration_minutes)
        check_in = att.check_in if att else None
        check_out = att.check_out if att else None
        late = att.late_duration if att and att.late_duration else 0
        work, overtime, _ = _calc_work_minutes(check_in, check_out, break_mins)
        existing = db.query(TimesheetEntry).filter(TimesheetEntry.employee_id == eid, TimesheetEntry.date == day).first()
        if existing:
            existing.check_in = check_in
            existing.check_out = check_out
            existing.break_minutes = break_mins
            existing.work_minutes = work
            existing.overtime_minutes = overtime
            existing.late_minutes = late
            if att and att.check_in:
                existing.shift_id = None
        else:
            row = TimesheetEntry(
                employee_id=eid,
                date=day,
                check_in=check_in,
                check_out=check_out,
                break_minutes=break_mins,
                work_minutes=work,
                overtime_minutes=overtime,
                late_minutes=late,
                status="Draft",
            )
            db.add(row)
            created += 1
        cursor += timedelta(days=1)
    db.commit()
    return ok(message=f"Timesheet generated for {s}..{e} ({created} new)")


@router.post("/Timesheet/submit")
def submit_timesheet(payload: TimesheetIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    # submit range: mark Draft → Submitted for employee
    eid = payload.employee_id or auth.id
    day = date_key(payload.date)
    if not day:
        return fail("date is required")
    row = db.query(TimesheetEntry).filter(TimesheetEntry.employee_id == eid, TimesheetEntry.date == day).first()
    if row is None:
        return fail("Timesheet entry not found, generate first")
    row.status = "Submitted"
    db.commit()
    return ok(message="Timesheet submitted")


@router.post("/Timesheet/approve")
def approve_timesheet(payload: TimesheetIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    row = db.get(TimesheetEntry, payload.id)
    if row is None and payload.date:
        day = date_key(payload.date)
        eid = payload.employee_id or auth.id
        row = db.query(TimesheetEntry).filter(TimesheetEntry.employee_id == eid, TimesheetEntry.date == day).first()
    if row is None:
        return fail("Timesheet entry not found")
    if payload.status == "Approved":
        row.status = "Approved"
        row.approved_by = auth.id
        row.rejection_reason = None
    elif payload.status == "Rejected":
        row.status = "Rejected"
        row.rejection_reason = payload.rejection_reason
    else:
        return fail("status must be Approved or Rejected")
    db.commit()
    return ok(data=timesheet_json(row), message=f"Timesheet {row.status}")


@router.get("/Timesheet/export")
def export_timesheet(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), employee_id: int = Query(0), startDate: str = Query(""), endDate: str = Query(""), format: str = Query("csv")):
    eid = employee_id or auth.id
    q = db.query(TimesheetEntry).filter(TimesheetEntry.employee_id == eid)
    s = date_key(startDate)
    e = date_key(endDate)
    if s:
        q = q.filter(TimesheetEntry.date >= s)
    if e:
        q = q.filter(TimesheetEntry.date <= e)
    rows = q.order_by(TimesheetEntry.date).all()
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["date", "check_in", "check_out", "break_minutes", "work_minutes", "overtime_minutes", "late_minutes", "status"])
    for r in rows:
        writer.writerow([r.date, r.check_in, r.check_out, r.break_minutes, r.work_minutes, r.overtime_minutes, r.late_minutes, r.status])
    output.seek(0)
    headers = {"Content-Disposition": f"attachment; filename=timesheet_{eid}_{s}_{e}.csv"}
    return StreamingResponse(iter([output.getvalue()]), media_type="text/csv", headers=headers)
