"""Announcements → fan-out to in-app Notifications (Talenta-like)."""

import json
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee, require_admin
from ..models import Announcement, Employee, Notification
from ..schemas import AnnouncementIn, announcement_json, fail, ok

router = APIRouter()


@router.get("/Announcements")
def list_announcements(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), company_id: int = Query(0)):
    q = db.query(Announcement)
    if company_id:
        q = q.filter(Announcement.company_id == company_id)
    rows = q.order_by(Announcement.is_pinned.desc(), Announcement.created_at.desc()).all()
    return ok(data=[announcement_json(r) for r in rows])


@router.post("/Announcements")
def add_announcement(payload: AnnouncementIn, db: Session = Depends(get_db), auth: Employee = Depends(require_admin)):
    title = (payload.title or "").strip()
    if not title:
        return fail("Title is required")
    row = Announcement(
        company_id=payload.company_id,
        title=title,
        body=payload.body or "",
        audience=payload.audience if payload.audience in ("ALL", "DEPARTMENT", "ROLE") else "ALL",
        department_id=payload.department_id,
        is_pinned=payload.is_pinned or 0,
        publish_at=payload.publish_at,
        expires_at=payload.expires_at,
        created_by=auth.id,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return ok(data=announcement_json(row), message="Announcement created")


@router.put("/Announcements")
def update_announcement(payload: AnnouncementIn, db: Session = Depends(get_db), auth: Employee = Depends(require_admin)):
    row = db.get(Announcement, payload.id)
    if row is None:
        return fail("Announcement not found")
    if payload.title is not None:
        row.title = payload.title
    if payload.body is not None:
        row.body = payload.body
    if payload.audience is not None:
        row.audience = payload.audience
    if payload.department_id is not None:
        row.department_id = payload.department_id
    if payload.is_pinned is not None:
        row.is_pinned = payload.is_pinned
    db.commit()
    return ok(data=announcement_json(row), message="Announcement updated")


@router.delete("/Announcements")
def delete_announcement(db: Session = Depends(get_db), auth: Employee = Depends(require_admin), id: int = Query(0)):
    row = db.get(Announcement, id)
    if row is None:
        return fail("Announcement not found")
    db.delete(row)
    db.commit()
    return ok(message="Announcement deleted")


@router.post("/Announcements/{id}/publish")
def publish_announcement(id: int, db: Session = Depends(get_db), auth: Employee = Depends(require_admin)):
    ann = db.get(Announcement, id)
    if ann is None:
        return fail("Announcement not found")
    # Resolve recipients
    q = db.query(Employee)
    if ann.audience == "DEPARTMENT" and ann.department_id:
        q = q.filter(Employee.department_id == ann.department_id)
    # ROLE not implemented → ALL
    recipients = q.all()
    count = 0
    for emp in recipients:
        notif = Notification(
            recipient_employee_id=emp.id,
            company_id=ann.company_id,
            type="announcement",
            title=ann.title,
            body=ann.body,
            payload_json=json.dumps({"announcement_id": ann.id}),
        )
        db.add(notif)
        count += 1
    db.commit()
    return ok(message=f"Published to {count} employees (in-app)")
