# Rencana Implementasi: Menu Employee

## Ikhtisar

Implementasi backend FastAPI (`ignitia_server`) untuk modul SDM lengkap: tambah/edit/nonaktifkan karyawan, manajemen departemen, riwayat transfer, status PTKP + PPh 21 progresif, impor massal CSV/Excel, Manpower Planning, Replacement Tracking, dan audit log. Semua endpoint baru mengikuti pola respons envelope yang sudah ada (`{"isSuccess", "message", "data"}`). Flutter client tidak diubah.

## Tasks

- [ ] 1. Foundation — Model, Dependency, Migrasi
  - [ ] 1.1 Tambahkan model-model baru ke `app/models.py`
    - Tambahkan class `Department` (kolom: id, name, code, is_active)
    - Tambahkan class `EmployeeTransfer` (kolom: id, employee_id, from/to_department_id, from/to_designation, effective_date, reason, created_by, created_at)
    - Tambahkan class `PtkpStatus` (kolom: id, code, description, annual_value)
    - Tambahkan class `PtkpStatusHistory` (kolom: id, employee_id, old/new_ptkp_status_id, effective_date, changed_by, created_at)
    - Tambahkan class `ManpowerPlan` (kolom: id, department_id, designation, plan_year, plan_month, target_headcount, notes, created_by, created_at)
    - Tambahkan class `ReplacementTracking` (kolom: id, departing/replacement_employee_id, department_id, designation, departure_reason, effective_date, expected_fill_date, fill_date, status, cancellation_reason, created_by, created_at)
    - Tambahkan class `AuditLog` (kolom: id, action, target_employee_id, performed_by, timestamp, changed_fields)
    - Tambahkan kolom `department_id` dan `ptkp_status_id` (nullable) ke class `Employee` yang sudah ada
    - _Persyaratan: 2.5, 5.4, 6.1, 8.1, 9.1, 11.5, 12.1_
    - _Desain: Bagian "Model Data — Definisi Model SQLAlchemy Baru"_

  - [ ] 1.2 Buat `app/migrations.py` untuk kolom baru pada tabel `employees`
    - Buat fungsi `run_migrations(engine)` yang menggunakan `inspect()` untuk memeriksa kolom yang sudah ada
    - Tambahkan `ALTER TABLE employees ADD COLUMN department_id INTEGER` jika belum ada
    - Tambahkan `ALTER TABLE employees ADD COLUMN ptkp_status_id INTEGER` jika belum ada
    - Commit setelah setiap perubahan DDL
    - _Persyaratan: 2.5_
    - _Desain: Bagian "Strategi Migrasi Database"_

  - [ ] 1.3 Tambahkan `require_admin` dependency ke `app/deps.py`
    - Implementasikan fungsi `require_admin(auth: Employee = Depends(get_current_employee)) -> Employee`
    - Lempar `HTTPException(status_code=403, detail="Forbidden")` jika `auth.type_id != 1`
    - _Persyaratan: 1.7, 4.4, 6.7, 7.7, 8.6, 9.1, 11.2_
    - _Desain: Bagian "app/deps.py — Dependency Baru"_

  - [ ] 1.4 Perbarui `app/main.py` untuk memanggil migrasi dan mendaftarkan router baru
    - Import dan panggil `run_migrations(engine)` di dalam fungsi `lifespan` setelah `create_all`
    - Import dan daftarkan router baru (departments, ptkp_statuses, manpower_plans, replacement_tracking) ke `create_app()` dengan prefix `/api`
    - _Desain: Bagian "Arsitektur — Alur Request"_

