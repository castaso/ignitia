# Product Requirements Document

**Product:** Ignitia (i_Employment)
**Version:** 1.0
**Status:** Current-state + target product
**Date:** 2026-09-09
**Owner:** Product / Engineering
**Codebase:** Monorepo `ignitia/` (`ignitia_server`, `ignitia_dashboard`, `ignitia_android`)

---

## 1. Executive Summary

Ignitia is a bilingual (ID/EN) HRIS and attendance platform for mid-size Indonesian companies. It prevents proxy attendance with server-side geo-fence, face matching, and optional liveness, then extends into time management, payroll (PPh 21 / PTKP), employee master data, and company administration.

The product ships as three clients against one FastAPI backend:

| Component | Stack | Audience |
|-----------|--------|----------|
| `ignitia_android` (i_Employment) | Flutter mobile | Employees and on-site admins |
| `ignitia_dashboard` | Flutter web | Super-admin / HR |
| `ignitia_server` | FastAPI + SQLAlchemy | Source of truth |

This PRD captures the product as implemented and the remaining gaps that are already specified or stubbed in the UI.

---

## 2. Problem Statement

Small and mid-size companies in Indonesia still rely on paper logs, buddy punching, and disconnected spreadsheets for attendance, leave, overtime, and payroll. Common failures:

- Employees check in for each other (proxy attendance).
- HR cannot reconstruct who worked which shift, when they took a break, or which hours are payable.
- Tax (PPh 21) is calculated with a flat rate instead of PTKP + progressive brackets.
- Company assets, announcements, and files live outside the HRIS.
- Admins need one web console; employees need a phone app at the office gate.

Ignitia is the single system of record for identity, presence, time, people, and company operations.

---

## 3. Goals and Non-Goals

### 3.1 Goals

1. Make check-in/check-out trustworthy: geo-fence + face + optional liveness, server as source of truth.
2. Give HR a weekly time stack: roster, attendance, one break type, leave, timesheet with approval and CSV export.
3. Keep an employee master (directory, department, transfer history, PTKP, bulk import, manpower planning).
4. Give admins a company hub: assets, activity log, announcements, in-app notifications, private files, timesheet CSV.
5. Support Indonesian payroll tax (PTKP codes + UU HPP 2022 progressive PPh 21) on payslips.
6. Ship bilingual UI (Indonesian / English) with role-based menus.
7. Preserve the existing Flutter wire contract (`isSuccess` / `message` / `data`, quirky JSON keys).

### 3.2 Non-Goals (this version)

- Full payroll engine (BPJS, allowances engine, bank files, multi-period close). Settings Payroll is an MVP stub.
- Recruitment ATS, finance GL, performance review, talent marketplace (menu items are Coming Soon).
- Email or push for announcements (in-app notifications only).
- Timesheet export beyond CSV (xlsx/pdf later).
- Alembic-managed migrations (tables via `create_all` + additive `run_migrations`).
- Auto-provision of users from Google SSO (unknown emails are rejected).
- Multi-office geo-fence per employee (single office centre + radius today).

---

## 4. Users and Roles

| Role | `type_id` | Primary client | Access |
|------|-----------|----------------|--------|
| Super-admin / HR Admin | 1 | Dashboard (web), Android admin menus | Full CRUD on employees, time, company, settings, approvals |
| Employee | 2 | Android (i_Employment) | Own profile (non-payroll), check-in/out, leave, overtime, payslip, directory (limited) |
| Supervisor | employee with subordinates via `supervisor_id` | Android / Dashboard | Approves overtime / leave / attendance edits for reports |

Rules:

- Missing or expired JWT → HTTP 401.
- Employee hitting admin-only APIs → HTTP 403.
- Employee may update own name/contact/address; employment and salary fields are ignored.
- Settings hub (parent menu 90) is admin-only.
- Deactivated employees (`status_id = 2`) cannot log in; historical attendance/leave/payslip is retained.

---

## 5. Product Architecture

```
Flutter Android (i_Employment)          Flutter Web (ignitia_dashboard)
 GPS + camera + ML Kit blink              Super-admin home, TrinaGrid, charts
                \                        /
                 \  HTTPS + Bearer JWT  /
                  v                    v
              FastAPI  /api  (ignitia_server)
         JWT auth · geo-fence · YuNet/SFace · liveness challenge
         SQLAlchemy  (SQLite default / PostgreSQL via DATABASE_URL)
```

