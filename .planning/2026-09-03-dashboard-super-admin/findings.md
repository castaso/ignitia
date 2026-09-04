# Findings & Decisions — Dashboard Super-Admin Layout

## Requirements (from `C:\Users\Yongky\Downloads\ignitia\dashboard.docx`, 19 elements)
Top bar: 1. Company Logo (tap=change; branch-aware) · 2. Ignitia Core & Non-Core (→ Insights/PM/Recruitment) · 3. Summarize data (AI: ringkasan ketenagakerjaan, kehadiran) · 4. Quick action (Add/create + Request) · 5. Search (employee name keyword) · 6. Inbox (messages, employee requests, system notifications) · 7. Switch app (other Mekari products) · 8. Profile Picture Icon (menu: User Name→my info, Account settings, Company info, Company list, Request PIC contact [popup form], Switch to old navigation, Support center, Help, Sign Out)
9. Menu bar (Super Admin): Home, Employee profile, Employees, Recruitment, Time, Finance, Payroll, Productivity, Company, Applications, Integrations, Settings
Dashboard cards: 10. Shortcut (Live attendance [absen masuk/keluar], Request benefit reimbursement, Request time off, More Request: Cash advance, Overtime, Change Shift) · 11. Chart (switch: Employment Status, Length of Service, Job Level, Gender Diversity) · 12. Quick Links (My Info→Employees>>General Info, Add Employee, Employee Transfer, Company Settings, Integration) · 13. Balance Time Off (sisa saldo cuti/izin; unlimited NOT shown) · 14. Applications (Forms, Performance Review, Talent management, Insight, Timesheet, Document template, Recruitment, Talentics, Marketplace) · 15. Announcement (filter by Category) · 16. Contract & Probation (mendekatan akhir percobaan/kontrak; timing configurable in Settings) · 17. Task (tugas ke karyawan) · 18. Who's Off (karyawan cuti dalam periode tertentu) · 19. Download Ignitia Mobile (App Store, Google Play)

## Research Findings — Frontend (ignitia_dashboard, Flutter Web)
- `lib/main.dart:49-58` — MultiProvider (Login/Employee/Holiday/Overtime/Shift VMs), home = DashboardHomeScreen when logged in. NO Router; pages opened via `navigation_utils.dart` `openNewUI`/`logout`.
- `lib/views/dashboard_home_screen.dart:40-91` — current home: AppBar (static `eb_logo.png` scaled 2.5x, title "Dashboard", `UserInfoWidget` right) + `Row(MenuPage flex1, content flex3)` with "Go To:" + `_quickAccessGrid` (5 MenuItemModel cards: EmployeeList, ApproveOvertime, Holiday, Shift, AssignShift + SignOut id 99).
- `lib/views/menu_page.dart:24-59` — sidebar: `MenuList().getMenuList().where(typeId contains FieldValue.userTypeId)`, ExpansionTile for parents (`_parentItem:63`), `webWidth` responsive (`automaticallyImplyLeading` when narrow).
- `lib/utils/menu_list.dart:30-63` — current menu: Home(1), MyColleagues(3), parent 30 Time Management (31/310/32/33/330/34/35), parent 40 Company (41-46), parent 90 Settings (91-95), legacy flat 13/18/20/21, SignOut(99). All `[1]` admin-only.
- `lib/views/home/user_info_section.dart:20-61` — Card with userName, userDesignation, employeeId, lastLogin — to be replaced by profile dropdown.
- `lib/utils/string.dart` — `Strings` static consts; bilingual pattern e.g. `titleTimeManagement = "Time Management / Manajemen Waktu"`; `appName = "i Employment"`.
- `lib/repo/api_service.dart` — Retrofit `@RestApi(baseUrl: kApiBaseUrl)` default `http://27.147.159.195:86/api/`, `String.fromEnvironment('API_BASE_URL')`; existing: Login, Overtime CRUD, Holiday CRUD, Shift CRUD/assign, WorkSchedule, Break, Liveness, Timesheet, CompanyAssets, ActivityLogs, Announcements (GET/POST/publish), Notifications (GET ?is_read, POST read), CompanyFiles, Employees (GET list, GetContactInfo), ForgetPassword. `part 'api_service.g.dart'` (build_runner).
- `pubspec.yaml` — provider, dio, retrofit, json_annotation, intl, trina_grid, dropdown_search, fluttertoast, flutter_spinkit, google_fonts, marquee, omni_datetime_picker, switcher, shared_preferences, url_launcher, whatsapp_unilink. **NO chart lib** → add `fl_chart`.
- `lib/utils/global_fields.dart` — `FieldValue` statics (userId, employeeId, userName, userTypeId, token, ...) loaded from SessionManager in main.
- `lib/views/employee/employee_list_page.dart` — TrinaGrid employee list; needs optional search param for top-bar Search.
- Existing pages reusable: `views/time_management/attendance/attendance_tm_page.dart`, `leave_tm_page.dart`, `timesheet_page.dart`, `admin/leave/holiday_page.dart`, `admin/attendance/approve_overtime_page.dart`, `shift/shift_page.dart`, `company_admin/announcement/announcement_page.dart`, `settings/company_profile_settings_page.dart`, `settings/integration_settings_page.dart`, `views/admin/leave/holiday_page.dart`.
- `lib/models/menu_item_model.dart` — `MenuItemModel(id, name, typeId, page, {children, isParent})`.

