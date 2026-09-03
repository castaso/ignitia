"""Employee endpoints.

IMPORTANT — route ordering: all literal-path routes (no path params) must be
registered BEFORE parameterised routes like /{id} so FastAPI does not try to
parse a literal string as an integer.

Wire contract (Flutter client — existing):
  GET  /api/Employees
  GET  /api/Employees/profile?id=
  GET  /api/Employees/GetContactInfo?id=
  PUT  /api/Employees              (self-update)
  PUT  /api/Employees/referenceFace

New endpoints (employee-menu feature):
  POST /api/Employees                      (admin — create)
  GET  /api/Employees/importTemplate       (admin)
  POST /api/Employees/import               (admin — multipart)
  PUT  /api/Employees/{id}                 (admin — full update)
  PUT  /api/Employees/{id}/deactivate      (admin)
  GET  /api/Employees/{id}/transfers
  POST /api/Employees/{id}/transfers       (admin)
  PUT  /api/Employees/{id}/ptkp            (admin)
"""

from datetime import datetime

from fastapi import APIRouter, Depends, Query, UploadFile
from pydantic import BaseModel, ConfigDict
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_employee, require_admin
from ..models import (
    Department,
    Employee,
    EmployeeContactInfo,
    EmployeeTransfer,
    PtkpStatus,
    PtkpStatusHistory,
)
from ..schemas import (
    ProfileIn,
    contact_json,
    employee_json,
    fail,
    ok,
)
from ..security import _decode_image
from ..utils.audit import write_audit_log

router = APIRouter()

_EMPLOYEE_FIELDS = {
    "name", "designation", "cell_no", "email", "address", "nid",
    "employee_id", "supervisor_id", "status_id",
}


# ---------------------------------------------------------------------------
# Pydantic schemas
# ---------------------------------------------------------------------------

class ReferenceFaceIn(BaseModel):
    face_base64: str
    model_config = ConfigDict(extra="ignore")


class EmployeeCreateIn(BaseModel):
    name: str
    employee_id: str
    email: str
    designation: str
    joining_date: str
    department_id: int | None = None
    cell_no: str | None = None
    address: str | None = None
    nid: str | None = None
    supervisor_id: int = 0
    basic_salary: float = 0.0
    model_config = ConfigDict(extra="ignore")


class EmployeeAdminUpdateIn(BaseModel):
    name: str | None = None
    designation: str | None = None
    cell_no: str | None = None
    email: str | None = None
    address: str | None = None
    nid: str | None = None
    employee_id: str | None = None
    supervisor_id: int | None = None
    status_id: int | None = None
    department_id: int | None = None
    ptkp_status_id: int | None = None
    basic_salary: float | None = None
    joining_date: str | None = None
    permanent_date: str | None = None
    model_config = ConfigDict(extra="ignore")


class DeactivateIn(BaseModel):
    effective_date: str
    reason: str
    model_config = ConfigDict(extra="ignore")


class TransferIn(BaseModel):
    from_department_id: int | None = None
    to_department_id: int | None = None
    from_designation: str | None = None
    to_designation: str | None = None
    effective_date: str
    reason: str | None = None
    model_config = ConfigDict(extra="ignore")


class PtkpUpdateIn(BaseModel):
    ptkp_status_id: int
    effective_date: str
    model_config = ConfigDict(extra="ignore")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _transfer_json(t: EmployeeTransfer) -> dict:
    return {
        "id": t.id,
        "employee_id": t.employee_id,
        "from_department_id": t.from_department_id,
        "to_department_id": t.to_department_id,
        "from_designation": t.from_designation,
        "to_designation": t.to_designation,
        "effective_date": t.effective_date,
        "reason": t.reason,
        "created_by": t.created_by,
        "created_at": t.created_at.isoformat() if t.created_at else None,
    }