- [ ] 2. Router Departemen
  - [ ] 2.1 Buat `app/routers/departments.py` dengan endpoint CRUD departemen
    - Implementasikan `GET /api/Departments`: query semua `Department`, kembalikan list dalam envelope
    - Implementasikan `POST /api/Departments` (admin only): validasi nama unik, simpan departemen baru, kembalikan data departemen
    - Implementasikan `PUT /api/Departments/{id}` (admin only): update nama/code/is_active, kembalikan `isSuccess: true`
    - Kembalikan `isSuccess: false` jika nama duplikat pada POST
    - Gunakan Pydantic schema `DepartmentIn` (name, code, is_active) yang didefinisikan di file yang sama atau di `schemas.py`
    - _Persyaratan: 2.1, 2.2, 2.3, 2.4_
    - _Desain: Bagian "app/routers/departments.py"_

- [ ] 3. Router PTKP Statuses + Data Seed
  - [ ] 3.1 Buat `app/routers/ptkp_statuses.py` dengan endpoint GET
    - Implementasikan `GET /api/PtkpStatuses`: query semua `PtkpStatus`, kembalikan list dalam envelope
    - _Persyaratan: 6.2_
    - _Desain: Bagian "app/routers/ptkp_statuses.py"_

  - [ ] 3.2 Buat `app/seed.py` untuk mengisi data awal PTKP
    - Buat fungsi `seed_ptkp_statuses(db)` yang melakukan insert idempotent (skip jika sudah ada) untuk 8 kode PTKP: TK/0 (54jt), TK/1 (58.5jt), TK/2 (63jt), TK/3 (67.5jt), K/0 (58.5jt), K/1 (63jt), K/2 (67.5jt), K/3 (72jt)
    - Panggil fungsi ini dari `lifespan` di `main.py` setelah migrasi
    - _Persyaratan: 6.1_
    - _Desain: Bagian "Data Seed PTKP"_

