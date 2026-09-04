"""Pydantic request schemas and response-builder helpers matching the wire
contract of the Flutter client.

Response envelope used everywhere (unless noted):

    {"isSuccess": bool, "message": str, "data": <object|list|null>}
"""

from typing import Any, List, Optional

from pydantic import BaseModel, ConfigDict

# --- requests -----------------------------------------------------------


class LoginRequest(BaseModel):
    email: str
    password: str

    model_config = ConfigDict(extra="ignore")


class ChangePasswordRequest(BaseModel):
    email: str
    oldPassword: str
    newPassword: str

    model_config = ConfigDict(extra="ignore")


class AttendanceIn(BaseModel):
    """Body of check-in / check-out / edit-attendance requests.

    The client serialises the full AttendanceModel (toJson), so unknown
    fields are tolerated.
    """

    id: int = 0
    employee_id: Optional[int] = None
    employee_name: Optional[str] = None
    date_time: Optional[str] = None
    check_in: Optional[str] = None
    check_out: Optional[str] = None
    late_duration: Optional[int] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    overtimE_MINUTES: int = 0
    check_out_latitude: Optional[float] = None
    check_out_longitude: Optional[float] = None
    check_in_address: Optional[str] = None
    check_out_address: Optional[str] = None
    check_in_face: Optional[str] = None
    check_out_face: Optional[str] = None
    # Base64 JPEG frames captured live during the blink challenge. When absent
    # and LIVENESS_REQUIRED is true the request is rejected.
    liveness_frames: Optional[List[str]] = None
    # Single-use challenge id issued by /Attendance/livenessChallenge, tied to
    # the liveness_frames to prevent replay of a pre-recorded sequence.
    challenge_id: Optional[str] = None
    status: Optional[str] = None
    missinG_REASON: Optional[str] = None
    approval_status_id: Optional[int] = None
    approval_status: Optional[str] = None

    model_config = ConfigDict(extra="ignore")


class OvertimeIn(BaseModel):
    id: int = 0
    employeE_ID: Optional[int] = None
    overtimE_DATE: Optional[str] = None
    checK_IN: Optional[str] = None
    checK_OUT: Optional[str] = None
    overtimE_MINUTES: int = 0
    status: Optional[str] = None
    reason: Optional[str] = None
    supervisoR_ID: Optional[int] = None
    name: Optional[str] = None
    designation: Optional[str] = None

    model_config = ConfigDict(extra="ignore")


class UserLeaveIn(BaseModel):
    id: int = 0
    leave_id: Optional[int] = None
    employee_id: Optional[int] = None
    apply_date: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    reason: Optional[str] = None
    total_days: Optional[int] = None
    is_approved: Optional[int] = None

    model_config = ConfigDict(extra="ignore")


class ContactInfoIn(BaseModel):
    id: Optional[int] = None
    permanent_address: Optional[str] = None
    personal_email: Optional[str] = None
    second_cell_no: Optional[str] = None
    father_name: Optional[str] = None
    father_cell_no: Optional[str] = None
    mother_name: Optional[str] = None
    mother_cell_no: Optional[str] = None
    secondary_contact_name: Optional[str] = None
    secondary_contact_cell: Optional[str] = None

    model_config = ConfigDict(extra="ignore")


class ProfileIn(BaseModel):
    """Body of PUT /api/Employees -> {employeeInfo: {...}, contactInfo: {...}}"""

    employeeInfo: Optional[dict] = None
    contactInfo: Optional[ContactInfoIn] = None

    model_config = ConfigDict(extra="ignore")


class CompanyIn(BaseModel):
    """Body of POST / PUT /api/Companies.

    The client may serialise the full CompanyModel (toJson), so unknown
    fields are tolerated.
    """

    id: int = 0
    name: Optional[str] = None
    code: Optional[str] = None
    short_name: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None
    contact_person: Optional[str] = None
    status_id: Optional[int] = None
    liveness_addon_active: Optional[int] = None
    liveness_addon_expires_at: Optional[str] = None
    attendance_liveness_enabled: Optional[int] = None
    break_liveness_enabled: Optional[int] = None

    model_config = ConfigDict(extra="ignore")


class ShiftIn(BaseModel):
    id: int = 0
    shift_name: Optional[str] = None
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    description: Optional[str] = None
    status_id: Optional[int] = None
    model_config = ConfigDict(extra="ignore")