**API contract**

- Base path: `/api`
- Envelope: `{ "isSuccess": bool, "message": str, "data": ... }`
- Login success: JWT is returned in `message` (client stores `FieldValue.token`).
- Business failures (geo/face/duplicate): HTTP 200 + `isSuccess: false`.
- Auth failures: HTTP 401; authorization: HTTP 403.
- JSON keys match the Flutter client, including `missinG_REASON`, `overtimE_MINUTES`, `employeE_ID`, `checK_IN`, `checK_OUT`.

**Auth**

- Email + password → app JWT (HS256, default 720h).
- Google SSO via shared Supabase project: client OAuth → `POST /Login/supabase` with access token → verify locally with `SUPABASE_JWT_SECRET` → issue app JWT. Unconfigured SSO returns 503. Unknown email returns 404. Inactive employee returns 401. No auto-provision.

---

## 6. Information Architecture

### 6.1 Dashboard (admin)

| Menu | ID | Status |
|------|----|--------|
| Home | 1 | Super-admin dashboard cards |
| Employee profile | 2 | Coming Soon |
| Employees | 3 | Employee directory |
| Recruitment | 10 | Coming Soon |
| Time | 30 | Parent: schedule, roster, attendance, break, leave, timesheet, shift, holiday, overtime, assign shift |
| Finance | 11 | Coming Soon |
| Payroll | 12 | Coming Soon (payslip exists on mobile) |
| Productivity | 13 | Coming Soon |
| Company | 40 | Parent: assets, activity, announcements, notifications, files, report builder |
| Applications | 47 | Parent: most Coming Soon; Timesheet live |
| Integrations | 48 | Settings integrations page |
| Settings | 90 | Admin-only: company profile, time & attendance, payroll, users & roles, integrations (MVP stubs) |
| Sign out | 99 | Session clear |

Home cards: greeting, 4 workforce charts, shortcuts, quick links, balance time-off, applications, feed (announcements / contract & probation / tasks), who's off, download mobile, company ID footer.

### 6.2 Android (employee + admin)

- Shared: Home, Profile, Time Management, Company Hub, Change password, Web view, Sign out.
- Admin: employee list, attendance list, approve attendance/overtime/leave, holidays, office location, Settings hub.
- Employee: attendance, edit requests, overtime, leave, payslip, colleague list.

---

## 7. Functional Requirements

Each requirement uses MoSCoW: **Must** (shipped or specified as complete), **Should** (partial / stub), **Could** (roadmap).

### 7.1 Authentication and Account

| ID | Requirement | Priority | Notes |
|----|-------------|----------|--------|
| AUTH-1 | Email/password login issues app JWT in `message` | Must | `POST /Login` |
| AUTH-2 | Change password for authenticated user | Must | `POST /Login/ChangePassword` |
| AUTH-3 | Forgot password always returns success (anti-enumeration); emails reset link when SMTP set, else logs link | Must | `POST /Login/ForgetPassword` |
| AUTH-4 | Reset password with one-time hashed token | Must | `POST /Login/ResetPassword` |
| AUTH-5 | Google SSO via Supabase; match existing employee email; no auto-provision | Must | `POST /Login/supabase` |
| AUTH-6 | Inactive employees cannot authenticate | Must | 401 |
| AUTH-7 | All protected routes require `Authorization: Bearer <jwt>` | Must | |

### 7.2 Anti-Proxy Attendance

Headline capability. Server re-validates every check-in/out.

