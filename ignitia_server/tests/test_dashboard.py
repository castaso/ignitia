"""Dashboard aggregation + tasks endpoint tests.

Uses the shared session DB from conftest (2 demo employees + leave types).
Assertions are membership/shape-based so they stay valid alongside data
created by other test files.
"""

from datetime import datetime, timedelta, timezone

from tests.conftest import auth

from app.database import SessionLocal
from app.models import Employee, LeaveType, UserLeave


def _today_s() -> str:
    return datetime.now(timezone.utc).replace(tzinfo=None).strftime("%Y-%m-%d")


def _in(days: int) -> str:
    return (datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(days=days)).strftime("%Y-%m-%d")


# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------


def test_summary_admin_only_and_shape(client, token, admin_token):
    assert client.get("/api/Dashboard/summary", headers=auth(token)).status_code == 403

    r = client.get("/api/Dashboard/summary", headers=auth(admin_token))
    assert r.status_code == 200
    body = r.json()
    assert body["isSuccess"] is True
    d = body["data"]
    for key in (
        "today",
        "total_employees",
        "present_today",
        "late_today",
        "absent_today",
        "on_leave_today",
        "pending_overtime",
        "pending_leave",
        "pending_attendance_edit",
        "upcoming_leaves_7d",
    ):
        assert key in d, f"missing key {key}"
    assert d["total_employees"] >= 2
    assert d["today"] == _today_s()
    for row in d["upcoming_leaves_7d"]:
        assert {"employee_id", "name", "leave_name", "start_date", "end_date"} <= set(row)


# ---------------------------------------------------------------------------
# Employee chart
# ---------------------------------------------------------------------------


def test_employee_chart_all_metrics(client, admin_token):
    for metric in (
        "employment_status",
        "length_of_service",
        "job_level",
        "gender_diversity",
    ):
        r = client.get(
            "/api/Dashboard/employeeChart",
            params={"metric": metric},
            headers=auth(admin_token),
        )
        assert r.status_code == 200
        body = r.json()
        assert body["isSuccess"] is True, body
        data = body["data"]
        assert isinstance(data, list) and data
        total = 0
        for row in data:
            assert set(row) == {"label", "count"}
            assert row["count"] > 0
            total += row["count"]
        assert total >= 2


def test_employee_chart_rejects_unknown_metric(client, admin_token):
    r = client.get(
        "/api/Dashboard/employeeChart",
        params={"metric": "bogus"},
        headers=auth(admin_token),
    )
    assert r.json()["isSuccess"] is False


def test_employee_chart_admin_only(client, token):
    assert (
        client.get(
            "/api/Dashboard/employeeChart",
            params={"metric": "job_level"},
            headers=auth(token),
        ).status_code
        == 403
    )


# ---------------------------------------------------------------------------
# Who's off
# ---------------------------------------------------------------------------


def test_who_is_off_lists_approved_leaves_in_window(client, admin_token):
    db = SessionLocal()
    try:
        emp = db.query(Employee).filter(Employee.email == "demo@ignitia.local").first()
        lt = db.query(LeaveType).first()
        emp_id, emp_name = emp.id, emp.name
        db.add(
            UserLeave(
                leave_id=lt.id,
                employee_id=emp_id,
                apply_date=_today_s(),
                start_date=_in(1),
                end_date=_in(3),
                reason="dashboard test",
                total_days=3,
                is_approved=1,
            )
        )
        db.commit()
    finally:
        db.close()

    r = client.get(
        "/api/Dashboard/whoIsOff",
        params={"days": 7},
        headers=auth(admin_token),
    )
    body = r.json()
    assert body["isSuccess"] is True
    row = next(
        (x for x in body["data"] if x["employee_id"] == emp_id), None
    )
    assert row is not None
    assert row["name"] == emp_name
    assert row["start_date"] <= _in(1)
    assert row["end_date"] >= _in(3)
    assert row["leave_name"]


def test_who_is_off_open_to_all_roles(client, token):
    assert (
        client.get("/api/Dashboard/whoIsOff", headers=auth(token)).status_code == 200
    )


# ---------------------------------------------------------------------------
# Contract & probation
# ---------------------------------------------------------------------------


