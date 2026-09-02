# Dokumen Desain: Menu Employee

## Ikhtisar

Fitur **Menu Employee** memperluas sistem Ignitia menjadi modul SDM (Sumber Daya Manusia) yang lengkap. Sistem saat ini sudah memiliki fondasi — profil karyawan, autentikasi JWT, absensi, payroll dasar — tetapi belum mendukung pengelolaan departemen, riwayat transfer, status pajak PTKP, impor massal, dan perencanaan tenaga kerja.

Desain ini menambahkan fungsionalitas berikut tanpa mengubah kontrak API yang sudah ada:

| Domain | Cakupan |
|--------|---------|
| Manajemen karyawan | Tambah, edit lengkap (admin), nonaktifkan |
| Departemen | CRUD departemen dan asosiasi karyawan |
| Riwayat transfer | Catat dan lihat perpindahan departemen/jabatan |
| PTKP | Referensi kode PTKP DJP, asosiasi per karyawan, riwayat perubahan |
| Payroll — PPh 21 | Ganti AIT flat 10% dengan tarif progresif berbasis PTKP nyata |
| Impor massal | Upload CSV/Excel, validasi per baris, laporan error |
| Manpower Planning | Target headcount per departemen per periode |
| Replacement Tracking | Pantau kebutuhan pengganti karyawan |
| Keamanan & audit | RBAC admin/employee, audit log operasi tulis |

### Prinsip Desain

1. **Kompatibilitas mundur**: Semua endpoint lama tetap bekerja tanpa perubahan contract.
2. **Pola konsisten**: Respons selalu `{"isSuccess": bool, "message": str, "data": ...}`.
3. **Gagal rapi**: Kesalahan validasi dikembalikan sebagai `isSuccess: false`, bukan HTTP 4xx/5xx (kecuali 401/403 untuk auth/otorisasi).
4. **Transaksi atomik**: Operasi multi-baris (bulk import) menggunakan satu transaksi database.

---

## Arsitektur

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Client (Android)                │
│  EmployeeListPage  │  ProfilePage  │  ManpowerPage  │  ...  │
└──────────────────────────┬──────────────────────────────────┘
                           │  HTTP/JSON  (Bearer JWT)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  FastAPI  (ignitia_server)                   │
│                                                             │
│  ┌──────────────┐  ┌─────────────┐  ┌───────────────────┐  │
│  │ app/deps.py  │  │ app/main.py │  │ app/security.py   │  │
│  │ get_current_ │  │ create_app()│  │ JWT / bcrypt /    │  │
│  │ employee()   │  │ /api prefix │  │ face / geo-fence  │  │
│  │ require_admin│  └──────┬──────┘  └───────────────────┘  │
│  └──────────────┘         │                                 │
│                           │  registers routers              │
│         ┌─────────────────┼──────────────────────────┐      │
│         ▼                 ▼                          ▼      │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │ employees  │  │ departments  │  │  ptkp_statuses   │    │
│  │ .py        │  │ .py          │  │  .py             │    │
│  └────────────┘  └──────────────┘  └──────────────────┘    │
│         ▼                 ▼                          ▼      │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │ manpower   │  │ replacement  │  │  payroll.py      │    │
│  │ _plans.py  │  │ _tracking.py │  │  (updated AIT)   │    │
│  └────────────┘  └──────────────┘  └──────────────────┘    │
│                                                             │
│  ┌────────────────────────────────────────────────────┐     │
│  │                  app/models.py                     │     │
│  │  Employee · Department · EmployeeTransfer          │     │
│  │  PtkpStatus · PtkpStatusHistory · AuditLog         │     │
│  │  ManpowerPlan · ReplacementTracking · ...existing  │     │
│  └────────────────────────────────────────────────────┘     │
│                                                             │
│  ┌────────────────────────────────────────────────────┐     │
│  │          SQLite / PostgreSQL  (SQLAlchemy)         │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Alur Request Tipikal

