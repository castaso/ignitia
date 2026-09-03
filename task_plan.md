# Task Plan: Time Management + Company Administration Hub

## Goal
Membangun (1) Time Management / Manajemen Waktu (roster mingguan, kehadiran, istirahat 1-tipe, cuti, timesheet + liveness per-company bilingual) + (2) **Company / Perusahaan Hub** untuk administrasi: Aset (semua kategori/status), Activity History (reuse AuditLog), Announcements → in-app Notifications, Files private per-uploader (admin monitor), Report Builder CSV Timesheet only.

## Next Step
Done — Phases 1-7 complete. Next: flutter build_runner for api_service.g.dart if needed.

## Current Phase
Phase 7: Company Administration Hub (complete)

## Phases

### Phase 1: Requirements & Discovery
- [x] Eksplorasi MenuList dashboard `ignitia_dashboard/lib/utils/menu_list.dart:11` flat, Android `ignitia_android/lib/utils/menu_list.dart:27` flat 15 item
- [x] Audit strings `ignitia_dashboard/lib/utils/string.dart:214`, models `ignitia_server/app/models.py:103`, security `ignitia_server/app/security.py:381` liveness
- [x] Klarifikasi 5 poin: 1 tipe istirahat, weekly HR approve+export, per-company liveness, roster mingguan, bilingual
- [x] Draft task_plan/findings/progress inline (plan mode), init planning files via init-session.ps1
- **Status:** complete

### Phase 2: Planning & Structure
- [x] Define IA: parent 30 Time Management → children 31 Jadwal Kerja, 32 Kehadiran, 33 Istirahat, 34 Cuti, 35 Timesheet
- [x] Tentukan model: Shift re-add, WorkScheduleTemplate weekly JSON, Company.liveness_addon, CompanyBreakConfig single row, BreakSession, TimesheetEntry/Period
- [x] Tentukan kontrak API & guard liveness per-company, bilingual strategy
- [x] Refresh findings.md & progress.md
- **Status:** complete

### Phase 3: Implementation — Server (ignitia_server)
- [x] `app/models.py` tambah Shift, WorkScheduleTemplate, EmployeeRoster, CompanyBreakConfig, BreakSession, TimesheetEntry + Company.liveness_addon_active/expires_at/attendance_liveness/break_liveness
- [x] `app/schemas.py` ShiftIn/WorkScheduleTemplateIn/BreakConfigIn/BreakSessionIn/TimesheetIn + json helpers, `app/config.py` BREAK_DEFAULT_*, `routers/attendance.py` per-company gate + `/Liveness/challenge` alias
- [x] Routers: shift, work_schedule, breaks, timesheet + register di `app/main.py:15,76`
- [x] Tables created via Base.metadata.create_all (shifts, work_schedule_templates, employee_rosters, company_break_configs, break_sessions, timesheet_entries) — 68 tests pass
- **Status:** complete

### Phase 4: Implementation — Flutter (Dashboard + Android)
- [x] `lib/utils/string.dart` bilingual keys Time Management, `lib/models/menu_item_model.dart:2` children/isParent/hasChildren, `lib/utils/menu_list.dart:11` hierarki parent 30 (7 children), legacy shift entries kept
- [x] `lib/views/menu_page.dart:60` ExpansionTile parent + _childItem, `lib/views/time_management/**` 7 stub pages (schedule_template, roster, attendance_tm, break_config, break_history, leave_tm, timesheet)
- [x] `lib/repo/api_service.dart:73` 13 new endpoints WorkSchedule/Break/Timesheet/Liveness, Android strings+menu_list mirrored
- **Status:** complete

### Phase 5: Testing & Verification
- [x] Server import ok + tables created + 68 pytest passed
- [x] Manual QA: Shift CRUD, Break config GET/PUT, WorkScheduleTemplate weekly {1..7}, Timesheet generate 3 entries, Liveness alias — all green via TestClient
- **Status:** complete

### Phase 6: Delivery (Time Management)
- [x] Review, docs bilingual, handover, polish schedule/break/timesheet UI + companies liveness expires fix (`1cd0909`)
- **Status:** complete

