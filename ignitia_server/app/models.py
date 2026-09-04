"""SQLAlchemy ORM models. Column names follow the wire contract used by the
Flutter client (note the odd casing of missinG_REASON / overtimE_MINUTES /
employeE_ID / overtimE_DATE / checK_IN / checK_OUT / supervisoR_ID)."""

from datetime import datetime, timezone

from sqlalchemy import (
    Column,
    DateTime,
    Float,
    Integer,
    String,
    Text,
    UniqueConstraint,
)

from .database import Base

_now = lambda: datetime.now(timezone.utc).replace(tzinfo=None)  # noqa: E731


class Company(Base):
    __tablename__ = "companies"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), index=True)
    code = Column(String(50), unique=True, index=True, nullable=True)
    short_name = Column(String(100), nullable=True)
    address = Column(String(500), nullable=True)
    phone = Column(String(50), nullable=True)
    email = Column(String(200), nullable=True)
    website = Column(String(200), nullable=True)
    contact_person = Column(String(200), nullable=True)
    status_id = Column(Integer, default=1)  # 1 = active
    # Liveness add-on per company (billing)
    liveness_addon_active = Column(Integer, default=0)  # 0=off, 1=on
    liveness_addon_expires_at = Column(DateTime, nullable=True)
    # Time Management toggles (per company)
    attendance_liveness_enabled = Column(Integer, default=0)
    break_liveness_enabled = Column(Integer, default=0)
    created_at = Column(DateTime, default=_now)


class Department(Base):
    __tablename__ = "departments"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), unique=True, nullable=False)
    code = Column(String(50), unique=True, nullable=True)
    is_active = Column(Integer, default=1)  # 1 = active


class PtkpStatus(Base):
    __tablename__ = "ptkp_statuses"

    id = Column(Integer, primary_key=True)
    code = Column(String(10), unique=True)          # "TK/0", "K/3", etc.
    description = Column(String(200))
    annual_value = Column(Float)                    # in Rupiah


class Employee(Base):
    __tablename__ = "employees"

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(String(50), unique=True, index=True)
    name = Column(String(200))
    designation = Column(String(200), default="")
    cell_no = Column(String(50), nullable=True)
    email = Column(String(200), unique=True, index=True)
    address = Column(String(500), nullable=True)
    nid = Column(String(50), nullable=True)
    type_id = Column(Integer, default=2)  # 1 = admin, 2 = employee
    supervisor_id = Column(Integer, default=0)
    status_id = Column(Integer, default=1)  # 1 = active, 2 = inactive
    joining_date = Column(DateTime, nullable=True)
    permanent_date = Column(DateTime, nullable=True)

    # --- new HR fields (nullable for backward compat with existing rows) ---
    department_id = Column(Integer, nullable=True)   # FK → departments.id
    ptkp_status_id = Column(Integer, nullable=True)  # FK → ptkp_statuses.id
    deactivate_date = Column(String(25), nullable=True)
    deactivate_reason = Column(String(500), nullable=True)

    # --- security (server side only, never exposed) ---
    password_hash = Column(String(500), default="")
    # Registered reference photo (base64 JPEG) used for face verification.
    reference_face = Column(Text, nullable=True)

    # --- payroll (used to build the payslip) ---
    basic_salary = Column(Float, default=0.0)

    # --- dashboard chart dimensions (nullable for backward compat) ---
    gender = Column(String(10), nullable=True)  # Male / Female
    job_level = Column(String(100), nullable=True)  # Staff / Supervisor / Manager / Director
    employment_status = Column(String(50), nullable=True)  # Full-time / Contract / Intern
    contract_end_date = Column(String(25), nullable=True)  # yyyy-MM-dd


class EmployeeContactInfo(Base):
    __tablename__ = "employee_contact_info"

    id = Column(Integer, primary_key=True)  # == employees.id
    permanent_address = Column(String(500), nullable=True)
    personal_email = Column(String(200), nullable=True)
    second_cell_no = Column(String(50), nullable=True)
    father_name = Column(String(200), nullable=True)
    father_cell_no = Column(String(50), nullable=True)
    mother_name = Column(String(200), nullable=True)
    mother_cell_no = Column(String(50), nullable=True)
    secondary_contact_name = Column(String(200), nullable=True)
    secondary_contact_cell = Column(String(50), nullable=True)