```
Client → Kirim Bearer token → deps.get_current_employee() → Employee ORM
                                   └─ type_id check → deps.require_admin()
                                                            └─ raise 403 jika bukan admin
Router handler → validasi payload → operasi DB → tulis AuditLog (jika tulis) → return ok()/fail()
```

---

## Komponen dan Antarmuka

### 1. `app/deps.py` — Dependency Baru

**`require_admin(auth: Employee = Depends(get_current_employee)) -> Employee`**

Dependency yang dapat digunakan sebagai pengganti atau tambahan `get_current_employee`. Melempar `HTTPException(403)` jika `auth.type_id != 1`.

```python
def require_admin(auth: Employee = Depends(get_current_employee)) -> Employee:
    if auth.type_id != 1:
        raise HTTPException(status_code=403, detail="Forbidden")
    return auth
```

---

### 2. Router Baru

#### `app/routers/departments.py`

| Method | Path | Auth | Keterangan |
|--------|------|------|-----------|
| GET | `/api/Departments` | Bearer | Daftar semua departemen + designations |
| POST | `/api/Departments` | Admin | Buat departemen baru |
| PUT | `/api/Departments/{id}` | Admin | Update departemen |

**Request body POST/PUT:**
```json
{ "name": "string (wajib)", "code": "string (opsional)", "is_active": true }
```

**Respons GET:**
```json
{
  "isSuccess": true,
  "message": "Success",
  "data": [
    { "id": 1, "name": "Engineering", "code": "ENG", "is_active": true }
  ]
}
```

---

#### `app/routers/employees.py` — Endpoint Baru

| Method | Path | Auth | Keterangan |
|--------|------|------|-----------|
| POST | `/api/Employees` | Admin | Tambah karyawan baru |
| PUT | `/api/Employees/{id}` | Admin | Update lengkap oleh admin |
| PUT | `/api/Employees/{id}/deactivate` | Admin | Nonaktifkan karyawan |
| GET | `/api/Employees/{id}/transfers` | Bearer | Riwayat transfer |
| POST | `/api/Employees/{id}/transfers` | Admin | Catat transfer manual |
| PUT | `/api/Employees/{id}/ptkp` | Admin | Update status PTKP |
| POST | `/api/Employees/import` | Admin | Bulk import CSV/Excel |
| GET | `/api/Employees/importTemplate` | Admin | Download template CSV |

**Request body POST `/api/Employees`:**
```json
{
  "name": "string",
  "employee_id": "string",
  "email": "string",
  "department_id": 1,
  "designation": "string",
  "joining_date": "2024-01-15",
  "cell_no": "string (opsional)",
  "address": "string (opsional)",
  "nid": "string (opsional)",
  "supervisor_id": 0,
  "basic_salary": 0.0
}
```

**Request body PUT `/api/Employees/{id}/deactivate`:**
```json
{ "effective_date": "2024-12-31", "reason": "Resign" }
```

**Request body PUT `/api/Employees/{id}/ptkp`:**
```json
{ "ptkp_status_id": 3, "effective_date": "2025-01-01" }
```

**Request body POST `/api/Employees/{id}/transfers`:**
```json
{
  "from_department_id": 1,
  "to_department_id": 2,
  "from_designation": "Junior Engineer",
  "to_designation": "Senior Engineer",
  "effective_date": "2025-03-01",
  "reason": "Promosi"
}
```

**Request body POST `/api/Employees/import`:**
- `multipart/form-data` dengan field `file` berisi file CSV atau `.xlsx`

**Respons POST `/api/Employees/import`:**
```json
{
  "isSuccess": true,
  "message": "Import selesai",
  "data": {
    "total_rows": 50,
    "success_count": 48,
    "failed_count": 2,
    "errors": [
      { "row": 5, "field": "email", "message": "Email sudah terdaftar" },
      { "row": 12, "field": "employee_id", "message": "ID karyawan sudah terdaftar" }
    ]
  }
}
```

---

#### `app/routers/ptkp_statuses.py`

