"""Manpower Planning endpoints.

Wire contract:
  POST /api/ManpowerPlans                -> create or update (upsert) plan (admin)
  GET  /api/ManpowerPlans                -> list with filters
  GET  /api/ManpowerPlans/summary        -> target vs actual headcount comparison
"""

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee, require_admin
from ..models import Department, Employee, ManpowerPlan
from ..schemas import fail, ok

router = APIRouter()


class ManpowerPlanIn(BaseModel):
    department_id: int
    designation: str
    plan_year: int
    plan_month: int
    target_headcount: int
    notes: str | None = None

    model_config = ConfigDict(extra="ignore")


def _plan_json(p: ManpowerPlan) -> dict:
    return {
        "id": p.id,
        "department_id": p.department_id,
        "designation": p.designation,
        "plan_year": p.plan_year,
        "plan_month": p.plan_month,
        "target_headcount": p.target_headcount,
        "notes": p.notes,
        "created_by": p.created_by,
        "created_at": p.created_at.isoformat() if p.created_at else None,
    }


@router.post("/ManpowerPlans")
def upsert_manpower_plan(
    payload: ManpowerPlanIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    if payload.target_headcount < 1:
        return fail("Target headcount harus minimal 1")

    existing = (
        db.query(ManpowerPlan)
        .filter(
            ManpowerPlan.department_id == payload.department_id,
            ManpowerPlan.designation == payload.designation,
            ManpowerPlan.plan_year == payload.plan_year,
            ManpowerPlan.plan_month == payload.plan_month,
        )
        .first()
    )
    if existing:
        existing.target_headcount = payload.target_headcount
        existing.notes = payload.notes
        db.commit()
        return ok(message="Rencana headcount berhasil diperbarui")

    plan = ManpowerPlan(
        department_id=payload.department_id,
        designation=payload.designation,
        plan_year=payload.plan_year,
        plan_month=payload.plan_month,
        target_headcount=payload.target_headcount,
        notes=payload.notes,
        created_by=auth.id,
    )
    db.add(plan)
    db.commit()
    return ok(message="Rencana headcount berhasil dibuat")


@router.get("/ManpowerPlans/summary")
def manpower_summary(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
    year: int = Query(0),
    month: int = Query(0),
    department_id: int = Query(0),
):
    query = db.query(ManpowerPlan)
    if year:
        query = query.filter(ManpowerPlan.plan_year == year)
    if month:
        query = query.filter(ManpowerPlan.plan_month == month)
    if department_id:
        query = query.filter(ManpowerPlan.department_id == department_id)
    plans = query.all()

    result = []
    for p in plans:
        dept = db.get(Department, p.department_id)
        actual = (
            db.query(Employee)
            .filter(
                Employee.department_id == p.department_id,
                Employee.designation == p.designation,
                Employee.status_id == 1,
            )
            .count()
        )
        result.append({
            "id": p.id,
            "department_id": p.department_id,
            "department_name": dept.name if dept else None,
            "designation": p.designation,
            "plan_year": p.plan_year,
            "plan_month": p.plan_month,
            "target_headcount": p.target_headcount,
            "actual_headcount": actual,
            "gap": actual - p.target_headcount,
            "notes": p.notes,
        })
    return ok(data=result)


@router.get("/ManpowerPlans")
def list_manpower_plans(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
    year: int = Query(0),
    month: int = Query(0),
    department_id: int = Query(0),
):
    query = db.query(ManpowerPlan)
    if year:
        query = query.filter(ManpowerPlan.plan_year == year)
    if month:
        query = query.filter(ManpowerPlan.plan_month == month)
    if department_id:
        query = query.filter(ManpowerPlan.department_id == department_id)
    plans = query.order_by(ManpowerPlan.plan_year.desc(), ManpowerPlan.plan_month.desc()).all()
    return ok(data=[_plan_json(p) for p in plans])