### Phase 7: Company Administration Hub (Administrasi Perusahaan)
- [x] Klarifikasi: Q1 semua kategori/status aset, Q2 reuse AuditLog, Q3 in-app notif saja, Q4 files private per-uploader admin monitor, Q5 CSV timesheet export saja
- [x] Server: CompanyAsset (5 status, 4 kategori), Announcement, Notification, CompanyFile + ActivityLogs (reuse AuditLog:272) + COMPANY_FILE_DIR via UPLOAD_DIR/company_files
- [x] Routers: company_assets, announcements (publish fan-out), notifications (in-app), company_files (private 20MB), activity_logs + register main.py:15 (68 tests pass, manual QA Asset/Ann/Publish/Notif green)
- [x] Flutter: strings Company hub bilingual, menu_list parent 40 +6 children, menu_page ExpansionTile reuse, views/company_admin/** 6 polished pages, api_service +12 endpoints, android mirror
- [x] Verify: pytest 68 pass, create_all 4 tables, manual QA green, pushed `3fbc757` → origin/main
- **Status:** complete

## Key Questions
1. Durasi istirahat default 60m window 12:00-13:00 OK? → **Resolved: OK, configurable per company via CompanyBreakConfig.**
2. Export Timesheet format wajib xlsx + pdf? → **Resolved: CSV dulu (MVP), xlsx/pdf next.**
3. Roster perlu override per-karyawan? → **Resolved: EmployeeRoster.override_json nullable.**
4. Liveness expiry per-company? → **Resolved: companies.liveness_addon_expires_at nullable + gate.**
5. Company aset semua kategori? → **Resolved: IT/Kendaraan/Furniture/Lainnya + 5 status (Q1 semua).**
6. Activity History reuse AuditLog? → **Resolved: ya (Q2).**
7. Announcements → email/push? → **Resolved: in-app notif saja (Q3).**
8. Files private per-uploader? → **Resolved: private per-uploader, admin monitor all (Q4).**
9. Report Builder scope? → **Resolved: CSV Timesheet export saja (Q5).**

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Hierarki parent 30 Time Management | Kelompokkan 5 submenu, cegah flat menu `menu_list.dart:12-20` |
| Single-row CompanyBreakConfig | Q1 TM: 1 tipe saja, sederhanakan CRUD |
| Weekly Timesheet + HR approve | Q2 TM: reuse `attendance.py:444` approvalStatusId 1/2/3 |
| Liveness per company `companies.liveness_addon_active` | Q3 TM per-company billing, guard di `validate_liveness_frames` |
| Weekly roster JSON {1..7: shiftId} | Q4 TM roster mingguan, extend `assign_shift_page.dart:94` rentang → pola mingguan |
| Bilingual string helper | Q5 TM ID/EN fallback EN |
| Re-add Shift backend missing | Client `shift_model.dart:8` kontrak harus ada server table |
| Company hub parent 40 all admin data | Q1 Company: aset semua kategori/status, activity reuse AuditLog, in-app notif, files private, CSV report |
| Files private per-uploader admin monitor | Q4 Company: `CompanyFile.uploader_id` + admin override `?all=true` + require_admin |
| Activity reuse AuditLog | Q2 Company: tidak noisy view-tracking, cukup audit existing |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| Shift model hilang di `models.py` (tidak ada table Shift) | 1 | Re-add tabel Shift konsisten kontrak client `api_service.dart:73` |
| Plan mode blocks write | 1 | Sajikan draft inline, tulis setelah build mode via init-session.ps1 |
| init-session.ps1 default template overwrite | 1 | Overwrite dengan draft detail Time Management |

## Notes
- Liveness reuse `security.py:381` challenge + `attendance.py:87` challenge endpoint → generic `/Liveness/challenge`.
- Timesheet: `work_minutes = (check_out - check_in) - break_duration - late`, break tidak hitung jam kerja.
- Update status pending→in_progress→complete per phase; Next Step selalu single action.