| Method | Path | Auth | Keterangan |
|--------|------|------|-----------|
| GET | `/api/PtkpStatuses` | Bearer | Daftar semua kode PTKP |

**Respons:**
```json
{
  "isSuccess": true,
  "message": "Success",
  "data": [
    { "id": 1, "code": "TK/0", "description": "Tidak Kawin, 0 tanggungan", "annual_value": 54000000 },
    { "id": 5, "code": "K/0", "description": "Kawin, 0 tanggungan", "annual_value": 58500000 }
  ]
}
```

---

#### `app/routers/manpower_plans.py`

| Method | Path | Auth | Keterangan |
|--------|------|------|-----------|
| POST | `/api/ManpowerPlans` | Admin | Buat/update (upsert) rencana |
| GET | `/api/ManpowerPlans` | Bearer | Daftar dengan filter |
| GET | `/api/ManpowerPlans/summary` | Bearer | Perbandingan target vs aktual |

**Request body POST:**
```json
{
  "department_id": 1,
  "designation": "Software Engineer",
  "plan_year": 2025,
  "plan_month": 6,
  "target_headcount": 5,
  "notes": "Kebutuhan proyek Q2"
}
```

**Query params GET:** `year`, `month`, `department_id` (semua opsional)

**Respons GET `/api/ManpowerPlans/summary`:**
```json
{
  "isSuccess": true,
  "message": "Success",
  "data": [
    {
      "department_id": 1,
      "department_name": "Engineering",
      "designation": "Software Engineer",
      "plan_year": 2025,
      "plan_month": 6,
      "target_headcount": 5,
      "actual_headcount": 3,
      "gap": -2
    }
  ]
}
```

---

#### `app/routers/replacement_tracking.py`

| Method | Path | Auth | Keterangan |
|--------|------|------|-----------|
| POST | `/api/ReplacementTrackings` | Admin | Buat kebutuhan penggantian |
| GET | `/api/ReplacementTrackings` | Bearer | Daftar dengan filter status/dept |
| PUT | `/api/ReplacementTrackings/{id}` | Admin | Update (isi pengganti / cancel) |

**Request body POST:**
```json
{
  "departing_employee_id": 10,
  "replacement_employee_id": null,
  "department_id": 1,
  "designation": "Senior Engineer",
  "departure_reason": "Resign",
  "effective_date": "2025-01-31",
  "expected_fill_date": "2025-03-31"
}
```

**Request body PUT `/{id}`:**
```json
{
  "replacement_employee_id": 15,
  "fill_date": "2025-03-15",
  "status": "Filled"
}
```
atau untuk pembatalan:
```json
{ "status": "Cancelled", "cancellation_reason": "Posisi dieliminasi" }
```

**Respons GET** (field tambahan `is_overdue` dihitung server):
```json
{
  "isSuccess": true,
  "message": "Success",
  "data": [
    {
      "id": 1,
      "departing_employee_id": 10,
      "department_id": 1,
      "designation": "Senior Engineer",
      "departure_reason": "Resign",
      "status": "Open",
      "expected_fill_date": "2025-03-31",
      "is_overdue": true
    }
  ]
}
```

---

### 3. `app/routers/payroll.py` — Perubahan pada `get_payslip`

Logika AIT diperbarui:

```
PTKP tahunan (dari ptkp_statuses, default TK/0 = 54.000.000 jika tidak terdaftar)
annual_gross   = gross_salary * 12
PKP_annual     = max(0, annual_gross - ptkp_annual_value)
AIT_annual     = tarif progresif PPh 21(PKP_annual)
AIT_monthly    = AIT_annual / 12

Tarif progresif PPh 21:
  ≤ 60.000.000       → 5%
  > 60.000.000       → 60jt × 5% + sisa × 15%  (untuk PKP ≤ 250jt)
  > 250.000.000      → + sisa × 25%            (untuk PKP ≤ 500jt)
  > 500.000.000      → + sisa × 30%
```

