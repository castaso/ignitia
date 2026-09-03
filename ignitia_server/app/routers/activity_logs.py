"""Activity History — read-only view of AuditLog (Talenta-like)."""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee
from ..models import AuditLog, Employee
from ..schemas import audit_log_json, ok

router = APIRouter()


@router.get("/ActivityLogs")
def list_activity_logs(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
    employee_id: int = Query(0),
    action: str = Query(""),
    startDate: str = Query(""),
    endDate: str = Query(""),
):
    q = db.query(AuditLog)
    if employee_id:
        q = q.filter((AuditLog.target_employee_id == employee_id) | (AuditLog.performed_by == employee_id))
    if action:
        q = q.filter(AuditLog.action == action)
    # date filter on timestamp string compare (sqlite)
    if startDate:
        q = q.filter(AuditLog.timestamp >= startDate)
    if endDate:
        q = q.filter(AuditLog.timestamp <= endDate)
    rows = q.order_by(AuditLog.timestamp.desc()).limit(500).all()
    return ok(data=[audit_log_json(r) for r in rows])