| ID | Requirement | Priority | Notes |
|----|-------------|----------|--------|
| ATT-1 | Check-in / check-out via `POST /Attendance/v2/checkin` and `checkout` | Must | |
| ATT-2 | Server geo-fence: haversine vs `OFFICE_LATITUDE/LONGITUDE` + `OFFICE_RADIUS_METERS`; reject outside range | Must | Server wins over client placeholder |
| ATT-3 | Face match vs registered `reference_face` (YuNet detect + SFace cosine; pHash fallback) | Must | `PUT /Employees/referenceFace` |
| ATT-4 | Reject blank / featureless captures | Must | |
| ATT-5 | Optional liveness: single-use challenge `GET /Attendance/livenessChallenge` (alias `/Liveness/challenge`), consume on use, TTL | Must | `MIN_LIVENESS_FRAMES`, diversity check |
| ATT-6 | Per-company liveness billing: `liveness_addon_active` + `liveness_addon_expires_at`; gates attendance and break | Must | |
| ATT-7 | Compute late minutes vs office/shift start; overtime minutes vs end | Must | |
| ATT-8 | Search attendance by date; user summary (late days, overtime) | Must | |
| ATT-9 | Employee may request attendance edit; admin approve/reject (status 1/2/3) | Must | |
| ATT-10 | Duplicate same-day check-in rejected with business message | Must | HTTP 200 + `isSuccess: false` |

### 7.3 Time Management

| ID | Requirement | Priority | Notes |
|----|-------------|----------|--------|
| TM-1 | Shift CRUD (name, start/end HH:mm, cross-midnight hours, active/inactive) | Must | |
| TM-2 | Weekly work-schedule template JSON `{1..7: shiftId}` (Mon–Sun) | Must | |
| TM-3 | Employee roster from template + nullable `override_pattern` | Must | |
| TM-4 | Assign shift to employees over a date range | Must | Dashboard Assign Shift |
| TM-5 | Single break type per company (`CompanyBreakConfig`): duration default 60m, window 12:00–13:00, paid flag, liveness, active | Must | |
| TM-6 | Break sessions with start/end, geo, optional face/liveness | Must | Break minutes excluded from work hours |
| TM-7 | Leave types, employee leave apply/list/summary; admin approve | Must | |
| TM-8 | Holiday calendar CRUD | Must | |
| TM-9 | Overtime request + supervisor/admin approve/reject | Must | |
| TM-10 | Daily timesheet entries generated from attendance; `work_minutes = (out-in) - break - late` | Must | Unique per employee+date |
| TM-11 | Weekly timesheet HR approve/reject | Must | |
| TM-12 | Timesheet CSV export only | Must | xlsx/pdf Could |
| TM-13 | Bilingual labels for all Time Management screens | Must | |

### 7.4 Employee Master (HRIS)

Specified in `.kiro/specs/employee-menu/requirements.md`. Backend implemented; dashboard has list/detail; some Android create/import UX may still lag.

| ID | Requirement | Priority | Notes |
|----|-------------|----------|--------|
| EMP-1 | List employees; search by name, employee_id, department (client-side on loaded list) | Must | |
| EMP-2 | Profile: personal, employment, contact/family, payroll (admin), last transfer | Must | Employee hides salary |
| EMP-3 | Admin create employee; unique email and employee_id; defaults status=1, type=2, salary=0; auto empty contact row | Must | `POST /Employees` |
| EMP-4 | Admin update employment fields; employee self-update limited to profile/contact | Must | |
| EMP-5 | Soft deactivate with effective date + reason; keep history | Must | `PUT /Employees/{id}/deactivate` |
| EMP-6 | Department CRUD; employee `department_id` | Must | |
| EMP-7 | Transfer history; auto-log on designation/department change | Must | |
| EMP-8 | PTKP reference TK/0–TK/3, K/0–K/3; assign per employee; history | Must | |
| EMP-9 | Bulk CSV/Excel import with per-row report; download template | Must | Admin only |
| EMP-10 | Manpower plan target headcount per dept/designation/month; summary vs actual | Must | Upsert unique key |
| EMP-11 | Replacement tracking Open/Filled/Cancelled; overdue flag after `expected_fill_date` | Must | Reasons: Resign, Long_Leave, Transfer |
| EMP-12 | Audit log on employee write operations | Must | Reused as Activity History |
| EMP-13 | Inactive employees remain in list with visual status | Must | |

### 7.5 Payroll

| ID | Requirement | Priority | Notes |
|----|-------------|----------|--------|
| PAY-1 | `GET /Payroll/GetPayslip` for employee + year + month | Must | Mobile payslip page |
| PAY-2 | PPh 21 progressive (UU HPP 2022): 5/15/25/30% on PKP after PTKP; default PTKP TK/0 54,000,000 | Must | Replaces old flat 10% |
| PAY-3 | Flag `payroll_recalculation_needed` when salary or PTKP changes | Must | |
| PAY-4 | Process Salary / Salary Sheet / dashboard Payroll menu | Could | Coming Soon / null menu |
| PAY-5 | Settings Payroll (PTKP display) persist to server | Should | MVP stub `_ApiHint` |