Catatan: batasan layer mengacu pada UU HPP (2022) yang berlaku saat ini. Nilai di-hardcode sebagai konstanta bernama di `payroll.py` agar mudah diperbarui ketika regulasi berubah.

---

### 4. `app/utils/audit.py` — Modul Bantu Audit Log

Fungsi pembantu yang digunakan oleh semua router yang melakukan operasi tulis:

```python
def write_audit_log(
    db: Session,
    action: str,            # "CREATE_EMPLOYEE", "DEACTIVATE", "UPDATE_PTKP", dll.
    target_employee_id: int | None,
    performed_by: int,
    changed_fields: dict,
) -> None: ...
```

---

### 5. `app/utils/bulk_import.py` — Modul Impor Massal

Memisahkan logika parsing dari router:

```
parse_csv(file_bytes)  → list[dict]
parse_excel(file_bytes) → list[dict]
validate_row(row, required_columns) → list[str]  # daftar error
```

Dependensi: `csv` (stdlib), `openpyxl` (tambahkan ke `requirements.txt`).

---

## Model Data

### ERD Ringkas

```
companies (existing)

employees (existing + kolom baru)
  ├─ department_id  ──FK──► departments.id
  └─ ptkp_status_id ──FK──► ptkp_statuses.id

departments
  id │ name │ code │ is_active

employee_contact_info (existing)
  id == employees.id

employee_transfers
  id │ employee_id ──► employees.id
     │ from_department_id ──► departments.id
     │ to_department_id ──► departments.id
     │ from_designation │ to_designation
     │ effective_date │ reason
     │ created_by ──► employees.id │ created_at

ptkp_statuses
  id │ code (TK/0 .. K/3) │ description │ annual_value

ptkp_status_histories
  id │ employee_id ──► employees.id
     │ old_ptkp_status_id ──► ptkp_statuses.id
     │ new_ptkp_status_id ──► ptkp_statuses.id
     │ effective_date │ changed_by ──► employees.id │ created_at

manpower_plans
  id │ department_id ──► departments.id
     │ designation │ plan_year │ plan_month
     │ target_headcount │ notes
     │ created_by ──► employees.id │ created_at
  UNIQUE (department_id, designation, plan_year, plan_month)

replacement_trackings
  id │ departing_employee_id ──► employees.id
     │ replacement_employee_id ──► employees.id (nullable)
     │ department_id ──► departments.id
     │ designation │ departure_reason
     │ effective_date │ expected_fill_date │ fill_date (nullable)
     │ status (Open/Filled/Cancelled)
     │ cancellation_reason (nullable)
     │ created_by ──► employees.id │ created_at

audit_logs
  id │ action │ target_employee_id │ performed_by │ timestamp │ changed_fields (JSON text)

attendance (existing)
user_leaves (existing)
overtime (existing)
leave_types (existing)
password_reset_tokens (existing)
```

### Definisi Model SQLAlchemy Baru

