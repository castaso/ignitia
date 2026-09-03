"""Company Files — private per uploader, admin monitor."""

import os
import uuid
from fastapi import APIRouter, Depends, File, Form, Query, UploadFile
from sqlalchemy.orm import Session

from ..config import settings
from ..database import get_db
from ..deps import get_current_employee, require_admin
from ..models import CompanyFile, Employee
from ..schemas import company_file_json, fail, ok

router = APIRouter()

MAX_BYTES = 20 * 1024 * 1024  # 20 MB


def _company_file_dir() -> str:
    d = os.path.join(settings.UPLOAD_DIR, "company_files")
    os.makedirs(d, exist_ok=True)
    return d


@router.get("/CompanyFiles")
def list_files(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), all: int = Query(0)):
    # private per-uploader: employee sees own only unless admin + all=1
    q = db.query(CompanyFile)
    if auth.type_id != 1 or not all:
        q = q.filter(CompanyFile.uploader_id == auth.id)
    rows = q.order_by(CompanyFile.created_at.desc()).all()
    return ok(data=[company_file_json(r) for r in rows])


@router.post("/CompanyFiles")
def upload_file(
    file: UploadFile = File(...),
    company_id: int = Form(0),
    category: str = Form(""),
    description: str = Form(""),
    db: Session = Depends(get_db),
    auth: Employee = Depends(get_current_employee),
):
    if file.size and file.size > MAX_BYTES:
        return fail("File too large (max 20 MB)")
    data = file.file.read()
    if len(data) > MAX_BYTES:
        return fail("File too large (max 20 MB)")
    ext = os.path.splitext(file.filename or "")[1]
    stored = f"{uuid.uuid4().hex}{ext}"
    dir_path = _company_file_dir()
    path = os.path.join(dir_path, stored)
    with open(path, "wb") as f:
        f.write(data)
    row = CompanyFile(
        company_id=company_id or None,
        uploader_id=auth.id,
        file_name=stored,
        original_name=file.filename or stored,
        mime=file.content_type,
        size_bytes=len(data),
        storage_path=path,
        category=category or None,
        description=description or None,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return ok(data=company_file_json(row), message="File uploaded")


@router.delete("/CompanyFiles")
def delete_file(db: Session = Depends(get_db), auth: Employee = Depends(get_current_employee), id: int = Query(0)):
    row = db.get(CompanyFile, id)
    if row is None:
        return fail("File not found")
    if row.uploader_id != auth.id and auth.type_id != 1:
        return fail("Not authorized to delete this file")
    try:
        if row.storage_path and os.path.exists(row.storage_path):
            os.remove(row.storage_path)
    except Exception:
        pass
    db.delete(row)
    db.commit()
    return ok(message="File deleted")
