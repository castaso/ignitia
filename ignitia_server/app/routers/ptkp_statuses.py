"""PTKP Status endpoints.

Wire contract:
  GET /api/PtkpStatuses   -> list all PTKP codes and their annual values
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee
from ..models import Employee, PtkpStatus
from ..schemas import ok

router = APIRouter()


def _ptkp_json(p: PtkpStatus) -> dict:
    return {
        "id": p.id,
        "code": p.code,
        "description": p.description,
        "annual_value": p.annual_value,
    }


@router.get("/PtkpStatuses")
def list_ptkp_statuses(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    statuses = db.query(PtkpStatus).order_by(PtkpStatus.id).all()
    return ok(data=[_ptkp_json(p) for p in statuses])