- [ ] 4. Endpoint Baru pada Router Employees
  - [ ] 4.1 Tambahkan `POST /api/Employees` ke `app/routers/employees.py`
    - Buat Pydantic schema `EmployeeCreateIn` dengan field: name, employee_id, email, department_id, designation, joining_date (wajib); cell_no, address, nid, supervisor_id, basic_salary (opsional)
    - Validasi field wajib tidak kosong; kembalikan `isSuccess: false` + daftar field kosong jika gagal
    - Periksa duplikat `email` dan `employee_id`; kembalikan pesan error spesifik untuk masing-masing
    - Buat record `Employee` baru dengan default `status_id=1`, `type_id=2`, `basic_salary=0.0`
    - Buat record `EmployeeContactInfo` kosong dengan `id` yang sama
    - Gunakan `require_admin` dependency
    - _Persyaratan: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7_
    - _Desain: Bagian "employees.py — Endpoint Baru", "Request body POST /api/Employees"_

  - [ ] 4.2 Tambahkan `PUT /api/Employees/{id}` (admin, update lengkap) ke `app/routers/employees.py`
    - Buat Pydantic schema `EmployeeAdminUpdateIn` mencakup semua field: designation, department_id, supervisor_id, status_id, joining_date, permanent_date, basic_salary, name, cell_no, email, address, nid
    - Ambil karyawan by `id`; kembalikan `isSuccess: false` "Karyawan tidak ditemukan" jika tidak ada
    - Simpan nilai lama `designation` dan `department_id` sebelum update
    - Update semua field yang dikirimkan (non-None)
    - Jika `designation` atau `department_id` berubah, buat record `EmployeeTransfer` baru secara otomatis dengan `created_by = auth.id`
    - Sertakan flag `payroll_recalculation_needed: true` dalam respons jika `basic_salary` berubah
    - Gunakan `require_admin` dependency
    - _Persyaratan: 3.1, 3.2, 3.4, 3.5, 12.3_
    - _Desain: Bagian "employees.py — Endpoint Baru", "Edge Cases — Transfer Otomatis"_

  - [ ] 4.3 Tambahkan `PUT /api/Employees/{id}/deactivate` ke `app/routers/employees.py`
    - Buat Pydantic schema `DeactivateIn` dengan field `effective_date` (str) dan `reason` (str)
    - Ambil karyawan by `id`; kembalikan 404-style fail jika tidak ada
    - Kembalikan `isSuccess: false` "Karyawan sudah berstatus nonaktif" jika `status_id` sudah `2`
    - Set `status_id = 2`, simpan `effective_date` dan `reason` (tambahkan kolom ke model jika belum ada: `deactivate_date`, `deactivate_reason`)
    - Gunakan `require_admin` dependency
    - _Persyaratan: 4.1, 4.2, 4.3, 4.4_
    - _Desain: Bagian "employees.py — Endpoint Baru", "Edge Cases — Nonaktifkan Karyawan"_

  - [ ] 4.4 Tambahkan `GET /api/Employees/{id}/transfers` dan `POST /api/Employees/{id}/transfers`
    - `GET`: query `EmployeeTransfer` by `employee_id`, urutkan terbaru dulu (`ORDER BY created_at DESC`), kembalikan list
    - `POST` (admin only): buat Pydantic schema `TransferIn` (from/to_department_id, from/to_designation, effective_date, reason); validasi department_id ada di tabel `departments`; simpan record baru dengan `created_by = auth.id`
    - Kembalikan `isSuccess: false` jika department tidak ditemukan
    - _Persyaratan: 5.1, 5.2, 5.3, 5.4_
    - _Desain: Bagian "employees.py — Endpoint Baru", "Request body POST transfers"_

  - [ ] 4.5 Tambahkan `PUT /api/Employees/{id}/ptkp` ke `app/routers/employees.py`
    - Buat Pydantic schema `PtkpUpdateIn` dengan field `ptkp_status_id` (int) dan `effective_date` (str)
    - Validasi `ptkp_status_id` ada di tabel `ptkp_statuses`; kembalikan "Kode PTKP tidak valid" jika tidak ada
    - Simpan nilai `old_ptkp_status_id` dari karyawan sebelum update
    - Update `employee.ptkp_status_id`
    - Buat record `PtkpStatusHistory` baru
    - Sertakan flag `payroll_recalculation_needed: true` dalam respons
    - Gunakan `require_admin` dependency
    - _Persyaratan: 6.3, 6.4, 6.5, 6.7, 12.3_
    - _Desain: Bagian "employees.py — Endpoint Baru", "Request body PUT ptkp"_

  - [ ] 4.6 Tambahkan `GET /api/Employees/profile` yang diperluas dan `GET /api/Employees` yang aman
    - Perbarui `employee_json()` di `schemas.py` untuk menyertakan `department_id`, `ptkp_status_id`, `department_name` (join atau sub-query)
    - Perbarui `GET /api/Employees/profile`: sertakan `ptkp_status_code`, `ptkp_annual_value`, `last_transfer_date`, `last_from_designation`, `last_to_designation` dalam respons
    - Perbarui `GET /api/Employees`: jika `auth.type_id == 2`, kembalikan hanya data karyawan sendiri (bukan semua karyawan) untuk memenuhi Persyaratan 11.3
    - _Persyaratan: 10.1, 11.3_
    - _Desain: Bagian "Perubahan pada Employee", "RBAC — Employee mengakses profil orang lain"_

