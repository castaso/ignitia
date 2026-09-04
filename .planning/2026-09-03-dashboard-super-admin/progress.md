# Progress Log

## Session: 2026-09-03 — Dashboard Super-Admin Layout

### Phase 0: Planning Init (planning-with-files)
- **Status:** complete
- **Started:** 2026-09-03
- **Completed:** 2026-09-03
- Actions taken:
  - Restored prior state: root task_plan/findings/progress = Time Mgmt + Company Hub + Settings (Phases 1-8 complete, committed @ dbdf41d); `git status` clean
  - Extracted docx (120KB, word/document.xml) → 96 paragraphs, 19 dashboard elements (text only; image not viewable)
  - Audited: dashboard_home_screen.dart, menu_page.dart, menu_list.dart, string.dart, user_info_section.dart, api_service.dart, pubspec.yaml, main.dart | server models.py, migrations.py, leave.py, router list, requirements.txt, .env.example
  - Clarified 4 scope questions (full stack / add DB cols / rule-based AI / placeholder pages) — all "recommended" chosen
  - Created isolated plan dir `.planning/2026-09-03-dashboard-super-admin/` (task_plan.md, findings.md, progress.md) — prior root plan preserved
- Files created: `.planning/2026-09-03-dashboard-super-admin/task_plan.md`, `findings.md`, `progress.md`

