# Task Plan: Dashboard Super-Admin Layout (Ignitia-style home)

## Goal
Rebuild `DashboardHomeScreen` (ignitia_dashboard, Flutter Web) into the Ignitia Super-Admin dashboard per `C:\Users\Yongky\Downloads\ignitia\dashboard.docx` — top bar (8 items), Super-Admin menu bar, and 10 dashboard cards (Shortcuts, Chart, Quick Links, Balance Time Off, Applications, Announcement, Contract & Probation, Task, Who's Off, Download Mobile) — backed by new FastAPI endpoints, employee schema columns, and a Task model.

**NOTE:** Reference image `[Image 1]` / `dashboard.jpg` NOT viewable (no image input). Layout follows the docx's 19-element order in a standard Ignitia card grid. User to flag visual mismatches after smoke test.

## Next Step
Phase 6 complete — awaiting user visual review (no commit unless asked)

## Current Phase
Phase 6: Layout Alignment (reference image)

## Phases

### Phase 0: Planning Init (planning-with-files)
- [x] Restore prior state: read root task_plan/findings/progress (Phases 1-8 complete, committed), git tree clean @ dbdf41d
- [x] Extract docx spec (96 paragraphs, 19 elements) via zip/XML parse → spec text saved
- [x] Audit dashboard app (main.dart, dashboard_home_screen.dart, menu_page.dart, menu_list.dart, string.dart, user_info_section.dart, api_service.dart, pubspec.yaml)
- [x] Audit server (models.py, migrations.py, routers/*, requirements.txt — no LLM)
- [x] Clarify 4 scope questions → full stack, add DB cols, rule-based AI, placeholder pages (all recommended)
- [x] Create isolated plan `.planning/2026-09-03-dashboard-super-admin/` + set active
- **Status:** complete

### Phase 1: Implementation — Server (ignitia_server)
- [x] **1a Schema**: `app/models.py` employees + nullable `gender`/`job_level`/`employment_status`/`contract_end_date`; new `Task` model (id, assigned_employee_id, assigned_by, title, description, due_date, status Open/InProgress/Done, created_at, updated_at); `app/migrations.py` additive ALTERs; `app/schemas.py` TaskIn + task_json; `app/seed.py` `seed_employee_dashboard_fields` backfill (deterministic, NULL-only)
- [x] **1b Router** `app/routers/dashboard.py` + register in `main.py`:
  - `GET /Dashboard/summary` (headcount, present/late/absent today, on_leave, pending approvals, upcoming leaves 7d)
  - `GET /Dashboard/employeeChart?metric=employment_status|length_of_service|job_level|gender_diversity`
  - `GET /Dashboard/whoIsOff?days=7` (approved leaves overlapping window, merged per employee)
  - `GET /Dashboard/contractProbation?window_days=30` (probation via permanent_date + contract_end_date, ±window, days_remaining, sorted)
  - `GET /Dashboard/aiSummary` (rule-based text, no external LLM)
  - `GET/POST/PUT/DELETE /Tasks` (CRUD, admin write, any-auth read)
- [x] **1c Tests** `tests/test_dashboard.py` 11 tests — full suite **79 passed** (was 68)
- **Status:** complete

### Phase 2: Frontend Data Layer (ignitia_dashboard)
- [x] `pubspec.yaml` + `fl_chart: ^1.2.0`; `flutter pub get`
- [x] `api_service.dart` + endpoints (Dashboard summary/chart/whoIsOff/contractProbation/aiSummary, Leave/getEmployeeLeaveSummary, Tasks CRUD) → build_runner regen `api_service.g.dart`
- [x] `TaskModel` + generated `task_model.g.dart`
- [x] `DashboardService` (repo/dashboard_services.dart, Success/Failed pattern) + `DashboardViewModel` (parallel per-card load, metric/days/category switchers, task CRUD, unread count) registered in `main.dart`
- [x] `string.dart` + ~80 English dashboard constants
- **Status:** complete
- **BLOCKER RESOLVED:** no Flutter SDK on machine → installed Flutter 3.47.2 (Dart 3.13.2) to `C:\tools\flutter`. Pinned toolchain (analyzer 7.7.1) cannot parse Dart 3.13 AST → upgraded dev deps (json_serializable 6.14.1, retrofit_generator 10.2.10, build_runner 2.16.1, json_annotation 4.12.0 → analyzer 14.3.0). build_runner Access-Denied in repo (file watcher/AV lock on .dart_tool) → reliable 16s build in temp copy `C:\Users\Yongky\AppData\Local\Temp\opencode\ignitia_dash_build`, copy generated files back.
- **PRE-EXISTING BUGS FIXED (never compiled on this machine):** `menu_page.dart` missing class closing brace; `TitleTextView`/`SubTitleTextView`/`MarqueeTextView` non-const ctors used as const (25 errors); `CustomAppBar` missing `actions` param (3 errors) → **flutter analyze: 0 errors** (237 pre-existing lints remain), **flutter test: 4/4 pass**

### Phase 3: Frontend UI (ignitia_dashboard)
- [x] **Top bar** (items 1-8) `views/home/top_bar_widget.dart`: logo→Company settings, Core&Non-Core (showMenu), Summarize Data (AiSummaryDialog), Quick Action dropdown, Search (→EmployeeListPage searchQuery), Inbox + unread badge, Switch App dropdown, Profile dropdown (9 items incl. PIC dialog + old-nav toggle via SessionManager.useOldNavigation)
- [x] **Sidebar** rebuild `menu_list.dart`: Home, Employee profile, Employees, Recruitment, Time (10 children), Finance, Payroll, Productivity, Company (6), Applications (9), Integrations, Settings (5), Sign Out — typeId filter kept; missing → ComingSoonPage
- [x] **Card grid** (items 10-19) `views/home/dashboard/*`: shortcut_card, chart_card (fl_chart pie + legend + metric dropdown), quick_links_card, balance_time_off_card (hides unlimited), applications_card (9 tiles), announcement_card (category filter + Manage), contract_probation_card, task_card, whos_off_card (period dropdown), download_mobile_card (App Store/Google Play)
- [x] **New pages**: `views/inbox/inbox_page.dart` (notifications + mark-read), `views/task/task_page.dart` (list + create dialog + status dropdown), `views/common/coming_soon_page.dart`
- [x] `dashboard_home_screen.dart` rewired: TopBar + MenuPage + 2-col (wide) / 1-col (narrow) card grid; **old navigation layout preserved** behind shared-prefs toggle
- [x] `employee_list_page.dart` + searchQuery param (name/employeeId/email/designation filter)
- [x] flutter analyze: **0 errors** (272 pre-existing lints)
- **Status:** complete

### Phase 4: Testing & Verification
- [x] `flutter analyze`: **0 errors** (272 pre-existing lints: use_super_parameters, withOpacity deprecation, unused imports)
- [x] `flutter test`: 4/4 pass
- [x] `pytest`: 79/79 pass (5.53s)
- [x] **Live smoke test** (server :86, temp admin smoke@ignitia.local, removed after): Login → Dashboard/summary (3 employees, all counters) ✓; employeeChart ×4 metrics (employment_status Full-time 2/Unspecified 1, gender Male 1/Female 1/Unspecified 1, tenure Unknown 3, job_level Manager 2/Unspecified 1) ✓; whoIsOff + contractProbation + leaveSummary → valid `{"isSuccess":true,"data":[]}` (dev DB has no leave types/contract dates) ✓; aiSummary 5-line rule-based text ✓; Tasks create→list→update(Done)→delete→404-on-second-delete ✓
- [x] `flutter build web --release`: **Built build/web** (exit 0, 205s compile) — full app compiles
- **Status:** complete

### Phase 5: Delivery & Close-out
- [x] Planning files updated; server stopped; smoke account deleted; git status reviewed (no commit per policy)
- [ ] User visual review of layout vs reference image (I cannot view images)
- **Status:** complete

### Phase 6: Layout Alignment (reference image, new docx `Downloads/ignitia spec/dashboard.docx`)
- [x] Viewed embedded layout image (word/media/image1.png): greeting + alert banner, 4 chart panels, tabbed feed, balance rows, promo banner, New badges, Today dropdown
- [x] VM: `_charts` map (all 4 metrics parallel) + `refreshCharts()` + `pendingApprovalsTotal`; who's-off default = Today (days=1)
- [x] `shortcut_card.dart` → horizontal pills; new `greeting_card.dart` (time greeting + date + pills)
- [x] `chart_card.dart` → `ChartSection`: responsive 4/2/1 panels (Employment stacked-bar+legend+%, Length BarChart, Job stacked, Gender donut+legend), ⋮ refresh + Filter footer each
- [x] New `feed_tabs_card.dart`: Announcement / Contract & Probation / Tasks tabs + shared Filter + Search (per-tab filter options, client-side search); deleted superseded announcement_card/contract_probation_card/task_card
- [x] `balance_time_off_card.dart` → per-type blocks (title + N Days + request link) + View all; `applications_card.dart` New badges; `whos_off_card.dart` Today/Next-7/14/30 dropdown + date strip; new `promo_banner_card.dart`
- [x] `top_bar_widget.dart`: "HRIS" label; `dashboard_home_screen.dart`: alert banner + greeting + charts + 3-col (left/center/right) layout + narrow stacking
- [x] Skipped: Company ID footer (no company id available client-side)
- [x] Verify: analyze 0 errors, flutter test 4/4, build web release exit 0
- **Status:** complete

## Key Questions
1. Scope depth? → **Resolved: full stack** (new endpoints + Task model/migration, real data in every card).
2. Chart data source (gender/job_level/employment_status missing in DB)? → **Resolved: add nullable DB columns + seed backfill.**
3. "Summarize data" AI mechanism? → **Resolved: rule-based server-side summary from real aggregates; no LLM dependency.**
4. Missing modules (Recruitment, Finance, Payroll, Productivity, Forms, Performance Review, Talentics, Marketplace...)? → **Resolved: placeholder `ComingSoonPage` so layout matches reference exactly.**
5. Language of new labels? → **English** (matches reference spec; existing bilingual pages untouched).
6. Reference image viewable? → **NO** — layout per docx order + standard Ignitia grid; user visual review after smoke.

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Isolated plan dir `.planning/2026-09-03-dashboard-super-admin/` | Prior root plan (Phases 1-8) complete+committed; keep its record, give new task clean state |
| Additive nullable employee columns + migrations.py ALTER pattern | Existing `ignitia.db` keeps working; matches `migrations.py:22-33` precedent |
| Rule-based `/Dashboard/aiSummary` | No LLM in requirements.txt/env; deterministic, testable, no key management |
| `fl_chart` for chart card | Lightweight, Flutter-native, works on web; no other chart lib in pubspec |
| Balance Time Off reuses `GET /Leave/getEmployeeLeaveSummary` | Endpoint already computes entitlement/taken/balance per leave type |
| Announcement card reuses `GET /Announcements` | Data exists; add client-side category (audience) filter + Manage → existing page |
| Who's Off = approved `user_leaves` overlapping [today, today+days] | Matches spec "karyawan yang sedang mengambil cuti dalam periode tertentu" |
| Contract & Probation window = 30 days, probation via `permanent_date` | No contract dates today → add `contract_end_date`; probation end already modeled |
| Profile "Switch to old navigation" = shared-prefs toggle | Keeps pre-update home layout accessible per spec item 8 |
| Quick Action/Search/Inbox/Switch App wired to real pages where they exist, placeholders otherwise | Full-stack scope but pragmatic: no new request flows beyond Task |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| PS `String.Matches` not available in PS 5.1 | 1 | Use `[regex]::Matches($s, $pattern)` static method |

## Notes
- Docx spec text: elements 1-8 top bar, 9 menu bar, 10-19 dashboard cards (extracted 2026-09-03, see findings.md).
- Dashboard app is Flutter Web + Provider + Retrofit/dio; server is FastAPI + SQLAlchemy/SQLite with idempotent startup migrations.
- `webWidth` constant gates sidebar visibility (responsive) — keep behavior.
- Update status pending→in_progress→complete per phase; Next Step always single action.
