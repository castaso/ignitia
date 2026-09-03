"""Company Assets — all categories/statuses."""

import secrets
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee, require_admin
from ..models import CompanyAsset, Employee
from ..schemas import CompanyAssetIn, company_asset_json, fail, ok

router = APIRouter()

CATEGORIES = {"IT", "Kendaraan", "Furniture", "Lainnya"}
STATUSES = {"Active", "Disposed", "Maintenance", "Lost", "On Loan"}


@router.get("/CompanyAssets")
def list_assets(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), company_id: int = Query(0), category: str = Query(""), status: str = Query("")):
    q = db.query(CompanyAsset)
    if company_id:
        q = q.filter(CompanyAsset.company_id == company_id)
    if category and category in CATEGORIES:
        q = q.filter(CompanyAsset.category == category)
    if status and status in STATUSES:
        q = q.filter(CompanyAsset.status == status)
    rows = q.order_by(CompanyAsset.id.desc()).all()
    return ok(data=[company_asset_json(r) for r in rows])


@router.post("/CompanyAssets")
def add_asset(payload: CompanyAssetIn, db: Session = Depends(get_db), auth: Employee = Depends(require_admin)):
    name = (payload.name or "").strip()
    if not name:
        return fail("Asset name is required")
    cat = payload.category if payload.category in CATEGORIES else "Lainnya"
    st = payload.status if payload.status in STATUSES else "Active"
    code = (payload.asset_code or "").strip()
    if not code:
        code = f"AST-{secrets.token_hex(4).upper()}"
    else:
        if db.query(CompanyAsset).filter(CompanyAsset.asset_code == code).first():
            return fail("Asset code already exists")
    row = CompanyAsset(
        company_id=payload.company_id,
        asset_code=code,
        name=name,
        category=cat,
        location=payload.location,
        status=st,
        assigned_employee_id=payload.assigned_employee_id,
        purchase_date=payload.purchase_date,
        value=payload.value or 0.0,
        description=payload.description,
        created_by=auth.id,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return ok(data=company_asset_json(row), message="Asset created")


@router.put("/CompanyAssets")
def update_asset(payload: CompanyAssetIn, db: Session = Depends(get_db), auth: Employee = Depends(require_admin)):
    row = db.get(CompanyAsset, payload.id)
    if row is None:
        return fail("Asset not found")
    if payload.name is not None:
        row.name = payload.name
    if payload.category is not None and payload.category in CATEGORIES:
        row.category = payload.category
    if payload.status is not None and payload.status in STATUSES:
        row.status = payload.status
    if payload.location is not None:
        row.location = payload.location
    if payload.assigned_employee_id is not None:
        row.assigned_employee_id = payload.assigned_employee_id
    if payload.purchase_date is not None:
        row.purchase_date = payload.purchase_date
    if payload.value is not None:
        row.value = payload.value
    if payload.description is not None:
        row.description = payload.description
    db.commit()
    return ok(data=company_asset_json(row), message="Asset updated")


@router.delete("/CompanyAssets")
def delete_asset(db: Session = Depends(get_db), auth: Employee = Depends(require_admin), id: int = Query(0)):
    row = db.get(CompanyAsset, id)
    if row is None:
        return fail("Asset not found")
    db.delete(row)
    db.commit()
    return ok(message="Asset deleted")
