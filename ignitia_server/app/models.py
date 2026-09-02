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