```python
class Department(Base):
    __tablename__ = "departments"
    id        = Column(Integer, primary_key=True, index=True)
    name      = Column(String(200), unique=True, nullable=False)
    code      = Column(String(50), unique=True, nullable=True)
    is_active = Column(Integer, default=1)  # 1 = aktif

class EmployeeTransfer(Base):
    __tablename__ = "employee_transfers"
    id                 = Column(Integer, primary_key=True)
    employee_id        = Column(Integer, index=True)
    from_department_id = Column(Integer, nullable=True)
    to_department_id   = Column(Integer, nullable=True)
    from_designation   = Column(String(200), nullable=True)
    to_designation     = Column(String(200), nullable=True)
    effective_date     = Column(String(25))
    reason             = Column(String(1000), nullable=True)
    created_by         = Column(Integer)
    created_at         = Column(DateTime, default=lambda: datetime.now(timezone.utc).replace(tzinfo=None))

class PtkpStatus(Base):
    __tablename__ = "ptkp_statuses"
    id           = Column(Integer, primary_key=True)
    code         = Column(String(10), unique=True)        # "TK/0", "K/3", dll.
    description  = Column(String(200))
    annual_value = Column(Float)                           # dalam Rupiah

class PtkpStatusHistory(Base):
    __tablename__ = "ptkp_status_histories"
    id                 = Column(Integer, primary_key=True)
    employee_id        = Column(Integer, index=True)
    old_ptkp_status_id = Column(Integer, nullable=True)
    new_ptkp_status_id = Column(Integer)
    effective_date     = Column(String(25))
    changed_by         = Column(Integer)
    created_at         = Column(DateTime, default=lambda: datetime.now(timezone.utc).replace(tzinfo=None))

class ManpowerPlan(Base):
    __tablename__ = "manpower_plans"
    id               = Column(Integer, primary_key=True)
    department_id    = Column(Integer, index=True)
    designation      = Column(String(200))
    plan_year        = Column(Integer)
    plan_month       = Column(Integer)
    target_headcount = Column(Integer)
    notes            = Column(String(1000), nullable=True)
    created_by       = Column(Integer)
    created_at       = Column(DateTime, default=lambda: datetime.now(timezone.utc).replace(tzinfo=None))
    # UniqueConstraint diimplementasikan via upsert logic di router

class ReplacementTracking(Base):
    __tablename__ = "replacement_trackings"
    id                      = Column(Integer, primary_key=True)
    departing_employee_id   = Column(Integer, index=True)
    replacement_employee_id = Column(Integer, nullable=True)
    department_id           = Column(Integer, index=True)
    designation             = Column(String(200))
    departure_reason        = Column(String(50))  # Resign / Long_Leave / Transfer
    effective_date          = Column(String(25))
    expected_fill_date      = Column(String(25))
    fill_date               = Column(String(25), nullable=True)
    status                  = Column(String(20), default="Open")
    cancellation_reason     = Column(String(1000), nullable=True)
    created_by              = Column(Integer)
    created_at              = Column(DateTime, default=lambda: datetime.now(timezone.utc).replace(tzinfo=None))

class AuditLog(Base):
    __tablename__ = "audit_logs"
    id                 = Column(Integer, primary_key=True)
    action             = Column(String(100))
    target_employee_id = Column(Integer, nullable=True)
    performed_by       = Column(Integer)
    timestamp          = Column(DateTime, default=lambda: datetime.now(timezone.utc).replace(tzinfo=None))
    changed_fields     = Column(Text, nullable=True)  # JSON string
```

### Perubahan pada `Employee`

Dua kolom baru ditambahkan (nullable agar kompatibel dengan data lama):

```python
department_id    = Column(Integer, nullable=True)   # FK ke departments.id
ptkp_status_id   = Column(Integer, nullable=True)   # FK ke ptkp_statuses.id
```

### Data Seed PTKP

Tabel `ptkp_statuses` diisi sekali (idempotent) saat startup atau via script seed:

| id | code | description | annual_value (Rp) |
|----|------|-------------|-------------------|
| 1 | TK/0 | Tidak Kawin, 0 tanggungan | 54.000.000 |
| 2 | TK/1 | Tidak Kawin, 1 tanggungan | 58.500.000 |
| 3 | TK/2 | Tidak Kawin, 2 tanggungan | 63.000.000 |
| 4 | TK/3 | Tidak Kawin, 3 tanggungan | 67.500.000 |
| 5 | K/0 | Kawin, 0 tanggungan | 58.500.000 |
| 6 | K/1 | Kawin, 1 tanggungan | 63.000.000 |
| 7 | K/2 | Kawin, 2 tanggungan | 67.500.000 |
| 8 | K/3 | Kawin, 3 tanggungan | 72.000.000 |

Nilai PTKP mengacu pada PMK 101/PMK.010/2016 yang masih berlaku sebagai dasar hukum.

### Strategi Migrasi Database