- [ ] 5. Integrasi PTKP ke Kalkulasi Payroll
  - [ ] 5.1 Perbarui `app/routers/payroll.py` dengan kalkulasi PPh 21 progresif
    - Definisikan konstanta bernama untuk layer tarif PPh 21 (sesuai UU HPP 2022): `TAX_BRACKET_1 = 60_000_000` (5%), `TAX_BRACKET_2 = 250_000_000` (15%), `TAX_BRACKET_3 = 500_000_000` (25%), tarif tertinggi 30%
    - Definisikan konstanta `DEFAULT_PTKP = 54_000_000` (TK/0) sebagai fallback
    - Buat fungsi `calculate_annual_pph21(pkp_annual: float) -> float` yang menghitung pajak progresif berdasarkan konstanta layer
    - Buat fungsi `calculate_ait_monthly(gross_monthly: float, ptkp_annual: float) -> float` yang: hitung `annual_gross = gross_monthly * 12`, hitung `pkp = max(0, annual_gross - ptkp_annual)`, panggil `calculate_annual_pph21(pkp)`, bagi 12
    - Di handler `get_payslip`: query `ptkp_statuses` by `employee.ptkp_status_id`; gunakan `DEFAULT_PTKP` jika None atau tidak ditemukan; ganti kalkulasi `ait = gross * 0.10` dengan `calculate_ait_monthly(gross, ptkp_annual_value)`
    - _Persyaratan: 6.6_
    - _Desain: Bagian "app/routers/payroll.py — Perubahan", "Properti 4", "Properti 5"_

- [ ] 6. Utilitas Bulk Import
  - [ ] 6.1 Tambahkan `openpyxl>=3.1,<4.0` ke `requirements.txt`
    - Tambahkan juga `hypothesis>=6.100,<7.0` untuk property-based testing
    - _Desain: Bagian "Kebutuhan Tambahan pada requirements.txt"_

  - [ ] 6.2 Buat `app/utils/bulk_import.py` dengan fungsi parsing dan validasi
    - Buat fungsi `parse_csv(file_bytes: bytes) -> list[dict]`: decode UTF-8 (fallback latin-1), gunakan `csv.DictReader`
    - Buat fungsi `parse_excel(file_bytes: bytes) -> list[dict]`: gunakan `openpyxl`, baca hanya sheet pertama
    - Buat fungsi `validate_row(row: dict, required_cols: list[str]) -> list[str]`: kembalikan list pesan error untuk field kosong atau format tidak valid (khusus `joining_date`: coba format `yyyy-MM-dd`, `dd/MM/yyyy`, `MM/dd/yyyy`)
    - Buat fungsi helper `normalize_date(value: str) -> str | None` untuk normalisasi tanggal
    - _Persyaratan: 7.2, 7.3, 7.4_
    - _Desain: Bagian "app/utils/bulk_import.py"_

  - [ ] 6.3 Tambahkan `POST /api/Employees/import` dan `GET /api/Employees/importTemplate` ke `app/routers/employees.py`
    - `POST /api/Employees/import` (admin only): terima `UploadFile` via `multipart/form-data`; deteksi format dari extension/content-type; panggil `parse_csv` atau `parse_excel`; validasi header wajib (`employee_id`, `name`, `email`, `designation`, `department_id`, `joining_date`) — tolak seluruh file jika kolom hilang; proses setiap baris dalam satu transaksi per baris (bukan satu transaksi keseluruhan); kumpulkan hasil sukses dan gagal; kembalikan laporan `{total_rows, success_count, failed_count, errors: [{row, field, message}]}`
    - `GET /api/Employees/importTemplate` (admin only): kembalikan respons dengan `Content-Type: text/csv` dan header CSV template dengan 6 kolom wajib sebagai konten
    - _Persyaratan: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 12.4_
    - _Desain: Bagian "employees.py — Endpoint Baru", "Edge Cases — Bulk Import"_

- [ ] 7. Router Manpower Planning
  - [ ] 7.1 Buat `app/routers/manpower_plans.py` dengan tiga endpoint
    - Buat Pydantic schema `ManpowerPlanIn` (department_id, designation, plan_year, plan_month, target_headcount, notes)
    - `POST /api/ManpowerPlans` (admin only): validasi `target_headcount >= 1`; lakukan upsert — cari record dengan kombinasi (department_id, designation, plan_year, plan_month), update jika ada atau insert baru; kembalikan `isSuccess: true`
    - `GET /api/ManpowerPlans`: dukung query param `year`, `month`, `department_id` (semua opsional); filter dan kembalikan list
    - `GET /api/ManpowerPlans/summary`: untuk setiap record `ManpowerPlan` yang cocok dengan filter, hitung `actual_headcount` dari tabel `employees` (count karyawan aktif dengan `department_id` dan `designation` yang sesuai); hitung `gap = actual_headcount - target_headcount`; kembalikan list summary
    - Gunakan `require_admin` untuk POST, `get_current_employee` untuk GET
    - _Persyaratan: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
    - _Desain: Bagian "app/routers/manpower_plans.py"_

