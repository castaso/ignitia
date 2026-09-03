"""Break (Istirahat) — single type per company config + session tracking."""

import json
from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..config import settings
from ..database import get_db
from ..dates import date_key, datetime_key
from ..deps import get_current_employee
from ..models import BreakSession, Company, CompanyBreakConfig, Employee
from ..schemas import BreakConfigIn, BreakSessionIn, break_config_json, break_session_json, fail, ok
from ..security import is_within_office, store_face_snapshot, validate_liveness_frames, verify_face

router = APIRouter()


def _get_company(db: Session) -> Company | None:
    return db.query(Company).first()


def _company_break_liveness(db: Session) -> bool:
    c = _get_company(db)
    if c is None:
        return settings.LIVENESS_REQUIRED
    if not getattr(c, "liveness_addon_active", 0):
        return False
    exp = getattr(c, "liveness_addon_expires_at", None)
    if exp is not None and datetime.now() > exp:
        return False
    return bool(getattr(c, "break_liveness_enabled", 0) or getattr(c, "liveness_addon_active", 0) == 0 and settings.LIVENESS_REQUIRED)


@router.get("/Break/config")
def get_break_config(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    cfg = db.query(CompanyBreakConfig).first()
    if cfg is None:
        # return defaults
        return ok(data={
            "duration_minutes": settings.BREAK_DEFAULT_DURATION,
            "allowed_start": settings.BREAK_DEFAULT_START,
            "allowed_end": settings.BREAK_DEFAULT_END,
            "is_paid": 0,
            "liveness_required": 0,
            "is_active": 1,
        })
    return ok(data=break_config_json(cfg))


@router.put("/Break/config")
def upsert_break_config(payload: BreakConfigIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    cfg = db.query(CompanyBreakConfig).first()
    company = _get_company(db)
    cid = payload.company_id or (company.id if company else 1)
    if cfg is None:
        cfg = CompanyBreakConfig(
            company_id=cid,
            duration_minutes=payload.duration_minutes or settings.BREAK_DEFAULT_DURATION,
            allowed_start=payload.allowed_start or settings.BREAK_DEFAULT_START,
            allowed_end=payload.allowed_end or settings.BREAK_DEFAULT_END,
            is_paid=payload.is_paid or 0,
            liveness_required=payload.liveness_required or 0,
            is_active=payload.is_active if payload.is_active is not None else 1,
        )
        db.add(cfg)
    else:
        if payload.duration_minutes is not None:
            cfg.duration_minutes = payload.duration_minutes
        if payload.allowed_start is not None:
            cfg.allowed_start = payload.allowed_start
        if payload.allowed_end is not None:
            cfg.allowed_end = payload.allowed_end
        if payload.is_paid is not None:
            cfg.is_paid = payload.is_paid
        if payload.liveness_required is not None:
            cfg.liveness_required = payload.liveness_required
        if payload.is_active is not None:
            cfg.is_active = payload.is_active
    db.commit()
    db.refresh(cfg)
    return ok(data=break_config_json(cfg), message="Break config saved")


@router.post("/Break/start")
def break_start(payload: BreakSessionIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    employee_id = payload.employee_id or auth.id
    employee = db.get(Employee, employee_id)
    if employee is None:
        return fail("Employee not found")
    # geo check optional — reuse office
    if payload.latitude is not None and payload.longitude is not None:
        if not is_within_office(payload.latitude, payload.longitude):
            return fail(settings.MESSAGE_OUTSIDE_RANGE)
    # face verification if reference exists
    if payload.face_image:
        ok_face, err = verify_face(employee.reference_face, payload.face_image)
        if not ok_face:
            return fail(err)
    # liveness per-company + per-config
    cfg = db.query(CompanyBreakConfig).first()
    need_liveness = bool(cfg.liveness_required) if cfg else False
    # if company addon enabled, respect cfg; else if addon off, disable
    if not getattr(_get_company(db) or Company(), "liveness_addon_active", 0):
        need_liveness = False
    else:
        need_liveness = need_liveness and bool(getattr(_get_company(db), "break_liveness_enabled", 0) or getattr(_get_company(db), "liveness_addon_active", 0))
    # fallback to global if cfg absent
    if cfg is None:
        need_liveness = _company_break_liveness(db)
    ok_live, live_err = validate_liveness_frames(payload.liveness_frames, required=need_liveness, challenge_id=payload.challenge_id)
    if not ok_live:
        return fail(live_err)

    day = date_key(payload.date_time) or datetime.now().strftime("%Y-%m-%d")
    # prevent double in-progress
    existing = db.query(BreakSession).filter(BreakSession.employee_id == employee_id, BreakSession.date_time == day, BreakSession.status == "InProgress").first()
    if existing:
        return fail("Break already in progress for today")

    now_str = datetime_key(datetime.now())
    face_path = store_face_snapshot(payload.face_image, f"emp{employee_id}_{day}_break_start.jpg") if payload.face_image else None
    row = BreakSession(
        employee_id=employee_id,
        company_id=getattr(_get_company(db), "id", None),
        date_time=day,
        break_start=now_str,
        status="InProgress",
        latitude=payload.latitude,
        longitude=payload.longitude,
        start_address=payload.start_address,
        start_face=face_path,
    )
    db.add(row)
    db.commit()
    return ok(data=break_session_json(row), message="Break started")


@router.post("/Break/end")
def break_end(payload: BreakSessionIn, db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee)):
    employee_id = payload.employee_id or auth.id
    day = date_key(payload.date_time) or datetime.now().strftime("%Y-%m-%d")
    row = db.query(BreakSession).filter(BreakSession.employee_id == employee_id, BreakSession.date_time == day, BreakSession.status == "InProgress").order_by(BreakSession.id.desc()).first()
    if row is None:
        return fail("No active break found")
    now = datetime.now()
    now_str = datetime_key(now)
    try:
        start_dt = datetime.strptime(row.break_start, "%Y-%m-%dT%H:%M:%S")
        duration = int((now - start_dt).total_seconds() // 60)
    except Exception:
        duration = 0
    # liveness on end as well if required
    cfg = db.query(CompanyBreakConfig).first()
    need_liveness = bool(cfg.liveness_required) if cfg else _company_break_liveness(db)
    if not getattr(_get_company(db) or Company(), "liveness_addon_active", 0):
        need_liveness = False
    ok_live, live_err = validate_liveness_frames(payload.liveness_frames, required=need_liveness, challenge_id=payload.challenge_id)
    if not ok_live:
        return fail(live_err)
    face_path = store_face_snapshot(payload.face_image, f"emp{employee_id}_{day}_break_end.jpg") if payload.face_image else None
    row.break_end = now_str
    row.duration_minutes = duration
    row.end_latitude = payload.end_latitude or payload.latitude
    row.end_longitude = payload.end_longitude or payload.longitude
    row.end_address = payload.end_address or payload.start_address
    row.end_face = face_path
    row.status = "Completed"
    db.commit()
    return ok(data=break_session_json(row), message="Break ended")


@router.get("/Break/sessions")
def list_sessions(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), employee_id: int = Query(0), startDate: str = Query(""), endDate: str = Query("")):
    eid = employee_id or auth.id
    q = db.query(BreakSession).filter(BreakSession.employee_id == eid)
    s = date_key(startDate)
    e = date_key(endDate)
    if s:
        q = q.filter(BreakSession.date_time >= s)
    if e:
        q = q.filter(BreakSession.date_time <= e)
    rows = q.order_by(BreakSession.date_time.desc()).all()
    return ok(data=[break_session_json(r) for r in rows])
