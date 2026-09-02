"""Department endpoints.

Wire contract:
  GET    /api/Departments           -> list of all departments
  POST   /api/Departments           -> create (admin only)
  PUT    /api/Departments/{id}      -> update (admin only)
"""

from fastapi import APIRouter, Depends
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee, require_admin
from ..models import Department, Employee
from ..schemas import fail, ok

router = APIRouter()


class DepartmentIn(BaseModel):
    name: str
    code: str | None = None
    is_active: int = 1

    model_config = ConfigDict(extra="ignore")


def _dept_json(dept: Department) -> dict:
    return {
        "id": dept.id,
        "name": dept.name,
        "code": dept.code,
        "is_active": dept.is_active,
    }


@router.get("/Departments")
def list_departments(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    depts = db.query(Department).order_by(Department.id).all()
    return ok(data=[_dept_json(d) for d in depts])


@router.post("/Departments")
def create_department(
    payload: DepartmentIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    name = payload.name.strip()
    if not name:
        return fail("Nama departemen tidak boleh kosong")
    existing = db.query(Department).filter(Department.name == name).first()
    if existing:
        return fail("Nama departemen sudah digunakan")
    dept = Department(name=name, code=payload.code, is_active=payload.is_active)
    db.add(dept)
    db.commit()
    db.refresh(dept)
    return ok(data=_dept_json(dept), message="Departemen berhasil dibuat")


@router.put("/Departments/{id}")
def update_department(
    id: int,
    payload: DepartmentIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    dept = db.get(Department, id)
    if dept is None:
        return fail("Departemen tidak ditemukan")
    name = payload.name.strip()
    if not name:
        return fail("Nama departemen tidak boleh kosong")
    duplicate = (
        db.query(Department)
        .filter(Department.name == name, Department.id != id)
        .first()
    )
    if duplicate:
        return fail("Nama departemen sudah digunakan")
    dept.name = name
    if payload.code is not None:
        dept.code = payload.code
    dept.is_active = payload.is_active
    db.commit()
    return ok(message="Departemen berhasil diperbarui")