class Attendance(Base):
    __tablename__ = "attendance"

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, index=True)
    employee_name = Column(String(200), default="")
    date_time = Column(String(20), index=True)  # yyyy-MM-dd (the working day)
    check_in = Column(String(25), nullable=True)  # yyyy-MM-ddTHH:mm:ss
    check_out = Column(String(25), nullable=True)  # yyyy-MM-ddTHH:mm:ss
    overtimE_MINUTES = Column(Integer, default=0)
    late_duration = Column(Integer, default=0)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    check_out_latitude = Column(Float, nullable=True)
    check_out_longitude = Column(Float, nullable=True)
    check_in_address = Column(String(500), nullable=True)
    check_out_address = Column(String(500), nullable=True)
    # Stored base64 is decoded to a file; the column keeps the file path.
    check_in_face = Column(String(500), nullable=True)
    check_out_face = Column(String(500), nullable=True)
    missinG_REASON = Column(String(1000), nullable=True)
    status = Column(String(50), default="Present")
    # Approval fields are used on the attendance-edit request list.
    approval_status_id = Column(Integer, default=0)
    approval_status = Column(String(50), nullable=True)


class AttendanceEditRequest(Base):
    __tablename__ = "attendance_edit_requests"

    id = Column(Integer, primary_key=True, index=True)
    attendance_id = Column(Integer, index=True)  # original attendance row id
    employee_id = Column(Integer, index=True)
    employee_name = Column(String(200), default="")
    date_time = Column(String(20), index=True)
    # Full proposed attendance JSON payload (as sent by the client).
    payload = Column(Text)
    approval_status_id = Column(Integer, default=1)  # 1 Pending
    approval_status = Column(String(50), default="Pending")
    rejection_reason = Column(String(1000), nullable=True)
    approved_by = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=_now)


class Overtime(Base):
    __tablename__ = "overtime"

    id = Column(Integer, primary_key=True, index=True)
    employeE_ID = Column(Integer, index=True)
    overtimE_DATE = Column(String(25), nullable=True)
    checK_IN = Column(String(25), nullable=True)
    checK_OUT = Column(String(25), nullable=True)
    overtimE_MINUTES = Column(Integer, default=0)
    status = Column(String(50), default="Pending")
    reason = Column(String(1000), default="")
    supervisoR_ID = Column(Integer, nullable=True)
    name = Column(String(200), nullable=True)
    designation = Column(String(200), nullable=True)


class LeaveType(Base):
    __tablename__ = "leave_types"

    id = Column(Integer, primary_key=True)
    leave_name = Column(String(200))
    leave_short_name = Column(String(50))
    leave_count = Column(Integer, default=0)


class UserLeave(Base):
    __tablename__ = "user_leaves"

    id = Column(Integer, primary_key=True, index=True)
    leave_id = Column(Integer, index=True)
    employee_id = Column(Integer, index=True)
    apply_date = Column(String(25))
    start_date = Column(String(25))
    end_date = Column(String(25))
    reason = Column(String(1000), default="")
    total_days = Column(Integer, default=0)
    is_approved = Column(Integer, default=0)


class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(200), index=True)
    token_hash = Column(String(200), unique=True)
    expires_at = Column(DateTime)
    used = Column(Integer, default=0)
    created_at = Column(DateTime, default=_now)


# ---------------------------------------------------------------------------
# Employee Management — new models
# ---------------------------------------------------------------------------


class EmployeeTransfer(Base):
    __tablename__ = "employee_transfers"

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, index=True)
    from_department_id = Column(Integer, nullable=True)
    to_department_id = Column(Integer, nullable=True)
    from_designation = Column(String(200), nullable=True)
    to_designation = Column(String(200), nullable=True)
    effective_date = Column(String(25))
    reason = Column(String(1000), nullable=True)
    created_by = Column(Integer)
    created_at = Column(DateTime, default=_now)


class PtkpStatusHistory(Base):
    __tablename__ = "ptkp_status_histories"

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, index=True)
    old_ptkp_status_id = Column(Integer, nullable=True)
    new_ptkp_status_id = Column(Integer)
    effective_date = Column(String(25))
    changed_by = Column(Integer)
    created_at = Column(DateTime, default=_now)