class WorkScheduleTemplateIn(BaseModel):
    id: int = 0
    company_id: Optional[int] = None
    name: Optional[str] = None
    weekly_pattern: Optional[dict] = None  # {"1":1,"2":1,...}
    effective_from: Optional[str] = None
    effective_to: Optional[str] = None
    is_active: Optional[int] = None
    model_config = ConfigDict(extra="ignore")


class EmployeeRosterIn(BaseModel):
    id: int = 0
    employee_id: Optional[int] = None
    template_id: Optional[int] = None
    override_pattern: Optional[dict] = None
    effective_from: Optional[str] = None
    effective_to: Optional[str] = None
    model_config = ConfigDict(extra="ignore")


class BreakConfigIn(BaseModel):
    company_id: Optional[int] = None
    duration_minutes: Optional[int] = None
    allowed_start: Optional[str] = None
    allowed_end: Optional[str] = None
    is_paid: Optional[int] = None
    liveness_required: Optional[int] = None
    is_active: Optional[int] = None
    model_config = ConfigDict(extra="ignore")


class BreakSessionIn(BaseModel):
    id: int = 0
    employee_id: Optional[int] = None
    date_time: Optional[str] = None
    break_start: Optional[str] = None
    break_end: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    end_latitude: Optional[float] = None
    end_longitude: Optional[float] = None
    start_address: Optional[str] = None
    end_address: Optional[str] = None
    face_image: Optional[str] = None
    liveness_frames: Optional[List[str]] = None
    challenge_id: Optional[str] = None
    model_config = ConfigDict(extra="ignore")


class TimesheetIn(BaseModel):
    id: int = 0
    employee_id: Optional[int] = None
    date: Optional[str] = None
    status: Optional[str] = None
    rejection_reason: Optional[str] = None
    model_config = ConfigDict(extra="ignore")


class CompanyAssetIn(BaseModel):
    id: int = 0
    asset_code: Optional[str] = None
    name: Optional[str] = None
    category: Optional[str] = None  # IT / Kendaraan / Furniture / Lainnya
    location: Optional[str] = None
    status: Optional[str] = None  # Active / Disposed / Maintenance / Lost / On Loan
    assigned_employee_id: Optional[int] = None
    purchase_date: Optional[str] = None
    value: Optional[float] = None
    description: Optional[str] = None
    company_id: Optional[int] = None
    model_config = ConfigDict(extra="ignore")


class AnnouncementIn(BaseModel):
    id: int = 0
    title: Optional[str] = None
    body: Optional[str] = None
    audience: Optional[str] = None  # ALL / DEPARTMENT / ROLE
    department_id: Optional[int] = None
    is_pinned: Optional[int] = None
    publish_at: Optional[str] = None
    expires_at: Optional[str] = None
    company_id: Optional[int] = None
    model_config = ConfigDict(extra="ignore")


class TaskIn(BaseModel):
    id: int = 0
    title: Optional[str] = None
    description: Optional[str] = None
    assigned_employee_id: Optional[int] = None
    assigned_by: Optional[int] = None
    due_date: Optional[str] = None
    status: Optional[str] = None  # Open / InProgress / Done
    model_config = ConfigDict(extra="ignore")


# --- responses ----------------------------------------------------------


def ok(data: Any = None, message: str = "Success") -> dict:
    return {"isSuccess": True, "message": message, "data": data}


def fail(message: str, data: Any = None) -> dict:
    return {"isSuccess": False, "message": message, "data": data}


def employee_json(emp, *, dept_name: str | None = None,
                  ptkp_code: str | None = None,
                  ptkp_annual_value: float | None = None,
                  last_transfer: dict | None = None) -> dict:
    d = {
        "id": emp.id,
        "name": emp.name,
        "designation": emp.designation or "",
        "cell_no": emp.cell_no,
        "email": emp.email,
        "address": emp.address,
        "nid": emp.nid,
        "type_id": emp.type_id,
        "employee_id": emp.employee_id,
        "supervisor_id": emp.supervisor_id,
        "status_id": emp.status_id,
        "department_id": getattr(emp, "department_id", None),
        "ptkp_status_id": getattr(emp, "ptkp_status_id", None),
        "joining_date": emp.joining_date.isoformat() if emp.joining_date else None,
        "permanent_date": emp.permanent_date.isoformat() if emp.permanent_date else None,
        "basic_salary": getattr(emp, "basic_salary", 0.0),
    }
    if dept_name is not None:
        d["department_name"] = dept_name
    if ptkp_code is not None:
        d["ptkp_status_code"] = ptkp_code
        d["ptkp_annual_value"] = ptkp_annual_value
    if last_transfer is not None:
        d.update(last_transfer)
    return d


