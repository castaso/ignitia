"""Work Schedule — weekly roster template (Senin-Minggu) per company."""

import json

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee
from ..models import Employee, EmployeeRoster, Shift, WorkScheduleTemplate
from ..schemas import EmployeeRosterIn, WorkScheduleTemplateIn, fail, ok, work_schedule_template_json

router = APIRouter()


@router.get("/WorkSchedule/templates")
def list_templates(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    rows = db.query(WorkScheduleTemplate).order_by(WorkScheduleTemplate.id).all()
    return ok(data=[work_schedule_template_json(r) for r in rows])


@router.post("/WorkSchedule/templates")
def create_template(payload: WorkScheduleTemplateIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    if not payload.name or not payload.name.strip():
        return fail("Template name is required")
    pattern = payload.weekly_pattern or {}
    # Validate shift ids exist when provided
    for day, sid in pattern.items():
        if sid and not db.get(Shift, int(sid)):
            return fail(f"Shift id {sid} for day {day} not found")
    row = WorkScheduleTemplate(
        company_id=payload.company_id,
        name=payload.name.strip(),
        weekly_pattern=json.dumps(pattern),
        effective_from=payload.effective_from,
        effective_to=payload.effective_to,
        is_active=payload.is_active if payload.is_active is not None else 1,
        created_by=auth.id,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return ok(data=work_schedule_template_json(row), message="Template created")


@router.put("/WorkSchedule/templates")
def update_template(payload: WorkScheduleTemplateIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    row = db.get(WorkScheduleTemplate, payload.id)
    if row is None:
        return fail("Template not found")
    if payload.name is not None:
        row.name = payload.name
    if payload.weekly_pattern is not None:
        for day, sid in payload.weekly_pattern.items():
            if sid and not db.get(Shift, int(sid)):
                return fail(f"Shift id {sid} for day {day} not found")
        row.weekly_pattern = json.dumps(payload.weekly_pattern)
    if payload.effective_from is not None:
        row.effective_from = payload.effective_from
    if payload.effective_to is not None:
        row.effective_to = payload.effective_to
    if payload.is_active is not None:
        row.is_active = payload.is_active
    db.commit()
    return ok(data=work_schedule_template_json(row), message="Template updated")


@router.delete("/WorkSchedule/templates")
def delete_template(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), id: int = Query(0)):
    row = db.get(WorkScheduleTemplate, id)
    if row is None:
        return fail("Template not found")
    db.delete(row)
    db.commit()
    return ok(message="Template deleted")


# --- roster assignment ---


@router.get("/WorkSchedule/rosters")
def list_rosters(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), employee_id: int = Query(0)):
    q = db.query(EmployeeRoster)
    if employee_id:
        q = q.filter(EmployeeRoster.employee_id == employee_id)
    rows = q.order_by(EmployeeRoster.id).all()
    data = []
    for r in rows:
        override = None
        try:
            override = json.loads(r.override_pattern) if r.override_pattern else None
        except Exception:
            override = None
        data.append({
            "id": r.id,
            "employee_id": r.employee_id,
            "template_id": r.template_id,
            "override_pattern": override,
            "effective_from": r.effective_from,
            "effective_to": r.effective_to,
        })
    return ok(data=data)


@router.post("/WorkSchedule/rosters")
def assign_roster(payload: EmployeeRosterIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    if not payload.employee_id:
        return fail("employee_id is required")
    if payload.template_id and not db.get(WorkScheduleTemplate, payload.template_id):
        return fail("Template not found")
    row = EmployeeRoster(
        employee_id=payload.employee_id,
        template_id=payload.template_id,
        override_pattern=json.dumps(payload.override_pattern) if payload.override_pattern else None,
        effective_from=payload.effective_from,
        effective_to=payload.effective_to,
        created_by=auth.id,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return ok(message="Roster assigned")


@router.post("/WorkSchedule/rosters/bulk")
def bulk_assign(payload: dict, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    """Bulk: {template_id, employee_ids:[], effective_from, effective_to}"""
    template_id = payload.get("template_id")
    employee_ids = payload.get("employee_ids") or []
    if not template_id or not employee_ids:
        return fail("template_id and employee_ids are required")
    if not db.get(WorkScheduleTemplate, int(template_id)):
        return fail("Template not found")
    for eid in employee_ids:
        row = EmployeeRoster(
            employee_id=int(eid),
            template_id=int(template_id),
            effective_from=payload.get("effective_from"),
            effective_to=payload.get("effective_to"),
            created_by=auth.id,
        )
        db.add(row)
    db.commit()
    return ok(message=f"Roster assigned to {len(employee_ids)} employees")