def _enrich_employee(emp: Employee, db: Session) -> dict:
    dept_name = None
    if emp.department_id:
        dept = db.get(Department, emp.department_id)
        if dept:
            dept_name = dept.name

    ptkp_code = None
    ptkp_annual = None
    if emp.ptkp_status_id:
        ptkp = db.get(PtkpStatus, emp.ptkp_status_id)
        if ptkp:
            ptkp_code = ptkp.code
            ptkp_annual = ptkp.annual_value

    last_t = (
        db.query(EmployeeTransfer)
        .filter(EmployeeTransfer.employee_id == emp.id)
        .order_by(EmployeeTransfer.created_at.desc())
        .first()
    )
    data = employee_json(emp, dept_name=dept_name, ptkp_code=ptkp_code,
                         ptkp_annual_value=ptkp_annual)
    data["department_name"] = dept_name
    data["ptkp_status_code"] = ptkp_code
    data["ptkp_annual_value"] = ptkp_annual
    data["last_transfer_date"] = last_t.effective_date if last_t else None
    data["last_from_designation"] = last_t.from_designation if last_t else None
    data["last_to_designation"] = last_t.to_designation if last_t else None
    return data


# ===========================================================================
# ── LITERAL-PATH ROUTES (no {id}) — must come before parameterised routes ──
# ===========================================================================

