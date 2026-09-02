"""Audit log helper — records write operations on employee data."""

import json

from sqlalchemy.orm import Session

from ..models import AuditLog


def write_audit_log(
    db: Session,
    action: str,
    target_employee_id: int | None,
    performed_by: int,
    changed_fields: dict,
) -> None:
    """Append one audit log entry.  Never raises — failures are silently ignored
    so a logging error never blocks the main operation."""
    try:
        entry = AuditLog(
            action=action,
            target_employee_id=target_employee_id,
            performed_by=performed_by,
            changed_fields=json.dumps(changed_fields, default=str),
        )
        db.add(entry)
        db.commit()
    except Exception:
        db.rollback()