- [ ] 8. Router Replacement Tracking
  - [ ] 8.1 Buat `app/routers/replacement_tracking.py` dengan tiga endpoint
    - Buat Pydantic schema `ReplacementTrackingIn` (departing_employee_id, replacement_employee_id [opsional], department_id, designation, departure_reason, effective_date, expected_fill_date) dan `ReplacementUpdateIn` (replacement_employee_id, fill_date, status, cancellation_reason)
    - `POST /api/ReplacementTrackings` (admin only): validasi `departing_employee_id` ada di `employees`; validasi `departure_reason` hanya "Resign", "Long_Leave", atau "Transfer"; simpan record baru dengan `status = "Open"`, `created_by = auth.id`
    - `GET /api/ReplacementTrackings`: dukung filter `department_id` dan `status`; untuk setiap record yang dikembalikan, hitung dan sertakan field `is_overdue` (`status == "Open"` dan `expected_fill_date < today`)
    - `PUT /api/ReplacementTrackings/{id}` (admin only): jika `status = "Filled"` set `fill_date` dan `replacement_employee_id`; jika `status = "Cancelled"` set `cancellation_reason`; kembalikan `isSuccess: true`
    - Gunakan `require_admin` untuk POST dan PUT, `get_current_employee` untuk GET
    - _Persyaratan: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_
    - _Desain: Bagian "app/routers/replacement_tracking.py", "Properti 6"_

- [ ] 9. Utilitas Audit Log
  - [ ] 9.1 Buat `app/utils/audit.py` dengan fungsi pembantu
    - Buat direktori `app/utils/` dengan file `__init__.py` kosong
    - Buat fungsi `write_audit_log(db: Session, action: str, target_employee_id: int | None, performed_by: int, changed_fields: dict) -> None`
    - Serialisasi `changed_fields` ke JSON string sebelum menyimpan ke kolom `AuditLog.changed_fields`
    - Tambahkan panggilan `write_audit_log` di endpoint yang melakukan operasi tulis: `POST /api/Employees` (action: "CREATE_EMPLOYEE"), `PUT /api/Employees/{id}` (action: "UPDATE_EMPLOYEE"), `PUT /api/Employees/{id}/deactivate` (action: "DEACTIVATE"), `PUT /api/Employees/{id}/ptkp` (action: "UPDATE_PTKP"), `POST /api/Employees/import` (action: "BULK_IMPORT" per baris sukses)
    - _Persyaratan: 11.5_
    - _Desain: Bagian "app/utils/audit.py — Modul Bantu Audit Log"_

- [ ] 10. Checkpoint — Verifikasi integrasi seluruh router
  - Pastikan semua router baru terdaftar di `main.py`
  - Pastikan `migrations.py` dan `seed.py` dipanggil dari `lifespan`
  - Pastikan semua file `__init__.py` yang diperlukan ada
  - Jalankan `pytest tests/ --tb=short -q` untuk memverifikasi tidak ada regresi pada test yang sudah ada
  - Tanyakan kepada pengguna jika ada pertanyaan sebelum melanjutkan ke task pengujian

