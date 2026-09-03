# Findings & Decisions — Time Management

## Requirements
- Menu induk Manajemen Waktu mengelola seluruh pengaturan waktu: **Jadwal Kerja, Kehadiran, Istirahat, Cuti, Timesheet**.
- Add-on **Liveness** pada Kehadiran & Istirahat.
- Klarifikasi user (2026-09-03):
  1. Istirahat cukup 1 tipe → single config per company.
  2. Timesheet weekly HR approval + export → ya.
  3. Liveness per company (billing) → flag di companies.
  4. Jadwal Kerja pola roster mingguan (Senin-Minggu beda shift) → template weekly JSON.
  5. Bilingual ID/EN.

## Research Findings
- `ignitia_dashboard/lib/utils/menu_list.dart:11` — `MenuList._menuList` flat: Home(1), EmployeeList(3), ApproveOvertime(13), Holiday(18), Shift(20), AssignShift(21), SignOut(99). Tidak ada parent grouping. `MenuItemModel:2` hanya `id,name,typeId,page`.
- `ignitia_dashboard/lib/views/menu_page.dart:26` — `ListView.builder:41` flat + `MenuPage:26` split `MediaQuery`. Belum ada ExpansionTile.
- `ignitia_dashboard/lib/utils/string.dart:214-242` — strings Shift ada (`titleShiftPage`, `colHeaderShiftName` etc.), belum ada `titleTimeManagement`.
- `ignitia_android/lib/utils/menu_list.dart:27` — flat 16 item, typeId [1]/[2] filter, Settings(98) remove di web `getMenuList:52`.
- `ignitia_server/app/models.py:103` — Attendance, AttendanceEditRequest, Overtime, UserLeave ada; **Shift/Timesheet/Break/WorkSchedule hilang** padahal client `shift_model.dart:8` kontrak pakai Shift.
- `ignitia_server/app/main.py:76` — routers tidak include shift/work_schedule/break/timesheet.
- `ignitia_server/app/security.py:381-462` — `issue_liveness_challenge()`, `validate_liveness_frames(required, challenge_id)` siap reuse, cek `MIN_LIVENESS_FRAMES:60`, `LIVENESS_MIN_DIVERSITY:63`, single-use challenge `consume_liveness_challenge:396`.
- `ignitia_server/app/routers/attendance.py:87,95,168` — check_in/out validasi 3 lapis geo-fence `is_within_office:115` + face `verify_face:324` + liveness, `userAttendanceSummary:254` hitung `late_days/overtime`, `approveAttendance:444` pattern 1 Pending 2 Approved 3 Rejected.
- `ignitia_server/app/config.py:59` — `LIVENESS_REQUIRED` global, `FACE_*` thresholds, `OFFICE_*` geo.
- `ignitia_server/app/schemas.py:31` — `AttendanceIn` toleran extra fields, `attendance_json:217` shape untuk client.
- `ignitia_android/lib/view_models/home_view_model.dart:143` — `checkIn({faceImageBase64,livenessFrames,challengeId})` kirim frames; `attendance_view_model.dart:68` edit attendance sama.
- `ignitia_dashboard/lib/views/shift/shift_page.dart:46` + `holiday_page.dart:129` — pattern TrinaGrid + Toolbar Add + Stack Loading/ErrorPopup, reusable untuk Break/Timesheet/Schedule.
- `ignitia_dashboard/lib/models/shift/shift_model.dart:36` — `getTotalHours()` handle cross-midnight, `getStatusAsString`.
- `ignitia_dashboard/lib/repo/shift_services.dart:11` + `api_service.dart:73` — client contract `GET Shift/getShiftList`, `POST Shift` etc.

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| Parent 30 Time Management + children 31-35 | Satukan fragmentasi shift/holiday/attendance/overtime jadi IA jelas, minimal refactor `menu_list.dart` |
| `MenuItemModel` tambah `children`/`isParent` + `menu_page.dart` ExpansionTile | Support collapsible parent tanpa breaking flat list lama |
| Single-row `CompanyBreakConfig` | 1 tipe istirahat → 1 config per company (duration 60, window 12-13, paid, liveness_required, is_active) |
| `Company.liveness_addon_active` + `liveness_addon_expires_at` | Per-company billing, guard di `validate_liveness_frames` & `attendance.py:116` |
| Weekly roster `WorkScheduleTemplate{weekly_pattern JSON {1..7:shiftId}}` + `EmployeeRoster` | Roster mingguan per Q4, extend assign dari rentang tanggal `assign_shift_page.dart:94` |
| Timesheet `TimesheetEntry` harian + `TimesheetPeriod` mingguan + export | Weekly HR approve + download xlsx/pdf per Q2, reuse `attendance.py:254` summary logic |
| Generic `/Liveness/challenge` alias | Reuse `attendance.py:87` challenge untuk Kehadiran & Istirahat, anti-replay single-use |
| Bilingual helper di `string.dart` | Q5, contoh `titleTimeManagement = "Time Management / Manajemen Waktu"` atau helper locale `Intl.getCurrentLocale()` |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| Shift table missing di server tapi client pakai | Re-add `Shift` table sesuai `shift_model.dart` contract, tambah ke `models.py` + router |
| Plan mode blocks file write | Draft inline dulu, materialisasi setelah build mode |
| init-session.ps1 hanya template default | Overwrite dengan draft detail |