### Phase 1: Implementation — Server
- **Status:** complete
- **Started:** 2026-09-03
- **Completed:** 2026-09-03
- Actions taken:
  - `models.py`: Employee +gender/job_level/employment_status/contract_end_date (nullable); new Task table at EOF
  - `migrations.py`: 4 new employees ALTERs (idempotent pattern)
  - `schemas.py`: TaskIn + task_json(assignee_name, created_by_name)
  - `seed.py`: `seed_employee_dashboard_fields` — deterministic NULL-only backfill (gender alt by id, job_level by type/id, employment_status Contract i%6 / Intern i%9, contract_end_date 10+i%45 days, demo probation dates near today)
  - `routers/dashboard.py` (new, ~400 lines): summary, employeeChart (4 metrics, ordered buckets), whoIsOff (days 1-60, merged per emp), contractProbation (±window, sorted by days_remaining), aiSummary (rule-based 5-para text), Tasks CRUD (admin write)
  - `main.py`: dashboard.router registered; seed call in lifespan
  - `tests/test_dashboard.py`: 11 tests (admin gates, shape, 4 metrics, bogus metric, who's off window, contract window+ordering+exclusion, aiSummary, tasks full lifecycle)
- Files created: `app/routers/dashboard.py`, `tests/test_dashboard.py`
- Files modified: `app/models.py`, `app/migrations.py`, `app/schemas.py`, `app/seed.py`, `app/main.py`
- Verify: **pytest 79 passed** (68 old + 11 new) 8.95s

### Phase 2: Frontend Data Layer
- **Status:** complete
- **Started:** 2026-09-03
- **Completed:** 2026-09-03
- Actions taken:
  - `pubspec.yaml` + fl_chart ^1.2.0; dev toolchain upgrade (json_serializable 6.14.1, retrofit_generator 10.2.10, build_runner 2.16.1, json_annotation 4.12.0 → analyzer 14.3.0) after discovering pinned analyzer 7.7.1 cannot parse Dart 3.13 AST
  - `api_service.dart` +10 endpoints (Dashboard ×5, Leave summary, Tasks CRUD ×4); build_runner regen in temp copy (in-repo build hits Access-Denied on .dart_tool — file watcher/AV lock); copy generated files back
  - `task_model.dart` + generated; `dashboard_services.dart` (Success/Failed wrappers); `dashboard_view_model.dart` (parallel loadAll, switchers, task CRUD, unread count); registered in main.dart
  - `string.dart` +~80 dashboard constants
  - **Pre-existing compile bugs fixed:** menu_page.dart missing class `}` (13 open/12 close); TitleTextView/SubTitleTextView/MarqueeTextView non-const ctors (25 errors); CustomAppBar missing `actions` param (3 errors)
- Files created: `lib/models/task/task_model.dart(+.g)`, `lib/repo/dashboard_services.dart`, `lib/view_models/dashboard_view_model.dart`
- Files modified: pubspec.yaml/lock, api_service.dart(+.g), main.dart, string.dart, shared_preference.dart, textview_widget.dart, app_bar_widget.dart, menu_page.dart, 16 regenerated .g.dart, analysis_options.yaml
- Verify: flutter analyze **0 errors** (237 pre-existing lints), flutter test 4/4

### Phase 3: Frontend UI
- **Status:** complete
- Actions taken:
  - `top_bar_widget.dart` (items 1-8): logo→CompanySettings, Core&Non-Core showMenu (showMenu API changed in Flutter 3.47: items+Future), AiSummaryDialog (StatefulWidget), Quick Action dropdown, Search→EmployeeListPage(searchQuery), Inbox+badge, Switch App, Profile dropdown (9 items, PIC dialog, old-nav toggle)
  - `menu_list.dart` Super-Admin rebuild (13 top entries incl. Time×10, Company×6, Applications×9, Settings×5 children)
  - 10 cards in `views/home/dashboard/`: shortcut, chart (fl_chart 1.2.0 PieChart — `center` param removed in 1.x → Stack overlay), quick_links, balance_time_off, applications, announcement, contract_probation, task, whos_off, download_mobile + dashboard_card shell
  - New pages: inbox_page, task_page (CRUD + status dropdown), coming_soon_page
  - `dashboard_home_screen.dart` rewired (TopBar + 2col/1col grid) + legacy layout preserved behind useOldNavigation toggle
  - `employee_list_page.dart` searchQuery filter (name/employeeId/email/designation)
  - Fixed 28 analyze errors across first UI pass (Icons import in menu_list, form_filled_outlined→assignment_outlined, Map<String,IconData>, DropdownMenuItem<int?>, showMenu API, fl_chart center, TaskModel.fromJson cast)
- Verify: flutter analyze **0 errors** (272 pre-existing lints)

### Phase 4: Testing & Verification
- **Status:** complete
- Actions taken:
  - flutter analyze 0 errors; flutter test 4/4; pytest 79/79 (5.53s)
  - Live smoke (server :86 via Start-Process, temp admin smoke@ignitia.local): all 6 Dashboard endpoints + leaveSummary + Tasks CRUD verified end-to-end via REST; smoke account deleted; server stopped
  - `flutter build web --release` → **Built build/web** (exit 0)
- Test Results:
  | Test | Expected | Actual | Status |
  |------|----------|--------|--------|
  | flutter analyze | 0 errors | 0 errors, 272 lints (pre-existing) | ✅ |
  | flutter test | pass | 4/4 | ✅ |
  | pytest | 79 pass | 79 passed 5.53s | ✅ |
  | Dashboard/summary REST | counts | 3 employees, all keys | ✅ |
  | employeeChart ×4 | label/count | all 4 metrics OK | ✅ |
  | whoIsOff/contractProbation/leaveSummary | valid envelope | {"isSuccess":true,"data":[]} | ✅ |
  | aiSummary | text | 5-line rule-based | ✅ |
  | Tasks create/update/delete | lifecycle | Open→Done→deleted→404 | ✅ |
  | flutter build web --release | built | Built build/web (205s) | ✅ |

## 5-Question Reboot Check
| Question | Answer |
|----------|--------|
| Where am I? | Phase 5 close-out; all code + verification done |
| Where am I going? | User visual review of layout vs reference image; commit only if asked |
| What's the goal? | Ignitia Super-Admin dashboard per 19-element docx, full stack |
| What have I learned? | No Flutter on machine → installed 3.47.2; pinned analyzer can't parse 3.13 → toolchain upgrade; in-repo build_runner blocked by file locks → temp-copy build; committed code had never been compiled (missing brace, non-const ctors, missing param) — all fixed |
| What have I done? | Phases 0-4 complete: server (5 dashboard endpoints + Tasks, 79 tests), data layer (VM/services/models/strings), UI (top bar, menu, 10 cards, 3 new pages, old-nav fallback), verify (0 analyze errors, 4/4 flutter, 79/79 pytest, web build, live REST smoke) |

## Error Log
| Timestamp | Error | Attempt | Resolution |
|-----------|-------|---------|------------|
| 2026-09-03 | PS 5.1 `String.Matches` missing in docx extraction | 1 | `[regex]::Matches()` static method |
| 2026-09-03 | DetachedInstanceError in 2 new dashboard tests (emp.id after db.close) | 1 | capture id/name before close |
| 2026-09-03 | No Flutter SDK on machine (dart analyze N/A in prior sessions) | 1 | Installed Flutter 3.47.2 (Dart 3.13.2) to C:\tools\flutter, user PATH |
| 2026-09-03 | build_runner: "SDK language 3.13 > analyzer 3.9" + visitDotShorthandPropertyAccess crash | 1 | Upgraded dev deps → analyzer 14.3.0 (json_serializable 6.14.1, retrofit_generator 10.2.10, build_runner 2.16.1, json_annotation 4.12.0) |
| 2026-09-03 | build_runner in repo: PathAccessException Access-Denied deleting .dart_tool\build_resolvers (also killed runs deleted all 17 .g.dart) | 2 | Restored .g.dart from git; build in temp copy C:\Users\Yongky\...\ignitia_dash_build (16s, reliable), copy generated files back |
| 2026-09-03 | Pre-existing compile bugs (never compiled here): menu_page.dart missing class `}`, const TitleTextView (non-const ctor), CustomAppBar(actions:) | 1 | Added closing brace; made 3 textview ctors const (final fields); added actions param — 28→0 errors |
| 2026-09-03 | Flutter 3.47 API breaks: showMenu(onSelected/itemBuilder) removed; fl_chart 1.2.0 PieChart(center:) removed; Icons.form_filled_outlined gone | 1 | showMenu(items:).then(); Stack overlay for pie center; Icons.assignment_outlined |
| 2026-09-03 | Start-Job server died with session | 1 | Start-Process -WindowStyle Hidden (detached) |
| 2026-09-03 | PowerShell quoting for python -c / heredocs | 2 | Write temp .py file, run it |