## Research Findings — Server (ignitia_server, FastAPI + SQLAlchemy/SQLite)
- `app/main.py:107` — `app.include_router(router, prefix="/api")`; lifespan runs `Base.metadata.create_all` then `run_migrations(engine)` (`app/migrations.py:14-34` — idempotent `ALTER TABLE ... ADD COLUMN` via inspector; extend this for new employee cols).
- `app/models.py` — Employee(62-91): id, employee_id(str), name, designation, cell_no, email, address, nid, type_id(1 admin/2 emp), supervisor_id, status_id(1 active/2 inactive), joining_date, permanent_date, department_id, ptkp_status_id, deactivate_date/reason, password_hash, reference_face, basic_salary. **NO gender / job_level / employment_status / contract_end_date.**
- `app/models.py` — LeaveType(id, leave_name, leave_short_name, leave_count=entitlement), UserLeave(leave_id, employee_id, apply_date, start_date, end_date, reason, total_days, is_approved). UserLeaves are per-employee keyed by internal `employees.id`.
- `app/routers/leave.py:30-63` — `GET /Leave/getEmployeeLeaveSummary?employeeId=` returns `[{employeE_ID, employeE_NAME, leavE_SHORT_NAME, entitlement, taken, balance}]` (balance = max(0, entitlement - taken); **unlimited types have leave_count=0 → excluded client-side**).
- `app/routers/announcements.py:15` — `GET /Announcements?company_id=`; Announcement(title, body, audience ALL/DEPARTMENT/ROLE, is_pinned, publish_at, expires_at). No "category" column → filter by `audience` as proxy.
- `app/routers/notifications.py:15,35` — `GET /Notifications?is_read=0/1` (unread count source), `POST /Notifications/{id}/read`, `POST /Notifications/read-all`.
- `app/routers/attendance.py:265,350,385` — `searchAttendanceByDate`, `userAttendanceSummary` (present/late/absent math), `getAttendanceRequest` (pending approvals). Overtime pending = `status == "Pending"`; leave pending = `is_approved == 0`.
- `app/models.py:19-21` `_now` UTC-naive default; wire contract uses odd casing (employeE_ID etc.) — new dashboard endpoints may use clean snake_case (new client only).
- `requirements.txt` — fastapi, uvicorn, sqlalchemy, pyjwt, pillow, opencv-headless, numpy, python-multipart, python-dotenv, pytest, httpx2, openpyxl, hypothesis. **NO LLM lib** → rule-based summary only.
- `.env.example` — no AI/LLM keys; DATABASE_URL sqlite:///./ignitia.db.
- `app/schemas.py` — `ok(data=)`, `fail(msg)` envelope helpers + `*_json` serializers; follow for Task + dashboard payloads.
- `tests/` — conftest.py TestClient pattern; 68 tests green @ dbdf41d.

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| New `app/routers/dashboard.py` (not scattered per router) | All aggregates are cross-domain; one endpoint family keeps client simple |
| Chart metrics computed server-side, returned as `[{label, count}]` | Client stays dumb; 4 fixed metric keys |
| Length of Service buckets: <1y, 1-3y, 3-5y, 5-10y, 10+y from `joining_date` | Standard tenure bands |
| Gender Diversity from new `gender` col (seed: mix) | Spec requires it; field didn't exist |
| Job Level from new `job_level` col (seed: Staff/Supervisor/Manager/Director by type_id+department) | Spec requires it |
| Employment Status from new `employment_status` col (seed Full-time/Contract/Intern) | Spec requires it; status_id is active/inactive only |
| Task = new table (company-scoped assign) | Spec item 17; no existing model |
| aiSummary = template sentences over /Dashboard/summary + whoIsOff + contractProbation | Deterministic, testable, zero external deps |
| Who's Off window param `days` default 7, min today | Spec: "dalam periode tertentu" |
| Contract/Probation window 30 days incl. past-30-day overdue flag | "mencapai atau mendekati" — both directions |
| fl_chart (not syncfusion/chart) | Minimal, web-compatible, no license concerns |
| Profile dropdown replaces UserInfoWidget card; old layout preserved via shared-prefs toggle (spec item 8 "Switch to old navigation") | Literal spec compliance |
| `ComingSoonPage(feature)` generic placeholder w/ icon | One widget serves ~10 missing modules |
| New endpoints use clean snake_case JSON (not legacy odd casing) | New client models only; no Android mirror needed (dashboard is web-only) |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| PowerShell 5.1 `String.Matches` missing | `[regex]::Matches($str, $pattern)` static |
| `Get-ChildItem -Recurse -Depth 2` returned nothing (filter quirk) | Used Glob tool instead |
| Reference image not viewable (model limitation) | docx = source of truth; flagged for user visual review |

## Resources
- `ignitia_server/app/migrations.py:14-34` — idempotent ALTER pattern to extend
- `ignitia_server/app/routers/leave.py:30-63` — leave summary shape (reuse for Balance Time Off)
- `ignitia_dashboard/lib/repo/api_service.dart:26-178` — Retrofit method patterns to copy
- `ignitia_dashboard/lib/views/shift/shift_page.dart` — TrinaGrid + toolbar + loading/error pattern for TaskPage
- `ignitia_dashboard/lib/utils/navigation_utils.dart` — `openNewUI(context, page)` navigation convention
- docx spec text extracted: `C:\Users\Yongky\AppData\Local\Temp\opencode\dashboard_docx_text.txt` (session scratch)