- [ ] 11. Unit Tests — Logika Kalkulasi Murni
  - [ ] 11.1 Buat `tests/test_payroll_tax.py` dengan unit test fungsi PPh 21
    - Test `calculate_annual_pph21(0)` → `0.0`
    - Test `calculate_annual_pph21(60_000_000)` → `3_000_000` (5%)
    - Test `calculate_annual_pph21(150_000_000)` → `3_000_000 + 13_500_000 = 16_500_000` (layer 5% + 15%)
    - Test `calculate_annual_pph21(300_000_000)` → layer 5% + 15% + 25%
    - Test `calculate_annual_pph21(600_000_000)` → layer tertinggi 30%
    - Test `calculate_ait_monthly(5_000_000, 54_000_000)` dengan nilai yang diverifikasi manual
    - _Persyaratan: 6.6_
    - _Desain: Bagian "Strategi Pengujian — Unit Tests"_

  - [ ] 11.2 Buat `tests/test_bulk_import.py` dengan unit test fungsi parsing dan validasi
    - Test `parse_csv` dengan baris valid → list dict yang benar
    - Test `parse_csv` dengan encoding latin-1 → fallback berhasil
    - Test `validate_row` dengan baris lengkap → list kosong (tidak ada error)
    - Test `validate_row` tanpa field `email` → error untuk field tersebut
    - Test `validate_row` dengan `joining_date` format tidak valid → error
    - Test `normalize_date` untuk format `dd/MM/yyyy` dan `MM/dd/yyyy`
    - Test `parse_excel` dengan file xlsx minimal (hanya header + 1 baris data)
    - _Persyaratan: 7.2, 7.3_
    - _Desain: Bagian "Strategi Pengujian — Unit Tests", "Properti 3"_

  - [ ] 11.3 Buat `tests/test_replacement_flag.py` dengan unit test flag `is_overdue`
    - Test: record "Open" dengan `expected_fill_date` kemarin → `is_overdue = True`
    - Test: record "Open" dengan `expected_fill_date` besok → `is_overdue = False`
    - Test: record "Filled" dengan `expected_fill_date` kemarin → `is_overdue = False`
    - Test: record "Cancelled" dengan `expected_fill_date` kemarin → `is_overdue = False`
    - _Persyaratan: 9.6_
    - _Desain: Bagian "Strategi Pengujian — Unit Tests", "Properti 6"_