def test_contract_probation_window_and_ordering(client, admin_token):
    db = SessionLocal()
    try:
        emp = db.query(Employee).filter(Employee.email == "demo@ignitia.local").first()
        emp_id = emp.id
        emp.contract_end_date = _in(10)
        db.commit()
    finally:
        db.close()

    r = client.get(
        "/api/Dashboard/contractProbation",
        params={"window_days": 30},
        headers=auth(admin_token),
    )
    body = r.json()
    assert body["isSuccess"] is True
    rows = body["data"]
    mine = [x for x in rows if x["employee_id"] == emp_id and x["type"] == "Contract"]
    assert mine, f"expected contract row for {emp_id} in {rows}"
    assert mine[0]["days_remaining"] == 10
    assert mine[0]["end_date"] == _in(10)
    days = [x["days_remaining"] for x in rows]
    assert days == sorted(days)


def test_contract_probation_excludes_outside_window(client, admin_token):
    db = SessionLocal()
    try:
        emp = db.query(Employee).filter(Employee.email == "demo@ignitia.local").first()
        emp_id = emp.id
        emp.contract_end_date = _in(200)
        db.commit()
    finally:
        db.close()

    r = client.get(
        "/api/Dashboard/contractProbation",
        params={"window_days": 30},
        headers=auth(admin_token),
    )
    rows = r.json()["data"]
    assert not any(
        x["employee_id"] == emp_id and x["type"] == "Contract" for x in rows
    )


# ---------------------------------------------------------------------------
# AI summary (rule-based)
# ---------------------------------------------------------------------------


def test_ai_summary_text(client, admin_token):
    r = client.get("/api/Dashboard/aiSummary", headers=auth(admin_token))
    body = r.json()
    assert body["isSuccess"] is True
    d = body["data"]
    assert "generated_at" in d
    assert "active employees" in d["text"]
    assert "Attendance today" in d["text"]


def test_ai_summary_admin_only(client, token):
    assert (
        client.get("/api/Dashboard/aiSummary", headers=auth(token)).status_code
        == 403
    )


# ---------------------------------------------------------------------------
# Tasks CRUD
# ---------------------------------------------------------------------------


def test_tasks_crud_lifecycle(client, token, admin_token):
    # Any authenticated user can list.
    r = client.get("/api/Tasks", headers=auth(token))
    assert r.status_code == 200
    assert r.json()["isSuccess"] is True

    # Create is admin-only; title is required.
    assert (
        client.post(
            "/api/Tasks", json={"title": "x"}, headers=auth(token)
        ).status_code
        == 403
    )
    r = client.post("/api/Tasks", json={"title": "   "}, headers=auth(admin_token))
    assert r.json()["isSuccess"] is False

    unique = f"Dashboard test task {int(datetime.now().timestamp())}"
    r = client.post(
        "/api/Tasks",
        json={
            "title": unique,
            "description": "created by dashboard test",
            "due_date": _today_s(),
        },
        headers=auth(admin_token),
    )
    assert r.json()["isSuccess"] is True
    created = r.json()["data"]
    tid = created["id"]
    assert created["title"] == unique
    assert created["status"] == "Open"
    assert created["created_by_name"]

    r = client.get("/api/Tasks", params={"status": "Open"}, headers=auth(token))
    assert any(t["id"] == tid for t in r.json()["data"])

    r = client.put(
        "/api/Tasks", json={"id": tid, "status": "Done"}, headers=auth(admin_token)
    )
    assert r.json()["data"]["status"] == "Done"

    r = client.put(
        "/api/Tasks", json={"id": 999999, "status": "Done"}, headers=auth(admin_token)
    )
    assert r.json()["isSuccess"] is False

    r = client.delete("/api/Tasks", params={"id": tid}, headers=auth(admin_token))
    assert r.json()["isSuccess"] is True

    r = client.delete("/api/Tasks", params={"id": tid}, headers=auth(admin_token))
    assert r.json()["isSuccess"] is False

    r = client.get("/api/Tasks", params={"status": "Done"}, headers=auth(token))
    assert not any(t["id"] == tid for t in r.json()["data"])