Sistem saat ini tidak menggunakan Alembic — tabel dibuat via `Base.metadata.create_all()` di startup. Kolom baru pada tabel yang sudah ada (`employees.department_id`, `employees.ptkp_status_id`) harus ditambahkan secara eksplisit karena `create_all` tidak menambah kolom ke tabel yang sudah ada.

**Pendekatan yang dipilih: migration script sederhana di startup**

```python
# app/migrations.py
def run_migrations(engine):
    with engine.connect() as conn:
        # Tambah kolom baru pada employees jika belum ada
        inspector = inspect(engine)
        existing = {c["name"] for c in inspector.get_columns("employees")}
        if "department_id" not in existing:
            conn.execute(text("ALTER TABLE employees ADD COLUMN department_id INTEGER"))
        if "ptkp_status_id" not in existing:
            conn.execute(text("ALTER TABLE employees ADD COLUMN ptkp_status_id INTEGER"))
        conn.commit()
```

Dipanggil dari `lifespan` di `main.py` setelah `create_all`. Untuk deployment production dengan PostgreSQL, migrasi ke Alembic direkomendasikan.

---

## Properti Kebenaran

*Properti adalah karakteristik atau perilaku yang harus berlaku di seluruh eksekusi sistem yang valid — pada intinya, pernyataan formal tentang apa yang seharusnya dilakukan sistem. Properti berfungsi sebagai jembatan antara spesifikasi yang dapat dibaca manusia dan jaminan kebenaran yang dapat diverifikasi mesin.*

### Properti 1: Penambahan karyawan baru tersimpan dan dapat diambil kembali

*Untuk setiap* payload karyawan baru yang valid (nama, email unik, employee_id unik, joining_date valid), melakukan `POST /api/Employees` lalu `GET /api/Employees/profile?id=<id_baru>` harus mengembalikan data yang setara dengan payload yang dikirimkan.

**Memvalidasi: Persyaratan 1.1, 1.5**

---

### Properti 2: Duplikat email ditolak dan tidak memodifikasi state

*Untuk setiap* database karyawan yang ada, mengirimkan `POST /api/Employees` dengan email yang sudah terdaftar harus mengembalikan `isSuccess: false` dan jumlah karyawan dalam database tidak berubah.

**Memvalidasi: Persyaratan 1.2**

---

### Properti 3: Import massal — hanya baris valid yang tersimpan

*Untuk setiap* file CSV dengan campuran baris valid dan baris duplikat/tidak lengkap, setelah `POST /api/Employees/import`: jumlah karyawan baru yang tersimpan harus sama persis dengan `success_count` pada laporan, dan `failed_count` harus sama dengan jumlah baris yang gagal diidentifikasi.

**Memvalidasi: Persyaratan 7.2, 7.4, 7.5**

---

### Properti 4: Kalkulasi AIT progresif monoton

*Untuk setiap* pasangan nilai `(gross_salary_A, gross_salary_B)` dengan nilai PTKP yang sama, jika `gross_salary_A < gross_salary_B` maka `AIT_A <= AIT_B` (tarif progresif tidak pernah menghasilkan beban pajak yang lebih tinggi untuk penghasilan yang lebih rendah).

**Memvalidasi: Persyaratan 6.6**

---

### Properti 5: Net pay selalu non-negatif untuk input valid

*Untuk setiap* data karyawan dengan gaji pokok ≥ 0 dan hari hadir ≥ 0, `net_pay` yang dikembalikan oleh `GET /api/Payroll/GetPayslip` harus ≥ 0.

**Memvalidasi: Persyaratan 6.6**

---

### Properti 6: Replacement Tracking — flag `is_overdue` konsisten dengan tanggal

*Untuk setiap* record replacement tracking dengan status "Open", `is_overdue` harus `true` jika dan hanya jika `expected_fill_date < tanggal_hari_ini`.

**Memvalidasi: Persyaratan 9.6**

---

### Properti 7: Round-trip serialisasi riwayat transfer

