"""FastAPI application entry point for ignitia_server.

The Flutter client is hard-coded to base URL ``http://<host>:86/api/``
(lib/repo/api_service.dart), so all routers are mounted under ``/api``.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .database import Base, SessionLocal, engine
from .migrations import run_migrations
from .routers import (
    activity_logs,
    announcements,
    attendance,
    breaks,
    companies,
    company_assets,
    company_files,
    departments,
    employees,
    leave,
    login,
    manpower_plans,
    notifications,
    overtime,
    payroll,
    ptkp_statuses,
    replacement_tracking,
    shift,
    timesheet,
    work_schedule,
)
from .seed import seed_ptkp_statuses


@asynccontextmanager
async def lifespan(app: FastAPI):
    # 1. Create any missing tables.
    Base.metadata.create_all(bind=engine)
    # 2. Add new columns to existing tables (idempotent).
    run_migrations(engine)
    # 3. Seed reference data.
    db = SessionLocal()
    try:
        seed_ptkp_statuses(db)
    finally:
        db.close()
    yield


def create_app() -> FastAPI:
    app = FastAPI(
        title="ignitia_server",
        description="Backend for the i_employment Flutter app, with "
        "server-side geo-fence + face verification to prevent proxy attendance.",
        version="0.2.0",
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.get("/")
    def root():
        return {
            "service": "ignitia_server",
            "docs": "/docs",
            "office": {
                "latitude": settings.OFFICE_LATITUDE,
                "longitude": settings.OFFICE_LONGITUDE,
                "radius_meters": settings.OFFICE_RADIUS_METERS,
            },
        }

    # Register routers under the /api prefix (matching the client base URL).
    for router in (
        login.router,
        attendance.router,
        employees.router,
        leave.router,
        overtime.router,
        payroll.router,
        companies.router,
        departments.router,
        ptkp_statuses.router,
        manpower_plans.router,
        replacement_tracking.router,
        shift.router,
        work_schedule.router,
        breaks.router,
        timesheet.router,
        company_assets.router,
        announcements.router,
        notifications.router,
        company_files.router,
        activity_logs.router,
    ):
        app.include_router(router, prefix="/api")

    return app


app = create_app()