class ManpowerPlan(Base):
    __tablename__ = "manpower_plans"

    id = Column(Integer, primary_key=True, index=True)
    department_id = Column(Integer, index=True)
    designation = Column(String(200))
    plan_year = Column(Integer)
    plan_month = Column(Integer)
    target_headcount = Column(Integer)
    notes = Column(String(1000), nullable=True)
    created_by = Column(Integer)
    created_at = Column(DateTime, default=_now)

    __table_args__ = (
        UniqueConstraint("department_id", "designation", "plan_year", "plan_month",
                         name="uq_manpower_plan"),
    )


class ReplacementTracking(Base):
    __tablename__ = "replacement_trackings"

    id = Column(Integer, primary_key=True, index=True)
    departing_employee_id = Column(Integer, index=True)
    replacement_employee_id = Column(Integer, nullable=True)
    department_id = Column(Integer, index=True)
    designation = Column(String(200))
    departure_reason = Column(String(50))   # Resign / Long_Leave / Transfer
    effective_date = Column(String(25))
    expected_fill_date = Column(String(25))
    fill_date = Column(String(25), nullable=True)
    status = Column(String(20), default="Open")  # Open / Filled / Cancelled
    cancellation_reason = Column(String(1000), nullable=True)
    created_by = Column(Integer)
    created_at = Column(DateTime, default=_now)


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    action = Column(String(100))
    target_employee_id = Column(Integer, nullable=True)
    performed_by = Column(Integer)
    timestamp = Column(DateTime, default=_now)
    changed_fields = Column(Text, nullable=True)  # JSON string


# ---------------------------------------------------------------------------
# Time Management — Shift, Roster, Break, Timesheet
# ---------------------------------------------------------------------------


class Shift(Base):
    __tablename__ = "shifts"

    id = Column(Integer, primary_key=True, index=True)
    shift_name = Column(String(200), nullable=False)
    start_time = Column(String(5), nullable=False)  # HH:mm
    end_time = Column(String(5), nullable=False)  # HH:mm
    description = Column(String(500), default="")
    status_id = Column(Integer, default=1)  # 1 Active, 2 Inactive
    created_at = Column(DateTime, default=_now)


class WorkScheduleTemplate(Base):
    __tablename__ = "work_schedule_templates"

    id = Column(Integer, primary_key=True, index=True)
    company_id = Column(Integer, nullable=True)
    name = Column(String(200), nullable=False)
    # JSON: {"1": shift_id_monday, ..., "7": shift_id_sunday} (1=Mon..7=Sun)
    weekly_pattern = Column(Text, nullable=False)
    effective_from = Column(String(20), nullable=True)  # yyyy-MM-dd
    effective_to = Column(String(20), nullable=True)
    is_active = Column(Integer, default=1)
    created_by = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=_now)


class EmployeeRoster(Base):
    __tablename__ = "employee_rosters"

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, index=True, nullable=False)
    template_id = Column(Integer, index=True, nullable=True)
    # Per-employee override JSON same shape as weekly_pattern, nullable
    override_pattern = Column(Text, nullable=True)
    effective_from = Column(String(20), nullable=True)
    effective_to = Column(String(20), nullable=True)
    created_by = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=_now)


class CompanyBreakConfig(Base):
    __tablename__ = "company_break_configs"

    id = Column(Integer, primary_key=True, index=True)
    company_id = Column(Integer, unique=True, index=True)
    duration_minutes = Column(Integer, default=60)
    allowed_start = Column(String(5), default="12:00")
    allowed_end = Column(String(5), default="13:00")
    is_paid = Column(Integer, default=0)
    liveness_required = Column(Integer, default=0)
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, default=_now)
    updated_at = Column(DateTime, default=_now, onupdate=_now)


class BreakSession(Base):
    __tablename__ = "break_sessions"

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, index=True, nullable=False)
    company_id = Column(Integer, nullable=True)
    date_time = Column(String(20), index=True)  # yyyy-MM-dd
    break_start = Column(String(25), nullable=True)  # yyyy-MM-ddTHH:mm:ss
    break_end = Column(String(25), nullable=True)
    duration_minutes = Column(Integer, nullable=True)
    status = Column(String(20), default="InProgress")  # InProgress / Completed
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    end_latitude = Column(Float, nullable=True)
    end_longitude = Column(Float, nullable=True)
    start_address = Column(String(500), nullable=True)
    end_address = Column(String(500), nullable=True)
    start_face = Column(String(500), nullable=True)
    end_face = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=_now)