def company_json(company) -> dict:
    return {
        "id": company.id,
        "name": company.name,
        "code": company.code,
        "short_name": company.short_name,
        "address": company.address,
        "phone": company.phone,
        "email": company.email,
        "website": company.website,
        "contact_person": company.contact_person,
        "status_id": company.status_id,
        "liveness_addon_active": getattr(company, "liveness_addon_active", 0) or 0,
        "liveness_addon_expires_at": company.liveness_addon_expires_at.isoformat() if getattr(company, "liveness_addon_expires_at", None) else None,
        "attendance_liveness_enabled": getattr(company, "attendance_liveness_enabled", 0) or 0,
        "break_liveness_enabled": getattr(company, "break_liveness_enabled", 0) or 0,
        "created_at": company.created_at.isoformat() if company.created_at else None,
    }


def shift_json(row) -> dict:
    return {
        "id": row.id,
        "shift_name": row.shift_name,
        "start_time": row.start_time,
        "end_time": row.end_time,
        "description": row.description or "",
        "status_id": row.status_id,
    }


def work_schedule_template_json(row) -> dict:
    import json as _json
    pattern = row.weekly_pattern
    try:
        pattern = _json.loads(pattern) if isinstance(pattern, str) else pattern
    except Exception:
        pattern = {}
    return {
        "id": row.id,
        "company_id": row.company_id,
        "name": row.name,
        "weekly_pattern": pattern,
        "effective_from": row.effective_from,
        "effective_to": row.effective_to,
        "is_active": row.is_active,
        "created_by": row.created_by,
    }


def break_config_json(row) -> dict:
    return {
        "id": row.id,
        "company_id": row.company_id,
        "duration_minutes": row.duration_minutes,
        "allowed_start": row.allowed_start,
        "allowed_end": row.allowed_end,
        "is_paid": row.is_paid,
        "liveness_required": row.liveness_required,
        "is_active": row.is_active,
    }


def break_session_json(row) -> dict:
    return {
        "id": row.id,
        "employee_id": row.employee_id,
        "company_id": row.company_id,
        "date_time": row.date_time,
        "break_start": row.break_start,
        "break_end": row.break_end,
        "duration_minutes": row.duration_minutes,
        "status": row.status,
        "latitude": row.latitude,
        "longitude": row.longitude,
        "end_latitude": row.end_latitude,
        "end_longitude": row.end_longitude,
        "start_address": row.start_address,
        "end_address": row.end_address,
    }


def timesheet_json(row) -> dict:
    return {
        "id": row.id,
        "employee_id": row.employee_id,
        "company_id": row.company_id,
        "date": row.date,
        "shift_id": row.shift_id,
        "check_in": row.check_in,
        "check_out": row.check_out,
        "break_minutes": row.break_minutes,
        "work_minutes": row.work_minutes,
        "overtime_minutes": row.overtime_minutes,
        "late_minutes": row.late_minutes,
        "status": row.status,
        "approved_by": row.approved_by,
        "rejection_reason": row.rejection_reason,
    }


def company_asset_json(row) -> dict:
    return {
        "id": row.id,
        "company_id": row.company_id,
        "asset_code": row.asset_code,
        "name": row.name,
        "category": row.category,
        "location": row.location,
        "status": row.status,
        "assigned_employee_id": row.assigned_employee_id,
        "purchase_date": row.purchase_date,
        "value": row.value,
        "description": row.description,
        "created_by": row.created_by,
        "created_at": row.created_at.isoformat() if row.created_at else None,
    }


def announcement_json(row) -> dict:
    return {
        "id": row.id,
        "company_id": row.company_id,
        "title": row.title,
        "body": row.body,
        "audience": row.audience,
        "department_id": row.department_id,
        "is_pinned": row.is_pinned,
        "publish_at": row.publish_at,
        "expires_at": row.expires_at,
        "created_by": row.created_by,
        "created_at": row.created_at.isoformat() if row.created_at else None,
    }


def notification_json(row) -> dict:
    return {
        "id": row.id,
        "recipient_employee_id": row.recipient_employee_id,
        "company_id": row.company_id,
        "type": row.type,
        "title": row.title,
        "body": row.body,
        "payload_json": row.payload_json,
        "is_read": row.is_read,
        "read_at": row.read_at.isoformat() if row.read_at else None,
        "created_at": row.created_at.isoformat() if row.created_at else None,
    }


