"""In-app Notifications for announcement fan-out."""

from datetime import datetime
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee
from ..models import Notification, Employee
from ..schemas import fail, notification_json, ok

router = APIRouter()


@router.get("/Notifications")
def list_notifications(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), is_read: int = Query(-1)):
    q = db.query(Notification).filter(Notification.recipient_employee_id == auth.id)
    if is_read in (0, 1):
        q = q.filter(Notification.is_read == is_read)
    rows = q.order_by(Notification.created_at.desc()).all()
    return ok(data=[notification_json(r) for r in rows])


@router.post("/Notifications/{id}/read")
def mark_read(id: int, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    row = db.get(Notification, id)
    if row is None or row.recipient_employee_id != auth.id:
        return fail("Notification not found")
    row.is_read = 1
    row.read_at = datetime.now()
    db.commit()
    return ok(message="Marked as read")


@router.post("/Notifications/read-all")
def mark_all_read(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    rows = db.query(Notification).filter(Notification.recipient_employee_id == auth.id, Notification.is_read == 0).all()
    for r in rows:
        r.is_read = 1
        r.read_at = datetime.now()
    db.commit()
    return ok(message=f"{len(rows)} notifications marked as read")