class TimesheetEntry(Base):
    __tablename__ = "timesheet_entries"

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, index=True, nullable=False)
    company_id = Column(Integer, nullable=True)
    date = Column(String(20), index=True)  # yyyy-MM-dd
    shift_id = Column(Integer, nullable=True)
    check_in = Column(String(25), nullable=True)
    check_out = Column(String(25), nullable=True)
    break_minutes = Column(Integer, default=0)
    work_minutes = Column(Integer, default=0)
    overtime_minutes = Column(Integer, default=0)
    late_minutes = Column(Integer, default=0)
    status = Column(String(20), default="Draft")  # Draft / Submitted / Approved / Rejected
    approved_by = Column(Integer, nullable=True)
    rejection_reason = Column(String(1000), nullable=True)
    created_at = Column(DateTime, default=_now)
    updated_at = Column(DateTime, default=_now, onupdate=_now)

    __table_args__ = (
        UniqueConstraint("employee_id", "date", name="uq_timesheet_employee_date"),
    )


# ---------------------------------------------------------------------------
# Company Administration Hub — Assets, Announcements, Notifications, Files
# ---------------------------------------------------------------------------


class CompanyAsset(Base):
    __tablename__ = "company_assets"

    id = Column(Integer, primary_key=True, index=True)
    company_id = Column(Integer, index=True, nullable=True)
    asset_code = Column(String(50), unique=True, index=True)
    name = Column(String(200), nullable=False)
    category = Column(String(50), default="IT")  # IT / Kendaraan / Furniture / Lainnya
    location = Column(String(200), nullable=True)
    status = Column(String(30), default="Active")  # Active / Disposed / Maintenance / Lost / On Loan
    assigned_employee_id = Column(Integer, nullable=True)
    purchase_date = Column(String(20), nullable=True)  # yyyy-MM-dd
    value = Column(Float, default=0.0)
    description = Column(String(1000), nullable=True)
    created_by = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=_now)
    updated_at = Column(DateTime, default=_now, onupdate=_now)


class Announcement(Base):
    __tablename__ = "announcements"

    id = Column(Integer, primary_key=True, index=True)
    company_id = Column(Integer, index=True, nullable=True)
    title = Column(String(300), nullable=False)
    body = Column(Text, nullable=False)
    audience = Column(String(20), default="ALL")  # ALL / DEPARTMENT / ROLE
    department_id = Column(Integer, nullable=True)
    is_pinned = Column(Integer, default=0)
    publish_at = Column(String(25), nullable=True)
    expires_at = Column(String(25), nullable=True)
    created_by = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=_now)


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    recipient_employee_id = Column(Integer, index=True, nullable=False)
    company_id = Column(Integer, nullable=True)
    type = Column(String(30), default="announcement")  # announcement / asset / system
    title = Column(String(300), nullable=False)
    body = Column(Text, nullable=True)
    payload_json = Column(Text, nullable=True)
    is_read = Column(Integer, default=0)
    read_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=_now)


class CompanyFile(Base):
    __tablename__ = "company_files"

    id = Column(Integer, primary_key=True, index=True)
    company_id = Column(Integer, index=True, nullable=True)
    uploader_id = Column(Integer, index=True, nullable=False)
    file_name = Column(String(300), nullable=False)  # stored filename
    original_name = Column(String(300), nullable=False)
    mime = Column(String(100), nullable=True)
    size_bytes = Column(Integer, default=0)
    storage_path = Column(String(500), nullable=False)
    category = Column(String(50), nullable=True)
    description = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=_now)


# ---------------------------------------------------------------------------
# Dashboard — Tasks
# ---------------------------------------------------------------------------


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(300), nullable=False)
    description = Column(Text, nullable=True)
    assigned_employee_id = Column(Integer, index=True, nullable=True)  # FK → employees.id
    assigned_by = Column(Integer, nullable=True)  # employees.id of the creator
    due_date = Column(String(25), nullable=True)  # yyyy-MM-dd
    status = Column(String(20), default="Open")  # Open / InProgress / Done
    created_at = Column(DateTime, default=_now)
    updated_at = Column(DateTime, default=_now, onupdate=_now)