- [ ] 12. Integration Tests — API Endpoints
  - [ ] 12.1 Perbarui `tests/conftest.py` untuk menambahkan fixture departemen dan PTKP seed
    - Tambahkan seed `Department` minimal (misalnya "Engineering", "HR") ke fixture `_db` yang sudah ada
    - Pastikan seed PTKP statuses berjalan dalam test setup (atau panggil `seed_ptkp_statuses` secara eksplisit)
    - Tambahkan fixture `admin_token` jika belum ada (sudah ada, tidak perlu diubah)
    - _Desain: Bagian "Strategi Pengujian — Integration Tests"_

  - [ ] 12.2 Buat `tests/test_employees_api.py` dengan integration test endpoint employees baru
    - Test `POST /api/Employees` dengan admin token → 200, data karyawan dikembalikan
    - Test `POST /api/Employees` dengan email duplikat → `isSuccess: false`
    - Test `POST /api/Employees` dengan employee_id duplikat → `isSuccess: false`
    - Test `POST /api/Employees` tanpa field wajib → `isSuccess: false` + daftar field
    - Test `PUT /api/Employees/{id}` (update admin) → `isSuccess: true`
    - Test `PUT /api/Employees/{id}/deactivate` → karyawan tetap ada, `status_id = 2`
    - Test `PUT /api/Employees/{id}/deactivate` dua kali → `isSuccess: false`
    - Test `GET /api/Employees/{id}/transfers` setelah update designation → riwayat transfer ada
    - Test `PUT /api/Employees/{id}/ptkp` dengan kode valid → `isSuccess: true`
    - Test `PUT /api/Employees/{id}/ptkp` dengan kode tidak valid → `isSuccess: false`
    - _Persyaratan: 1.1–1.7, 3.1–3.5, 4.1–4.4, 5.1–5.4, 6.3–6.5_

  - [ ] 12.3 Buat `tests/test_bulk_import_api.py` dengan integration test bulk import
    - Test upload CSV valid (3 baris) → `success_count = 3`, `failed_count = 0`
    - Test upload CSV dengan 1 baris duplikat email → `success_count = 2`, `failed_count = 1`, error di list
    - Test upload CSV dengan kolom wajib hilang → `isSuccess: false`, daftar kolom hilang
    - Test upload file format tidak didukung (.txt) → `isSuccess: false`
    - Test `GET /api/Employees/importTemplate` → respons CSV dengan header yang benar
    - _Persyaratan: 7.1–7.7_

  - [ ] 12.4 Buat `tests/test_departments_api.py` dengan integration test departments
    - Test `GET /api/Departments` → daftar departemen, termasuk seed dari conftest
    - Test `POST /api/Departments` dengan admin → departemen baru tersimpan
    - Test `POST /api/Departments` dengan nama duplikat → `isSuccess: false`
    - Test `PUT /api/Departments/{id}` → data diperbarui
    - _Persyaratan: 2.1–2.4_

  - [ ] 12.5 Buat `tests/test_manpower_plans_api.py` dengan integration test manpower planning
    - Test `POST /api/ManpowerPlans` dengan target valid → `isSuccess: true`
    - Test `POST /api/ManpowerPlans` dua kali dengan kombinasi sama → satu record di DB (upsert)
    - Test `POST /api/ManpowerPlans` dengan `target_headcount = 0` → `isSuccess: false`
    - Test `GET /api/ManpowerPlans` dengan filter `year` dan `month` → hasil terfilter
    - Test `GET /api/ManpowerPlans/summary` → field `actual_headcount` dan `gap` ada dalam respons
    - _Persyaratan: 8.1–8.6_

  - [ ] 12.6 Buat `tests/test_replacement_tracking_api.py` dengan integration test replacement tracking
    - Test `POST /api/ReplacementTrackings` dengan karyawan valid → `isSuccess: true`, status "Open"
    - Test `POST /api/ReplacementTrackings` dengan `departing_employee_id` tidak ada → `isSuccess: false`
    - Test `POST /api/ReplacementTrackings` dengan `departure_reason` tidak valid → `isSuccess: false`
    - Test `GET /api/ReplacementTrackings` dengan filter status → hasil terfilter
    - Test `PUT /api/ReplacementTrackings/{id}` dengan status "Filled" → status berubah, `fill_date` tersimpan
    - Test `PUT /api/ReplacementTrackings/{id}` dengan status "Cancelled" → status berubah
    - _Persyaratan: 9.1–9.6_

  - [ ] 12.7 Buat `tests/test_rbac.py` dengan integration test keamanan dan otorisasi
    - Test semua endpoint admin-only dengan employee token → HTTP 403
    - Test semua endpoint dengan tanpa token → HTTP 401
    - Test `GET /api/Employees/profile?id=X` (X adalah karyawan lain) dengan employee token → HTTP 403
    - Test `GET /api/Employees` dengan employee token → hanya data diri sendiri
    - _Persyaratan: 11.1, 11.2, 11.3, 11.4_

  - [ ] 12.8 Buat `tests/test_payroll_ptkp.py` dengan integration test payroll + PTKP
    - Test `GET /api/Payroll/GetPayslip` untuk karyawan tanpa PTKP → AIT menggunakan fallback TK/0 (tidak 10% flat)
    - Test `GET /api/Payroll/GetPayslip` untuk karyawan dengan K/3 → AIT lebih kecil dibanding TK/0 untuk salary yang sama
    - Test bahwa `net_pay >= 0` untuk berbagai kombinasi salary dan hari hadir
    - _Persyaratan: 6.6_
    - _Desain: Bagian "Strategi Pengujian — Integration Tests"_