*Untuk setiap* record transfer yang disimpan via `POST /api/Employees/{id}/transfers`, mengambil kembali via `GET /api/Employees/{id}/transfers` harus menghasilkan data yang setara dengan yang dikirimkan (semua field wajib terjaga).

**Memvalidasi: Persyaratan 5.2, 5.4**

---

### Properti 8: Karyawan nonaktif tetap ada di daftar

*Untuk setiap* karyawan yang berhasil dinonaktifkan via `PUT /api/Employees/{id}/deactivate`, `GET /api/Employees` harus tetap mengembalikan karyawan tersebut (record tidak dihapus), dengan `status_id = 2`.

**Memvalidasi: Persyaratan 4.2, 12.1**

---

### Properti 9: Upsert ManpowerPlan idempoten

*Untuk setiap* kombinasi `(department_id, designation, plan_year, plan_month)`, mengirimkan `POST /api/ManpowerPlans` dua kali dengan `target_headcount` berbeda harus menghasilkan tepat satu record di database (bukan dua), dengan nilai `target_headcount` dari pengiriman terakhir.

**Memvalidasi: Persyaratan 8.2**

---

## Penanganan Error

### Tabel Kode Error

| Situasi | HTTP | `isSuccess` | Pesan |
|---------|------|-------------|-------|
| Token tidak ada / tidak valid | 401 | — | "Unauthorized" |
| Token kedaluwarsa | 401 | — | "Token telah kedaluwarsa" |
| Bukan admin | 403 | — | "Forbidden" |
| Karyawan tidak ditemukan | 200 | false | "Karyawan tidak ditemukan" |
| Email sudah digunakan | 200 | false | "Email sudah digunakan" |
| Employee ID sudah digunakan | 200 | false | "ID karyawan sudah digunakan" |
| Field wajib kosong | 200 | false | "Field berikut wajib diisi: [nama_field]" |
| Karyawan sudah nonaktif | 200 | false | "Karyawan sudah berstatus nonaktif" |
| Departemen tidak ditemukan | 200 | false | "Departemen tidak ditemukan" |
| Kode PTKP tidak valid | 200 | false | "Kode PTKP tidak valid" |
| Target headcount < 1 | 200 | false | "Target headcount harus minimal 1" |
| Karyawan digantikan tidak ada | 200 | false | "Karyawan yang akan digantikan tidak ditemukan" |
| File import tidak ada / format salah | 200 | false | "Format file tidak didukung. Gunakan CSV atau XLSX." |
| Kolom wajib hilang di file import | 200 | false | "Kolom wajib tidak ditemukan: [daftar_kolom]" |
| Departure reason tidak valid | 200 | false | "Alasan kepergian harus salah satu dari: Resign, Long_Leave, Transfer" |
| DB error / exception tidak terduga | 500 | — | "Internal Server Error" |

### Edge Cases Penting

**Bulk Import:**
- File kosong (hanya header): kembalikan `isSuccess: true` dengan `total_rows: 0`
- Encoding non-UTF-8: coba `latin-1` fallback, jika gagal kembalikan error deskriptif
- File Excel dengan multiple sheets: hanya proses sheet pertama
- Kolom `joining_date` dengan format berbeda: coba `yyyy-MM-dd`, `dd/MM/yyyy`, `MM/dd/yyyy`

**Nonaktifkan Karyawan:**
- Karyawan yang sudah nonaktif mencoba nonaktifkan dirinya sendiri: `isSuccess: false`
- `effective_date` di masa lalu: diizinkan (retroaktif)

**Transfer Otomatis (dipicu oleh update admin):**
- Jika hanya `designation` berubah (tanpa `department_id`): `from_department_id` dan `to_department_id` sama
- Jika hanya `department_id` berubah (tanpa `designation`): `from_designation` dan `to_designation` sama

**Payroll + PTKP:**
- Karyawan tanpa `ptkp_status_id`: gunakan TK/0 (54.000.000) sebagai default
- `ptkp_statuses` tabel kosong (belum di-seed): gunakan fallback 54.000.000 hardcoded