### 7.6 Company Administration Hub

| ID | Requirement | Priority | Notes |
|----|-------------|----------|--------|
| CO-1 | Assets: categories IT / Kendaraan / Furniture / Lainnya; statuses Active / Disposed / Maintenance / Lost / On Loan | Must | |
| CO-2 | Activity History lists existing `AuditLog` (no view-tracking noise) | Must | |
| CO-3 | Announcements with audience ALL / DEPARTMENT / ROLE; publish fans out in-app notifications only | Must | |
| CO-4 | In-app notifications list + mark read (inbox badge on dashboard) | Must | No email/push |
| CO-5 | Company files private per uploader, 20MB max; admin can list all (`?all=true`) | Must | |
| CO-6 | Report Builder = timesheet CSV export | Must | |

### 7.7 Super-Admin Dashboard

| ID | Requirement | Priority | Notes |
|----|-------------|----------|--------|
| DASH-1 | Summary: headcount, present/late/absent today, on leave, pending approvals, upcoming leaves | Must | `GET /Dashboard/summary` |
| DASH-2 | Charts: employment_status, length_of_service, job_level, gender_diversity | Must | |
| DASH-3 | Who's off (Today / 7 / 14 / 30 days) | Must | |
| DASH-4 | Contract & probation window (±30 days default) | Must | `permanent_date`, `contract_end_date` |
| DASH-5 | Rule-based AI summary (no external LLM) | Must | `GET /Dashboard/aiSummary` |
| DASH-6 | Tasks CRUD Open / InProgress / Done | Must | Admin write |
| DASH-7 | Top bar: logo, Core/Non-Core, summarize, quick action, search, inbox, switch app, profile | Must | |
| DASH-8 | Optional old-navigation toggle | Must | Shared prefs |

### 7.8 Settings (admin MVP)

Five pages, admin-only, no new tables in MVP:

1. Company Profile
2. Time & Attendance
3. Payroll (PTKP)
4. Users & Roles
5. Integrations (SMTP / webhook)

**Should:** persist to server in a later phase.

---

## 8. Non-Functional Requirements

| ID | Area | Requirement |
|----|------|-------------|
| NFR-1 | Locale | UI strings bilingual ID/EN; fallback English |
| NFR-2 | Compatibility | Do not break existing Flutter wire keys or envelope |
| NFR-3 | Security | Passwords hashed; reference faces and JWT secret never returned; SSO env-gated |
| NFR-4 | Privacy | Files scoped to uploader unless admin; employees cannot read others' payroll |
| NFR-5 | Integrity | Soft-delete only for people; attendance/leave/OT/payslip retained after deactivate |
| NFR-6 | Performance | Dashboard cards load in parallel; list search is client-side on fetched set |
| NFR-7 | Reliability | Liveness challenges single-use with TTL; SMTP optional |
| NFR-8 | Observability | AuditLog for writes; password-reset links logged when SMTP unset |
| NFR-9 | i18n tax | PTKP and PPh 21 follow Indonesian DJP / UU HPP 2022 |
| NFR-10 | Preview | Single exposed port: frontend reverse-proxy `/api` to backend |
| NFR-11 | Test | Server suite (pytest) is the contract gate; currently 79+ tests including dashboard and SSO |
| NFR-12 | Config | Office geo, face thresholds, liveness, SMTP, Supabase via `.env` |

---

## 9. Data Model (logical)

**Core:** Company, Department, Employee, EmployeeContactInfo, PtkpStatus, PtkpStatusHistory, EmployeeTransfer, PasswordResetToken, AuditLog

**Time:** Attendance, AttendanceEditRequest, Overtime, LeaveType, UserLeave, Shift, WorkScheduleTemplate, EmployeeRoster, CompanyBreakConfig, BreakSession, TimesheetEntry

**HR planning:** ManpowerPlan, ReplacementTracking

**Company hub:** CompanyAsset, Announcement, Notification, CompanyFile

