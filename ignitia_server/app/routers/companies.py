"""Company endpoints (maintain companies).

CRUD for company records, used by the admin dashboard:

  GET    /api/Companies         -> {isSuccess, message, data: [CompanyModel]}
  GET    /api/Companies?id=     -> {isSuccess, message, data: CompanyModel}
  POST   /api/Companies         body CompanyModel   create
  PUT    /api/Companies         body CompanyModel   update
  DELETE /api/Companies?id=     delete

The `code` column is unique, so duplicate codes are rejected.
"""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee
from ..models import Company, Employee
from ..schemas import (
    CompanyIn,
    company_json,
    fail,
    ok,
)

router = APIRouter()

_COMPANY_FIELDS = {
    "name", "code", "short_name", "address", "phone", "email",
    "website", "contact_person", "status_id",
}


@router.get("/Companies")
def get_company_list(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
    id: int = Query(0),
):
    if id:
        company = db.get(Company, id)
        if company is None:
            return fail("Company not found")
        return ok(data=company_json(company))
    companies = db.query(Company).order_by(Company.id).all()
    return ok(data=[company_json(c) for c in companies])


@router.post("/Companies")
def add_company(
    payload: CompanyIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    name = (payload.name or "").strip()
    if not name:
        return fail("Company name is required")
    code = (payload.code or "").strip()
    if code:
        other = db.query(Company).filter(Company.code == code).first()
        if other is not None:
            return fail("Company code is already in use")
    company = Company(
        name=name,
        code=code or None,
        short_name=payload.short_name,
        address=payload.address,
        phone=payload.phone,
        email=payload.email,
        website=payload.website,
        contact_person=payload.contact_person,
        status_id=payload.status_id if payload.status_id is not None else 1,
    )
    db.add(company)
    db.commit()
    return ok(data=company_json(company), message="Company created successfully")


@router.put("/Companies")
def update_company(
    payload: CompanyIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    company = db.get(Company, payload.id)
    if company is None:
        return fail("Company not found")
    for key, value in payload.model_dump(exclude_none=True).items():
        if key == "id" or key not in _COMPANY_FIELDS:
            continue
        if key == "name":
            name = str(value).strip()
            if not name:
                return fail("Company name cannot be empty")
            setattr(company, key, name)
        elif key == "code":
            code = str(value).strip()
            if code:
                other = (
                    db.query(Company)
                    .filter(Company.code == code, Company.id != payload.id)
                    .first()
                )
                if other is not None:
                    return fail("Company code is already in use")
                setattr(company, key, code)
            else:
                setattr(company, key, None)
        else:
            setattr(company, key, value)
    db.commit()
    return ok(data=company_json(company), message="Company updated successfully")


@router.delete("/Companies")
def delete_company(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
    id: int = Query(0),
):
    company = db.get(Company, id)
    if company is None:
        return fail("Company not found")
    db.delete(company)
    db.commit()
    return ok(message="Company deleted successfully")
