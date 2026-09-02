"""Payroll endpoint.

Wire contract (Flutter client):
  GET /api/Payroll/GetPayslip?employee_id=&salary_year=&salary_month=
      -> {isSuccess, message, data: SalaryModel|null}

The payslip is derived from the employee record and that month's attendance
(see lib/models/payroll/salary_model.dart for the exact JSON keys).

PPh 21 calculation (UU HPP 2022 progressive tax brackets):
  PKP = max(0, annual_gross - ptkp_annual)
  Layer 1: PKP ≤  60_000_000 →  5%
  Layer 2: PKP ≤ 250_000_000 → 15%  (on the slice above layer 1)
  Layer 3: PKP ≤ 500_000_000 → 25%
  Layer 4: PKP >  500_000_000 → 30%
  AIT_monthly = annual_tax / 12
"""

import calendar
from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee
from ..models import Attendance, Employee, PtkpStatus, UserLeave
from ..schemas import fail, ok

router = APIRouter()

# ---------------------------------------------------------------------------
# PPh 21 progressive tax constants (UU HPP 2022)
# ---------------------------------------------------------------------------

_TAX_BRACKET_1 = 60_000_000.0    # 5%
_TAX_BRACKET_2 = 250_000_000.0   # 15%
_TAX_BRACKET_3 = 500_000_000.0   # 25%
# above 500 jt → 30%

_RATE_1 = 0.05
_RATE_2 = 0.15
_RATE_3 = 0.25
_RATE_4 = 0.30

# Default PTKP (TK/0) used when the employee has no PTKP status set.
_DEFAULT_PTKP = 54_000_000.0


def calculate_annual_pph21(pkp_annual: float) -> float:
    """Compute annual PPh 21 for the given PKP (Penghasilan Kena Pajak)."""
    if pkp_annual <= 0:
        return 0.0
    tax = 0.0
    # Layer 1
    l1 = min(pkp_annual, _TAX_BRACKET_1)
    tax += l1 * _RATE_1
    if pkp_annual <= _TAX_BRACKET_1:
        return tax
    # Layer 2
    l2 = min(pkp_annual - _TAX_BRACKET_1, _TAX_BRACKET_2 - _TAX_BRACKET_1)
    tax += l2 * _RATE_2
    if pkp_annual <= _TAX_BRACKET_2:
        return tax
    # Layer 3
    l3 = min(pkp_annual - _TAX_BRACKET_2, _TAX_BRACKET_3 - _TAX_BRACKET_2)
    tax += l3 * _RATE_3
    if pkp_annual <= _TAX_BRACKET_3:
        return tax
    # Layer 4
    l4 = pkp_annual - _TAX_BRACKET_3
    tax += l4 * _RATE_4
    return tax


def calculate_ait_monthly(gross_monthly: float, ptkp_annual: float) -> float:
    """Monthly AIT (PPh 21) for the given monthly gross and annual PTKP."""
    annual_gross = gross_monthly * 12
    pkp = max(0.0, annual_gross - ptkp_annual)
    annual_tax = calculate_annual_pph21(pkp)
    return annual_tax / 12


# ---------------------------------------------------------------------------

def _is_weekend(day: date) -> bool:
    return day.weekday() in (5, 6)


@router.get("/Payroll/GetPayslip")
def get_payslip(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
    employee_id: int = Query(0),
    salary_year: int = Query(2026),
    salary_month: int = Query(1),
):
    employee = db.get(Employee, employee_id or auth.id)
    if employee is None:
        return fail("Karyawan tidak ditemukan")

    days_of_month = calendar.monthrange(salary_year, salary_month)[1]
    month_key = f"{salary_year:04d}-{salary_month:02d}"

    start = f"{month_key}-01"
    end = f"{month_key}-{days_of_month:02d}"

    present_days = (
        db.query(Attendance)
        .filter(
            Attendance.employee_id == employee.id,
            Attendance.date_time >= start,
            Attendance.date_time <= end,
            Attendance.check_in.isnot(None),
        )
        .count()
    )
    leave_days = (
        db.query(UserLeave)
        .filter(
            UserLeave.employee_id == employee.id,
            UserLeave.is_approved == 1,
            UserLeave.start_date >= start,
            UserLeave.end_date <= end,
        )
        .count()
    )
    holidays = sum(
        1
        for d in range(1, days_of_month + 1)
        if _is_weekend(date(salary_year, salary_month, d))
    )
    absent_days = max(0, days_of_month - holidays - present_days - leave_days)

    total_ot_minutes = sum(
        r.overtimE_MINUTES or 0
        for r in db.query(Attendance)
        .filter(
            Attendance.employee_id == employee.id,
            Attendance.date_time >= start,
            Attendance.date_time <= end,
        )
        .all()
    )
    ot_hours = f"{total_ot_minutes // 60}.{total_ot_minutes % 60:02d}"

    basic = float(employee.basic_salary or 0.0)
    medical = round(basic * 0.10, 2)
    conveyance = round(basic * 0.05, 2)
    gross = round(basic + medical + conveyance, 2)

    working_hours = (days_of_month - holidays) * 8
    hourly_rate = basic / working_hours if working_hours else 0.0
    ot_amount = round((total_ot_minutes / 60) * hourly_rate, 2)
    overtime = round(total_ot_minutes / 60, 2)

    absent_deduction = round(
        absent_days * (basic / days_of_month) if days_of_month else 0.0, 2
    )

    # --- PPh 21 progressive tax (replaces flat 10%) ---
    ptkp_annual = _DEFAULT_PTKP
    if employee.ptkp_status_id:
        ptkp_row = db.get(PtkpStatus, employee.ptkp_status_id)
        if ptkp_row:
            ptkp_annual = ptkp_row.annual_value

    ait = round(calculate_ait_monthly(gross, ptkp_annual), 2)
    net_pay = round(max(0.0, gross + ot_amount - absent_deduction - ait), 2)

    data = {
        "employee_id": employee.employee_id,
        "name": employee.name,
        "designation": employee.designation,
        "email": employee.email,
        "joining_date": (
            employee.joining_date.strftime("%Y-%m-%d") if employee.joining_date else ""
        ),
        "bank_name": "",
        "bank_account_no": "",
        "payment_mode": "Bank",
        "days_of_month": days_of_month,
        "holidays": holidays,
        "present_days": present_days,
        "leave_days": leave_days,
        "absent_days": absent_days,
        "basic_salary": basic,
        "medical_allowance": medical,
        "convenyence_allowance": conveyance,
        "gross_salary": gross,
        "ot_hours": ot_hours,
        "other_allowance": 0.0,
        "bonus": 0.0,
        "other_allowance_description": "",
        "overtime": overtime,
        "ot_amount": ot_amount,
        "absent_deduction": absent_deduction,
        "other_deduction_description": "",
        "other_deduction": 0.0,
        "ait": ait,
        "net_pay": net_pay,
        "is_disbursed": 0,
    }
    return ok(data=data)
