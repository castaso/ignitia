"""Lightweight startup migrations for columns added after initial deploy.

SQLAlchemy's ``create_all`` creates missing *tables* but never adds columns
to existing ones. This module fills that gap for the narrow set of columns
added to pre-existing tables. Called from ``main.py`` lifespan after
``Base.metadata.create_all``.

For a production PostgreSQL deployment, migrate to Alembic.
"""

from sqlalchemy import inspect, text


def run_migrations(engine) -> None:
    """Idempotently add new columns to existing tables."""
    with engine.connect() as conn:
        inspector = inspect(engine)

        # ----------------------------------------------------------------
        # employees table — new HR columns
        # ----------------------------------------------------------------
        existing_emp = {c["name"] for c in inspector.get_columns("employees")}
        new_emp_cols = {
            "department_id": "INTEGER",
            "ptkp_status_id": "INTEGER",
            "deactivate_date": "VARCHAR(25)",
            "deactivate_reason": "VARCHAR(500)",
        }
        for col, coltype in new_emp_cols.items():
            if col not in existing_emp:
                conn.execute(text(
                    f"ALTER TABLE employees ADD COLUMN {col} {coltype}"
                ))

        conn.commit()