## Resources
- `ignitia_dashboard/lib/views/shift/shift_page.dart:23` — TrinaGrid + Toolbar pattern
- `ignitia_dashboard/lib/views/admin/leave/holiday_page.dart:21` — holiday CRUD reference (akan pindah ke Cuti)
- `ignitia_server/app/security.py:115,324,407` — geo/face/liveness
- `ignitia_server/app/routers/attendance.py:87,95,254,444` — attendance lifecycle & approval
- `ignitia_server/app/config.py:18,59` — Settings env
- `ignitia_android/lib/repo/api_service.dart:64` — livenessChallenge endpoint

## Findings — Phase 8 Settings (2026-09-03)
- Klarifikasi final: 5 submenu, hanya admin `[1]`, MVP stub `_ApiHint` tanpa tabel baru, Android parent 90 ganti flat 98, paralel Dashboard+Android.
- `ignitia_dashboard/lib/utils/menu_list.dart:25` — parent 30 Time + parent 40 Company sudah pakai `MenuItemModel:2` children/isParent + `menu_page.dart:63` ExpansionTile — reuse untuk Settings parent 90.
- `ignitia_dashboard/lib/utils/string.dart:277` — Company hub keys ada, Settings hub belum ada — perlu 6 keys baru bilingual.
- `ignitia_android/lib/utils/menu_list.dart:26-63` — flat `_menuList:27` 16 item, `SettingsPage(98)` hidden web `removeWhere:63`, `ProfilePage` dll — refactor ke parent 90 + `_parentItem` seperti dashboard `menu_page.dart:63-77`.
- `ignitia_android/lib/views/menu_page.dart:18-97` — flat `ListView.builder:52` tanpa hasChildren — perlu port ExpansionTile branch.
- `ignitia_android/lib/views/settings_page.dart:17` — 7 field lokal SharedPreference — keep legacy, 5 sub-page baru di `views/settings/`.
- `ignitia_server/app/models.py:22-459` — Company, Shift, Break, PtkpStatus etc. cukup untuk _ApiHint referral — MVP tidak tambah tabel.
- MVP pattern validated `company_admin/file/company_file_page.dart:22` `_ApiHint` + polish container `Colors.white` `Border.all(Colors.grey.shade200)` — reuse untuk 5 Settings pages.

## Visual/Browser Findings
- Tidak ada screenshot/browser; semua evidence via codegraph read verbatim.