**Dashboard:** Task; Employee dimensions gender, job_level, employment_status, contract_end_date

**Company liveness flags:** `liveness_addon_active`, `liveness_addon_expires_at`, `attendance_liveness_enabled`, `break_liveness_enabled`

---

## 10. Success Metrics

| Metric | Target |
|--------|--------|
| Proxy check-in blocked (geo or face fail) | 100% of failing samples rejected with clear message |
| Liveness replay (identical frames / reused challenge) | Rejected |
| Time-to-check-in (happy path, on device) | Under 15 seconds including blink |
| Payslip PPh 21 vs spreadsheet for TK/0 and K/1 fixtures | Exact match to bracket math |
| Bulk import | Partial success with row-level errors; never all-or-nothing on duplicate rows |
| Admin dashboard first paint of summary | Under 3 seconds on office LAN |
| SSO unknown account | 404, zero new employee rows |
| Regression | pytest green before merge |

---

## 11. Constraints and Assumptions

- One office geo-fence per deployment (env), not per site/employee.
- One break type per company.
- App JWT remains canonical after Google SSO.
- Flutter clients may keep odd JSON key casing for backward compatibility.
- Database default is SQLite; production should use PostgreSQL via `DATABASE_URL`.
- Face models (YuNet ONNX + SFace) must be present for production matching; otherwise pHash fallback.
- Settings pages do not yet persist.
- Android Company Hub / Time Management children currently reuse some legacy pages as placeholders; dashboard is the admin source of truth.
- Product is private / internal (see root README).

---

## 12. Out of Scope / Roadmap

**Coming Soon in IA (do not treat as committed delivery):** Recruitment, Finance, full Payroll console, Productivity, Employee Profile page, Applications (forms, performance, talent, insight, document template, talentics, marketplace).

**Next product increments (already decided):**

1. Persist Settings hub to server.
2. Timesheet xlsx/pdf export.
3. Align Android Time/Company child pages with dashboard (not legacy stand-ins).
4. Alembic migrations.
5. Email/push announcements (explicitly deferred).
6. Multi-office / per-employee geo-fence.
7. Full payroll (allowances, BPJS, salary process, salary sheet).

---

## 13. Acceptance Criteria (product-level)

The product is acceptable for an internal HRIS rollout when:

1. An employee cannot check in outside the fence, with another person's face, or with a still/replayed liveness sequence.
2. Admin can define a weekly roster, see attendance, configure one break window, approve leave/OT/timesheet, and download timesheet CSV.
3. Admin can add, import, transfer, PTKP-tag, and deactivate employees without losing history.
4. Payslip AIT uses PTKP + progressive PPh 21.
5. Admin can manage assets (all categories/statuses), publish an announcement that appears as in-app notifications, upload a private file, and view audit activity.
6. Google Sign-In works only for existing active emails when Supabase is configured; email login always works.
7. UI is usable in Indonesian and English.
8. Server tests pass against the Flutter wire contract.

---

## 14. Open Questions

| # | Question | Current decision |
|---|----------|------------------|
| 1 | Multi-company tenancy isolation | Company rows exist; most queries are not strictly tenant-filtered yet |
| 2 | Supervisor vs admin approval matrix | Overtime has `supervisoR_ID`; many flows are admin-only |
| 3 | Mobile reference-face registration UI | API exists; dedicated camera UX still expected |
| 4 | Production face-model packaging | Bundled ONNX paths in config |
| 5 | Payroll close calendar | Not defined |
| 6 | Data residency / GDPR-equivalent policy | Not defined |

---

## 15. References

- Root overview: `README.md`
- Server contract and anti-proxy design: `ignitia_server/README.md`
- Employee HRIS spec: `.kiro/specs/employee-menu/requirements.md`
- Time Management + Company Hub + Settings: `task_plan.md`, `findings.md`, `progress.md`
- Super-admin dashboard: `.planning/2026-09-03-dashboard-super-admin/task_plan.md`
- Google SSO: `docs/google-sso.md`, `.planning/2026-09-04-supabase-sso/task_plan.md`
- Demo accounts: `demo@ignitia.local` / `demo1234` (employee), `admin@ignitia.local` / `admin1234` (admin)