**RBAC — Employee mengakses profil orang lain:**
- `GET /api/Employees/profile?id=X` di mana X ≠ `auth.id`: kembalikan HTTP 403
- `GET /api/Employees` (daftar semua): employee hanya menerima data profil sendiri atau 403 tergantung kebijakan bisnis — implementasikan 403 sesuai Persyaratan 11.3

---

## Strategi Pengujian

### Unit Tests

Fokus pada logika murni yang tidak bergantung pada I/O:

1. **Kalkulasi PPh 21 progresif** (`test_payroll_tax.py`):
   - PKP = 0 → AIT = 0
   - PKP = 60.000.000 → AIT = 3.000.000 (5%)
   - PKP = 150.000.000 → AIT = 3.000.000 + 13.500.000 = 16.500.000 (layer 5% + 15%)
   - PKP = 300.000.000 → layer 5% + 15% + 25%
   - PKP di atas 500.000.000 → layer tertinggi 30%

2. **Validasi baris impor** (`test_bulk_import.py`):
   - Baris lengkap → tidak ada error
   - Email kosong → error field `email`
   - `joining_date` format tidak valid → error field `joining_date`
   - Parsing CSV round-trip

3. **Flag `is_overdue`** (`test_replacement_tracking.py`):
   - Record dengan `expected_fill_date` kemarin → `is_overdue = True`
   - Record dengan `expected_fill_date` besok → `is_overdue = False`
   - Record dengan status "Filled" → `is_overdue = False` (tidak relevan)

### Integration Tests (via httpx + TestClient)

Menggunakan database SQLite in-memory. Setiap test suite membuat fresh database.

1. **Employee CRUD** (`test_employees_api.py`):
   - POST karyawan baru → 200 + data karyawan
   - POST duplikat email → `isSuccess: false`
   - GET profil setelah POST → data konsisten

2. **Bulk Import** (`test_bulk_import_api.py`):
   - Upload CSV valid → laporan sukses
   - Upload CSV dengan duplikat → partial success + error list
   - Upload file bukan CSV/XLSX → error format

3. **Deaktivasi** (`test_deactivate_api.py`):
   - Nonaktifkan karyawan aktif → sukses, status_id = 2
   - Nonaktifkan dua kali → `isSuccess: false`
   - GET setelah nonaktif → karyawan masih ada

4. **Payroll + PTKP** (`test_payroll_ptkp.py`):
   - Payslip tanpa PTKP → fallback TK/0
   - Payslip dengan K/3 → AIT lebih kecil dari TK/0 untuk salary sama

5. **RBAC** (`test_rbac.py`):
   - Admin mengakses semua endpoint → sukses
   - Employee mengakses endpoint admin-only → HTTP 403
   - Request tanpa token → HTTP 401

### Property-Based Tests

Menggunakan library **Hypothesis** (Python).

Konfigurasi minimum 100 iterasi per properti. Setiap test dianotasi dengan tag referensi properti dari dokumen desain ini.

**Contoh struktur:**

```python
# Feature: employee-menu, Property 4: AIT progresif monoton
@given(
    salary_a=st.floats(min_value=0, max_value=10_000_000),
    salary_b=st.floats(min_value=0, max_value=10_000_000),
    ptkp=st.floats(min_value=0, max_value=100_000_000),
)
@settings(max_examples=500)
def test_ait_monotone(salary_a, salary_b, ptkp):
    ait_a = calculate_ait_monthly(salary_a, ptkp)
    ait_b = calculate_ait_monthly(salary_b, ptkp)
    if salary_a <= salary_b:
        assert ait_a <= ait_b
```

Semua property test ditempatkan di `tests/test_properties.py`. Dependensi: `hypothesis>=6.100`.

### Kebutuhan Tambahan pada `requirements.txt`

```
openpyxl>=3.1,<4.0      # Parsing file Excel untuk bulk import
hypothesis>=6.100,<7.0   # Property-based testing
```
