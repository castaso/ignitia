"""Dashboard aggregation endpoints for the Flutter web dashboard.

Wire contract (new client — clean snake_case, standard ok/fail envelope):
  GET    /api/Dashboard/summary
  GET    /api/Dashboard/employeeChart?metric=
  GET    /api/Dashboard/whoIsOff?days=7
  GET    /api/Dashboard/contractProbation?window_days=30
  GET    /api/Dashboard/aiSummary
  GET    /api/Tasks?status=&assigned_to=
  POST   /api/Tasks
  PUT    /api/Tasks
  DELETE /api/Tasks?id=
"""

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee, require_admin
from ..models import (
    Attendance,
    AttendanceEditRequest,
    Employee,
    LeaveType,
    Overtime,
    Task,
    UserLeave,
)
from ..schemas import TaskIn, fail, ok, task_json

router = APIRouter()

_PRESENT_STATUSES = ("Present", "Late")
_ABSENT_STATUSES = ("Absent", "Missing", "Missing Check-In", "Missing Check Out", "A")
_CHART_METRICS = (
    "employment_status",
    "length_of_service",
    "job_level",
    "gender_diversity",
)


def _today() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _date(s: str | None):
    """'yyyy-MM-dd' -> date (None-safe, tolerant of trailing time)."""
    if not s:
        return None
    try:
        return datetime.strptime(s[:10], "%Y-%m-%d").date()
    except ValueError:
        return None


def _employee_names(db: Session) -> dict[int, str]:
    return {e.id: e.name for e in db.query(Employee).all()}


# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------


def _summary_payload(db: Session) -> dict:
    today = _today()
    today_s = today.strftime("%Y-%m-%d")
    window_end_s = (today + timedelta(days=7)).strftime("%Y-%m-%d")

    active = (
        db.query(Employee).filter(Employee.status_id == 1).count()
    )
    today_rows = db.query(Attendance).filter(Attendance.date_time == today_s).all()
    on_leave_today = (
        db.query(UserLeave)
        .join(Employee, UserLeave.employee_id == Employee.id)
        .filter(
            UserLeave.is_approved == 1,
            Employee.status_id == 1,
            UserLeave.start_date <= today_s,
            UserLeave.end_date >= today_s,
        )
        .count()
    )

    upcoming = []
    seen = set()
    rows = (
        db.query(UserLeave, Employee, LeaveType)
        .join(Employee, UserLeave.employee_id == Employee.id)
        .join(LeaveType, UserLeave.leave_id == LeaveType.id)
        .filter(
            UserLeave.is_approved == 1,
            Employee.status_id == 1,
            UserLeave.end_date >= today_s,
            UserLeave.start_date <= window_end_s,
        )
        .order_by(UserLeave.start_date)
        .all()
    )
    for leave, emp, lt in rows:
        if emp.id in seen:
            continue
        seen.add(emp.id)
        upcoming.append(
            {
                "employee_id": emp.id,
                "name": emp.name,
                "designation": emp.designation or "",
                "leave_name": lt.leave_name,
                "start_date": leave.start_date,
                "end_date": leave.end_date,
            }
        )

    return {
        "today": today_s,
        "total_employees": active,
        "present_today": sum(1 for a in today_rows if a.status in _PRESENT_STATUSES),
        "late_today": sum(1 for a in today_rows if a.status == "Late"),
        "absent_today": sum(1 for a in today_rows if a.status in _ABSENT_STATUSES),
        "on_leave_today": on_leave_today,
        "pending_overtime": (
            db.query(Overtime).filter(Overtime.status == "Pending").count()
        ),
        "pending_leave": (
            db.query(UserLeave).filter(UserLeave.is_approved == 0).count()
        ),
        "pending_attendance_edit": (
            db.query(AttendanceEditRequest)
            .filter(AttendanceEditRequest.approval_status_id == 1)
            .count()
        ),
        "upcoming_leaves_7d": upcoming[:10],
    }