- [ ] 13. Property-Based Tests
  - [ ] 13.1 Buat `tests/test_properties.py` dengan property test untuk AIT monoton
    - **Properti 4: Kalkulasi AIT progresif monoton**
    - Gunakan `@given(salary_a=st.floats(...), salary_b=st.floats(...), ptkp=st.floats(...))` dengan `@settings(max_examples=500)`
    - Assert: jika `salary_a <= salary_b` maka `calculate_ait_monthly(salary_a, ptkp) <= calculate_ait_monthly(salary_b, ptkp)`
    - **Memvalidasi: Persyaratan 6.6**
    - _Desain: Bagian "Properti 4"_

  - [ ] 13.2 Tambahkan property test untuk net pay non-negatif ke `tests/test_properties.py`
    - **Properti 5: Net pay selalu non-negatif untuk input valid**
    - Generate kombinasi `gross_salary >= 0`, `absent_days >= 0`, `ptkp_annual >= 0` secara acak
    - Hitung `net_pay` menggunakan logika payslip yang diekstrak (tanpa DB)
    - Assert `net_pay >= 0`
    - **Memvalidasi: Persyaratan 6.6**
    - _Desain: Bagian "Properti 5"_

  - [ ] 13.3 Tambahkan property test untuk konsistensi `is_overdue` ke `tests/test_properties.py`
    - **Properti 6: Flag `is_overdue` konsisten dengan tanggal**
    - Generate `expected_fill_date` acak (masa lalu atau masa depan) dan `status` acak
    - Assert: `is_overdue` harus `True` jika dan hanya jika `status == "Open"` dan `expected_fill_date < today`
    - **Memvalidasi: Persyaratan 9.6**
    - _Desain: Bagian "Properti 6"_

  - [ ] 13.4 Tambahkan property test untuk upsert ManpowerPlan idempoten ke `tests/test_properties.py`
    - **Properti 9: Upsert ManpowerPlan idempoten**
    - Gunakan `@given` untuk generate kombinasi (department_id, designation, year, month) dan dua nilai `target_headcount` berbeda
    - POST dua kali ke `/api/ManpowerPlans` dengan kombinasi yang sama
    - Assert: hanya ada satu record di DB, nilainya adalah dari POST kedua
    - **Memvalidasi: Persyaratan 8.2**
    - _Desain: Bagian "Properti 9"_

- [ ] 14. Checkpoint Akhir — Semua test hijau
  - Pastikan semua test pass dengan `pytest tests/ --tb=short -q`
  - Tanyakan kepada pengguna jika ada pertanyaan atau jika ada penyesuaian yang diperlukan

## Catatan

- Task bertanda `*` bersifat opsional dan dapat dilewati untuk MVP yang lebih cepat
- Setiap task mencantumkan file target dan nomor persyaratan untuk keterlacakan
- Checkpoint memastikan validasi inkremental di titik-titik penting
- Property tests menggunakan library **Hypothesis** yang harus ditambahkan ke `requirements.txt`
- Unit tests dan property tests bersifat komplementer: unit tests memvalidasi contoh spesifik, property tests memvalidasi sifat universal

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3"] },
    { "id": 1, "tasks": ["1.4", "2.1", "3.1", "3.2"] },
    { "id": 2, "tasks": ["4.1", "4.2", "4.3", "4.4", "4.5", "4.6", "5.1", "6.1", "7.1", "8.1"] },
    { "id": 3, "tasks": ["6.2", "9.1"] },
    { "id": 4, "tasks": ["6.3"] },
    { "id": 5, "tasks": ["11.1", "11.2", "11.3", "12.1"] },
    { "id": 6, "tasks": ["12.2", "12.3", "12.4", "12.5", "12.6", "12.7", "12.8"] },
    { "id": 7, "tasks": ["13.1", "13.2", "13.3", "13.4"] }
  ]
}
```