# ---------------------------------------------------------------------------
# GET /api/Employees
# ---------------------------------------------------------------------------
@router.get("/Employees")
def get_employee_list(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    if auth.type_id == 1:
        employees = db.query(Employee).order_by(Employee.id).all()
    else:
        employees = [auth]
    return ok(data=[employee_json(e) for e in employees])


# ---------------------------------------------------------------------------
# GET /api/Employees/profile
# ---------------------------------------------------------------------------
@router.get("/Employees/profile")
def get_profile(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
    id: int = Query(0),
):
    target_id = id or auth.id
    if auth.type_id != 1 and target_id != auth.id:
        from fastapi import HTTPException
        raise HTTPException(status_code=403, detail="Forbidden")
    emp = db.get(Employee, target_id)
    if emp is None:
        return fail("Karyawan tidak ditemukan")
    return ok(data=_enrich_employee(emp, db))


# ---------------------------------------------------------------------------
# GET /api/Employees/GetContactInfo
# ---------------------------------------------------------------------------
@router.get("/Employees/GetContactInfo")
def get_contact_info(
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
    id: int = Query(0),
):
    employee_id = id or auth.id
    contact = db.get(EmployeeContactInfo, employee_id)
    if contact is None:
        contact = EmployeeContactInfo(id=employee_id)
        db.add(contact)
        db.commit()
    return ok(data=contact_json(contact))


# ---------------------------------------------------------------------------
# GET /api/Employees/importTemplate
# ---------------------------------------------------------------------------
@router.get("/Employees/importTemplate")
def import_template(
    auth: Employee = Depends(require_admin),
):
    from fastapi.responses import Response
    header = "employee_id,name,email,designation,department_id,joining_date\n"
    return Response(
        content=header,
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=employee_import_template.csv"},
    )


# ---------------------------------------------------------------------------
# POST /api/Employees  (create — admin only)
# ---------------------------------------------------------------------------
@router.post("/Employees")
def create_employee(
    payload: EmployeeCreateIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    missing = [f for f in ("name", "employee_id", "email", "designation", "joining_date", "department_id")
               if not getattr(payload, f, None)]
    if missing:
        return fail(f"Field berikut wajib diisi: {', '.join(missing)}")

    if db.query(Employee).filter(Employee.email == payload.email.strip().lower()).first():
        return fail("Email sudah digunakan")
    if db.query(Employee).filter(Employee.employee_id == payload.employee_id.strip()).first():
        return fail("ID karyawan sudah digunakan")

    joining = None
    if payload.joining_date:
        from ..dates import parse_date
        joining = parse_date(payload.joining_date)

    emp = Employee(
        employee_id=payload.employee_id.strip(),
        name=payload.name.strip(),
        designation=payload.designation.strip(),
        email=payload.email.strip().lower(),
        cell_no=payload.cell_no,
        address=payload.address,
        nid=payload.nid,
        supervisor_id=payload.supervisor_id or 0,
        department_id=payload.department_id,
        basic_salary=payload.basic_salary or 0.0,
        status_id=1,
        type_id=2,
        joining_date=joining,
        password_hash="",
    )
    db.add(emp)
    db.flush()
    db.add(EmployeeContactInfo(id=emp.id))
    db.commit()
    db.refresh(emp)

    write_audit_log(db, "CREATE_EMPLOYEE", emp.id, auth.id,
                    {"employee_id": emp.employee_id, "name": emp.name})
    return ok(data=employee_json(emp), message="Karyawan berhasil ditambahkan")


# ---------------------------------------------------------------------------
# PUT /api/Employees  (self-update — existing, no path param)
# ---------------------------------------------------------------------------
@router.put("/Employees")
def update_employee(
    payload: ProfileIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    emp = db.get(Employee, auth.id)
    if emp is None:
        return fail("Karyawan tidak ditemukan")

    info = payload.employeeInfo or {}
    for key, value in info.items():
        if key in _EMPLOYEE_FIELDS and value is not None:
            if key == "email":
                email = str(value).strip().lower()
                other = (
                    db.query(Employee)
                    .filter(Employee.email == email, Employee.id != auth.id)
                    .first()
                )
                if other is not None:
                    return fail("Email sudah digunakan oleh akun lain")
                setattr(emp, key, email)
            else:
                setattr(emp, key, value)

    if payload.contactInfo is not None:
        contact = db.get(EmployeeContactInfo, auth.id)
        if contact is None:
            contact = EmployeeContactInfo(id=auth.id)
            db.add(contact)
        for key, value in payload.contactInfo.model_dump(exclude_none=True).items():
            if key != "id" and hasattr(contact, key):
                setattr(contact, key, value)

    db.commit()
    return ok(message="Profil berhasil diperbarui")


# ---------------------------------------------------------------------------
# PUT /api/Employees/referenceFace  (existing — must be before /{id})
# ---------------------------------------------------------------------------
@router.put("/Employees/referenceFace")
def register_reference_face(
    payload: ReferenceFaceIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    if _decode_image(payload.face_base64) is None:
        return fail("Gambar wajah tidak valid")
    auth.reference_face = payload.face_base64
    db.commit()
    return ok(message="Foto referensi berhasil didaftarkan")


# ---------------------------------------------------------------------------
# POST /api/Employees/import  (bulk import — literal path before /{id})
# ---------------------------------------------------------------------------
@router.post("/Employees/import")
async def import_employees_upload(
    file: UploadFile,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    from ..utils.bulk_import import (
        REQUIRED_COLUMNS, normalize_date, parse_csv, parse_excel, validate_row,
    )
    from ..dates import parse_date as _pd

    content = await file.read()
    filename = (file.filename or "").lower()

    if filename.endswith(".xlsx") or filename.endswith(".xls"):
        parser = parse_excel
    elif filename.endswith(".csv") or not filename:
        parser = parse_csv
    else:
        return fail("Format file tidak didukung. Gunakan CSV atau XLSX.")

    try:
        rows = parser(content)
    except Exception as exc:
        return fail(f"Gagal membaca file: {exc}")

    if not rows:
        return ok(message="Import selesai (tidak ada data)",
                  data={"total_rows": 0, "success_count": 0, "failed_count": 0, "errors": []})

    first_row_keys = set(rows[0].keys())
    missing_cols = [c for c in REQUIRED_COLUMNS if c not in first_row_keys]
    if missing_cols:
        return fail(f"Kolom wajib tidak ditemukan: {', '.join(missing_cols)}")

    total = len(rows)
    success_count = 0
    failed_count = 0
    errors = []

    for i, row in enumerate(rows, start=2):
        row_errors = validate_row(row)
        if row_errors:
            failed_count += 1
            for msg in row_errors:
                errors.append({"row": i, "field": "", "message": msg})
            continue

        email = str(row["email"]).strip().lower()
        emp_id = str(row["employee_id"]).strip()

        if db.query(Employee).filter(Employee.email == email).first():
            failed_count += 1
            errors.append({"row": i, "field": "email", "message": "Email sudah terdaftar"})
            continue
        if db.query(Employee).filter(Employee.employee_id == emp_id).first():
            failed_count += 1
            errors.append({"row": i, "field": "employee_id", "message": "ID karyawan sudah terdaftar"})
            continue

        joining = _pd(normalize_date(str(row.get("joining_date", "")).strip()) or "")
        dept_id = None
        dept_val = str(row.get("department_id", "")).strip()
        if dept_val:
            try:
                dept_id = int(dept_val)
            except ValueError:
                pass

        try:
            emp = Employee(
                employee_id=emp_id,
                name=str(row["name"]).strip(),
                designation=str(row["designation"]).strip(),
                email=email,
                department_id=dept_id,
                joining_date=joining,
                status_id=1,
                type_id=2,
                basic_salary=0.0,
                password_hash="",
            )
            db.add(emp)
            db.flush()
            db.add(EmployeeContactInfo(id=emp.id))
            db.commit()
            write_audit_log(db, "BULK_IMPORT", emp.id, auth.id,
                            {"employee_id": emp.employee_id, "row": i})
            success_count += 1
        except Exception as exc:
            db.rollback()
            failed_count += 1
            errors.append({"row": i, "field": "", "message": str(exc)})

    return ok(
        message="Import selesai",
        data={
            "total_rows": total,
            "success_count": success_count,
            "failed_count": failed_count,
            "errors": errors,
        },
    )


# ===========================================================================
# ── PARAMETERISED ROUTES  /{id}  — must come AFTER all literal routes ──────
# ===========================================================================

# ---------------------------------------------------------------------------
# PUT /api/Employees/{id}  (full admin update)
# ---------------------------------------------------------------------------
@router.put("/Employees/{id}")
def admin_update_employee(
    id: int,
    payload: EmployeeAdminUpdateIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    emp = db.get(Employee, id)
    if emp is None:
        return fail("Karyawan tidak ditemukan")

    old_designation = emp.designation
    old_dept_id = emp.department_id
    changed = {}
    payroll_changed = False

    field_map = {
        "name": "name", "designation": "designation", "cell_no": "cell_no",
        "address": "address", "nid": "nid", "supervisor_id": "supervisor_id",
        "status_id": "status_id", "department_id": "department_id",
        "ptkp_status_id": "ptkp_status_id", "basic_salary": "basic_salary",
        "employee_id": "employee_id",
    }
    for attr, col in field_map.items():
        val = getattr(payload, attr, None)
        if val is not None:
            old_val = getattr(emp, col, None)
            if old_val != val:
                changed[col] = {"from": old_val, "to": val}
                setattr(emp, col, val)
                if col == "basic_salary":
                    payroll_changed = True

    if payload.email is not None:
        email = payload.email.strip().lower()
        dup = db.query(Employee).filter(
            Employee.email == email, Employee.id != id
        ).first()
        if dup:
            return fail("Email sudah digunakan oleh karyawan lain")
        if emp.email != email:
            changed["email"] = {"from": emp.email, "to": email}
            emp.email = email

    if payload.joining_date is not None:
        from ..dates import parse_date as _pd
        joining = _pd(payload.joining_date)
        if joining:
            emp.joining_date = joining

    if payload.permanent_date is not None:
        from ..dates import parse_date as _pd
        perm = _pd(payload.permanent_date)
        if perm:
            emp.permanent_date = perm

    # Auto-record transfer when designation or department changes
    new_designation = emp.designation
    new_dept_id = emp.department_id
    if old_designation != new_designation or old_dept_id != new_dept_id:
        db.add(EmployeeTransfer(
            employee_id=emp.id,
            from_department_id=old_dept_id,
            to_department_id=new_dept_id,
            from_designation=old_designation,
            to_designation=new_designation,
            effective_date=datetime.now().strftime("%Y-%m-%d"),
            reason="Admin update",
            created_by=auth.id,
        ))

    db.commit()
    if changed:
        write_audit_log(db, "UPDATE_EMPLOYEE", emp.id, auth.id, changed)

    return ok(
        message="Profil karyawan berhasil diperbarui",
        data={"payroll_recalculation_needed": payroll_changed} if payroll_changed else None,
    )


# ---------------------------------------------------------------------------
# PUT /api/Employees/{id}/deactivate
# ---------------------------------------------------------------------------
@router.put("/Employees/{id}/deactivate")
def deactivate_employee(
    id: int,
    payload: DeactivateIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    emp = db.get(Employee, id)
    if emp is None:
        return fail("Karyawan tidak ditemukan")
    if emp.status_id == 2:
        return fail("Karyawan sudah berstatus nonaktif")
    emp.status_id = 2
    emp.deactivate_date = payload.effective_date
    emp.deactivate_reason = payload.reason
    db.commit()
    write_audit_log(db, "DEACTIVATE", emp.id, auth.id,
                    {"effective_date": payload.effective_date, "reason": payload.reason})
    return ok(message="Karyawan berhasil dinonaktifkan")


# ---------------------------------------------------------------------------
# GET /api/Employees/{id}/transfers
# ---------------------------------------------------------------------------
@router.get("/Employees/{id}/transfers")
def get_transfers(
    id: int,
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    transfers = (
        db.query(EmployeeTransfer)
        .filter(EmployeeTransfer.employee_id == id)
        .order_by(EmployeeTransfer.created_at.desc())
        .all()
    )
    return ok(data=[_transfer_json(t) for t in transfers])


# ---------------------------------------------------------------------------
# POST /api/Employees/{id}/transfers
# ---------------------------------------------------------------------------
@router.post("/Employees/{id}/transfers")
def create_transfer(
    id: int,
    payload: TransferIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    if db.get(Employee, id) is None:
        return fail("Karyawan tidak ditemukan")

    for dept_id in filter(None, [payload.from_department_id, payload.to_department_id]):
        if db.get(Department, dept_id) is None:
            return fail(f"Departemen dengan id {dept_id} tidak ditemukan")

    db.add(EmployeeTransfer(
        employee_id=id,
        from_department_id=payload.from_department_id,
        to_department_id=payload.to_department_id,
        from_designation=payload.from_designation,
        to_designation=payload.to_designation,
        effective_date=payload.effective_date,
        reason=payload.reason,
        created_by=auth.id,
    ))
    db.commit()
    return ok(message="Riwayat transfer berhasil disimpan")


# ---------------------------------------------------------------------------
# PUT /api/Employees/{id}/ptkp
# ---------------------------------------------------------------------------
@router.put("/Employees/{id}/ptkp")
def update_ptkp(
    id: int,
    payload: PtkpUpdateIn,
    db: Session = Depends(get_db),
    auth: Employee = Depends(require_admin),
):
    emp = db.get(Employee, id)
    if emp is None:
        return fail("Karyawan tidak ditemukan")

    ptkp = db.get(PtkpStatus, payload.ptkp_status_id)
    if ptkp is None:
        return fail("Kode PTKP tidak valid")

    old_ptkp_id = emp.ptkp_status_id
    emp.ptkp_status_id = payload.ptkp_status_id
    db.add(PtkpStatusHistory(
        employee_id=id,
        old_ptkp_status_id=old_ptkp_id,
        new_ptkp_status_id=payload.ptkp_status_id,
        effective_date=payload.effective_date,
        changed_by=auth.id,
    ))
    db.commit()
    write_audit_log(db, "UPDATE_PTKP", emp.id, auth.id,
                    {"old_ptkp_status_id": old_ptkp_id,
                     "new_ptkp_status_id": payload.ptkp_status_id})
    return ok(message="Status PTKP berhasil diperbarui",
              data={"payroll_recalculation_needed": True})