def company_file_json(row) -> dict:
    return {
        "id": row.id,
        "company_id": row.company_id,
        "uploader_id": row.uploader_id,
        "file_name": row.file_name,
        "original_name": row.original_name,
        "mime": row.mime,
        "size_bytes": row.size_bytes,
        "storage_path": row.storage_path,
        "category": row.category,
        "description": row.description,
        "created_at": row.created_at.isoformat() if row.created_at else None,
    }


def audit_log_json(row) -> dict:
    return {
        "id": row.id,
        "action": row.action,
        "target_employee_id": row.target_employee_id,
        "performed_by": row.performed_by,
        "timestamp": row.timestamp.isoformat() if row.timestamp else None,
        "changed_fields": row.changed_fields,
    }


def contact_json(contact) -> dict:
    return {
        "id": contact.id,
        "permanent_address": contact.permanent_address,
        "personal_email": contact.personal_email,
        "second_cell_no": contact.second_cell_no,
        "father_name": contact.father_name,
        "father_cell_no": contact.father_cell_no,
        "mother_name": contact.mother_name,
        "mother_cell_no": contact.mother_cell_no,
        "secondary_contact_name": contact.secondary_contact_name,
        "secondary_contact_cell": contact.secondary_contact_cell,
    }


def attendance_json(row, *, include_faces: bool = False) -> dict:
    """Serialize an Attendance (or attendance-edit request) row to the exact
    JSON shape AttendanceModel.fromJson expects.

    The client parses ``date_time`` with a full datetime pattern, so a plain
    ``yyyy-MM-dd`` value is normalised to ``yyyy-MM-ddTHH:mm:ss`` (midnight).
    """
    approval_status_id = getattr(row, "approval_status_id", 0) or 0
    approval_status = getattr(row, "approval_status", None)
    date_time = row.date_time
    if date_time and len(date_time) == 10:
        date_time = f"{date_time}T00:00:00"
    result = {
        "id": row.id or 0,
        "employee_id": row.employee_id,
        "employee_name": row.employee_name,
        "date_time": date_time,
        "check_in": row.check_in,
        "check_out": row.check_out,
        "late_duration": row.late_duration,
        "latitude": row.latitude,
        "longitude": row.longitude,
        "overtimE_MINUTES": row.overtimE_MINUTES or 0,
        "check_out_latitude": row.check_out_latitude,
        "check_out_longitude": row.check_out_longitude,
        "check_in_address": row.check_in_address,
        "check_out_address": row.check_out_address,
        "status": row.status or "",
        "missinG_REASON": row.missinG_REASON,
        "approval_status_id": approval_status_id,
        "approval_status": approval_status,
    }
    # Face images are large base64 strings; only expose file paths when asked.
    result["check_in_face"] = row.check_in_face if include_faces else ""
    result["check_out_face"] = row.check_out_face if include_faces else ""
    return result


def leave_type_json(leave_type) -> dict:
    return {
        "id": leave_type.id,
        "leave_name": leave_type.leave_name,
        "leave_short_name": leave_type.leave_short_name,
        "leave_count": leave_type.leave_count,
    }


def user_leave_json(leave) -> dict:
    return {
        "id": leave.id,
        "leave_id": leave.leave_id,
        "employee_id": leave.employee_id,
        "apply_date": leave.apply_date,
        "start_date": leave.start_date,
        "end_date": leave.end_date,
        "reason": leave.reason,
        "total_days": leave.total_days,
        "is_approved": leave.is_approved,
    }


def overtime_json(row) -> dict:
    return {
        "id": row.id,
        "employeE_ID": row.employeE_ID,
        "overtimE_DATE": row.overtimE_DATE,
        "checK_IN": row.checK_IN,
        "checK_OUT": row.checK_OUT,
        "overtimE_MINUTES": row.overtimE_MINUTES or 0,
        "status": row.status or "",
        "reason": row.reason or "",
        "supervisoR_ID": row.supervisoR_ID,
        "name": row.name,
        "designation": row.designation,
    }


def task_json(row, *, assignee_name: str | None = None,
              created_by_name: str | None = None) -> dict:
    return {
        "id": row.id,
        "title": row.title,
        "description": row.description,
        "assigned_employee_id": row.assigned_employee_id,
        "assigned_by": row.assigned_by,
        "due_date": row.due_date,
        "status": row.status or "Open",
        "assignee_name": assignee_name,
        "created_by_name": created_by_name,
        "created_at": row.created_at.isoformat() if row.created_at else None,
        "updated_at": row.updated_at.isoformat() if row.updated_at else None,
    }