@router.get("/Dashboard/summary")
def dashboard_summary(
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    return ok(data=_summary_payload(db))


# ---------------------------------------------------------------------------
# Employee chart
# ---------------------------------------------------------------------------


def _tenure_bucket(joining: datetime | None) -> str:
    if joining is None:
        return "Unknown"
    years = (_today() - joining).days / 365.0
    if years < 1:
        return "< 1 year"
    if years < 3:
        return "1-3 years"
    if years < 5:
        return "3-5 years"
    if years < 10:
        return "5-10 years"
    return "> 10 years"


def _ordered_counts(raw: dict[str, int], preferred: list[str]) -> list[tuple[str, int]]:
    out = [(k, raw[k]) for k in preferred if k in raw]
    for k in sorted(raw):
        if k not in preferred:
            out.append((k, raw[k]))
    return out


@router.get("/Dashboard/employeeChart")
def employee_chart(
    metric: str = Query("employment_status"),
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    if metric not in _CHART_METRICS:
        return fail(
            f"Unknown metric '{metric}'. Use one of: {', '.join(_CHART_METRICS)}"
        )

    emps = db.query(Employee).filter(Employee.status_id == 1).all()
    counts: dict[str, int] = {}

    if metric == "employment_status":
        preferred = ["Full-time", "Contract", "Intern", "Unspecified"]
        for e in emps:
            key = e.employment_status or "Unspecified"
            counts[key] = counts.get(key, 0) + 1
    elif metric == "length_of_service":
        preferred = ["< 1 year", "1-3 years", "3-5 years", "5-10 years", "> 10 years", "Unknown"]
        for e in emps:
            key = _tenure_bucket(e.joining_date)
            counts[key] = counts.get(key, 0) + 1
    elif metric == "job_level":
        preferred = ["Staff", "Supervisor", "Manager", "Director", "Unspecified"]
        for e in emps:
            key = e.job_level or "Unspecified"
            counts[key] = counts.get(key, 0) + 1
    else:  # gender_diversity
        preferred = ["Male", "Female", "Unspecified"]
        for e in emps:
            key = e.gender or "Unspecified"
            counts[key] = counts.get(key, 0) + 1

    data = [
        {"label": label, "count": count}
        for label, count in _ordered_counts(counts, preferred)
    ]
    return ok(data=data)


# ---------------------------------------------------------------------------
# Who's off
# ---------------------------------------------------------------------------


@router.get("/Dashboard/whoIsOff")
def who_is_off(
    days: int = Query(7, ge=1, le=60),
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    today = _today()
    today_s = today.strftime("%Y-%m-%d")
    window_end_s = (today + timedelta(days=days)).strftime("%Y-%m-%d")

    rows = (
        db.query(UserLeave, Employee, LeaveType)
        .join(Employee, UserLeave.employee_id == Employee.id)
        .join(LeaveType, UserLeave.leave_id == LeaveType.id)
        .filter(
            UserLeave.is_approved == 1,
            Employee.status_id == 1,
            UserLeave.start_date <= window_end_s,
            UserLeave.end_date >= today_s,
        )
        .all()
    )

    by_emp: dict[int, dict] = {}
    for leave, emp, lt in rows:
        cur = by_emp.get(emp.id)
        if cur is None:
            by_emp[emp.id] = {
                "employee_id": emp.id,
                "name": emp.name,
                "designation": emp.designation or "",
                "leave_name": lt.leave_name,
                "start_date": leave.start_date,
                "end_date": leave.end_date,
            }
        else:
            if leave.start_date and (
                cur["start_date"] is None or leave.start_date < cur["start_date"]
            ):
                cur["start_date"] = leave.start_date
            if leave.end_date and (
                cur["end_date"] is None or leave.end_date > cur["end_date"]
            ):
                cur["end_date"] = leave.end_date

    data = sorted(
        by_emp.values(), key=lambda r: (r["start_date"] or "", r["name"] or "")
    )
    return ok(data=data)


# ---------------------------------------------------------------------------
# Contract & probation
# ---------------------------------------------------------------------------


def _contract_probation_rows(db: Session, window_days: int) -> list[dict]:
    today_d = _today().date()
    lo = today_d - timedelta(days=window_days)
    hi = today_d + timedelta(days=window_days)
    results = []
    for e in db.query(Employee).filter(Employee.status_id == 1).all():
        candidates: list[tuple[str, object]] = []
        if e.permanent_date is not None:
            end = (
                e.permanent_date.date()
                if isinstance(e.permanent_date, datetime)
                else _date(str(e.permanent_date))
            )
            if end is not None:
                candidates.append(("Probation", end))
        if e.contract_end_date:
            end = _date(e.contract_end_date)
            if end is not None:
                candidates.append(("Contract", end))
        for kind, end in candidates:
            if lo <= end <= hi:
                results.append(
                    {
                        "employee_id": e.id,
                        "name": e.name,
                        "designation": e.designation or "",
                        "type": kind,
                        "end_date": end.isoformat(),
                        "days_remaining": (end - today_d).days,
                    }
                )
    results.sort(key=lambda r: r["days_remaining"])
    return results


@router.get("/Dashboard/contractProbation")
def contract_probation(
    window_days: int = Query(30, ge=1, le=365),
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    return ok(data=_contract_probation_rows(db, window_days))


# ---------------------------------------------------------------------------
# AI summary (rule-based — no external LLM dependency)
# ---------------------------------------------------------------------------


@router.get("/Dashboard/aiSummary")
def ai_summary(
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    s = _summary_payload(db)
    text = [
        f"Here is a summary of your organization as of {s['today']}.",
        f"Headcount: {s['total_employees']} active employees.",
        (
            f"Attendance today: {s['present_today']} present, "
            f"{s['late_today']} late, {s['absent_today']} absent, "
            f"{s['on_leave_today']} on approved leave."
        ),
    ]
    pending = (
        s["pending_overtime"] + s["pending_leave"] + s["pending_attendance_edit"]
    )
    if pending:
        text.append(
            f"You have {pending} pending approval(s): "
            f"{s['pending_overtime']} overtime, {s['pending_leave']} leave, and "
            f"{s['pending_attendance_edit']} attendance-edit request(s)."
        )
    else:
        text.append("There are no pending approvals right now.")
    if s["upcoming_leaves_7d"]:
        names = ", ".join(u["name"] for u in s["upcoming_leaves_7d"][:5])
        extra = "" if len(s["upcoming_leaves_7d"]) <= 5 else " and others"
        text.append(f"Upcoming leaves in the next 7 days: {names}{extra}.")
    else:
        text.append("No approved leaves are scheduled in the next 7 days.")
    cp = _contract_probation_rows(db, 30)
    if cp:
        bits = [
            f"{r['name']} ({r['type'].lower()} ends {r['end_date']})"
            for r in cp[:5]
        ]
        text.append(f"Probation/contract review within 30 days: {', '.join(bits)}.")
    else:
        text.append("No probation or contract end dates fall within the next 30 days.")
    return ok(
        data={
            "text": "\n".join(text),
            "generated_at": _today().isoformat(),
        }
    )


# ---------------------------------------------------------------------------
# Tasks
# ---------------------------------------------------------------------------


@router.get("/Tasks")
def list_tasks(
    status: str | None = Query(None),
    assigned_to: int | None = Query(None),
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    q = db.query(Task)
    if status:
        q = q.filter(Task.status == status)
    if assigned_to:
        q = q.filter(Task.assigned_employee_id == assigned_to)
    tasks = q.order_by(Task.id.desc()).all()
    names = _employee_names(db)
    return ok(
        data=[
            task_json(
                t,
                assignee_name=names.get(t.assigned_employee_id),
                created_by_name=names.get(t.assigned_by),
            )
            for t in tasks
        ]
    )


@router.post("/Tasks")
def create_task(
    payload: TaskIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    if not payload.title or not payload.title.strip():
        return fail("Title is required")
    if payload.assigned_employee_id and (
        db.get(Employee, payload.assigned_employee_id) is None
    ):
        return fail("Assigned employee not found")
    task = Task(
        title=payload.title.strip(),
        description=payload.description,
        assigned_employee_id=payload.assigned_employee_id,
        assigned_by=auth.id,
        due_date=payload.due_date,
        status=payload.status or "Open",
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    names = _employee_names(db)
    return ok(
        data=task_json(
            task,
            assignee_name=names.get(task.assigned_employee_id),
            created_by_name=names.get(task.assigned_by),
        ),
        message="Task created",
    )


@router.put("/Tasks")
def update_task(
    payload: TaskIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    if payload.id <= 0:
        return fail("Task id is required")
    task = db.get(Task, payload.id)
    if task is None:
        return fail("Task not found")
    if payload.title is not None:
        if not payload.title.strip():
            return fail("Title cannot be empty")
        task.title = payload.title.strip()
    if payload.description is not None:
        task.description = payload.description
    if payload.assigned_employee_id is not None:
        if payload.assigned_employee_id and (
            db.get(Employee, payload.assigned_employee_id) is None
        ):
            return fail("Assigned employee not found")
        task.assigned_employee_id = payload.assigned_employee_id
    if payload.due_date is not None:
        task.due_date = payload.due_date
    if payload.status is not None:
        task.status = payload.status
    db.commit()
    db.refresh(task)
    names = _employee_names(db)
    return ok(
        data=task_json(
            task,
            assignee_name=names.get(task.assigned_employee_id),
            created_by_name=names.get(task.assigned_by),
        ),
        message="Task updated",
    )


@router.delete("/Tasks")
def delete_task(
    id: int = Query(...),
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    task = db.get(Task, id)
    if task is None:
        return fail("Task not found")
    db.delete(task)
    db.commit()
    return ok(data=None, message="Task deleted")
