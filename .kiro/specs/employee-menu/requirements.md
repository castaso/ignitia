# Dokumen Persyaratan: Menu Employee

## Pendahuluan

Fitur **Menu Employee** pada aplikasi Ignitia berfungsi sebagai database SDM (Sumber Daya Manusia) perusahaan yang terpusat. Fitur ini mencakup pengelolaan lengkap data karyawan — mulai dari informasi pribadi, kepegawaian, dan payroll, hingga riwayat transfer, status pajak (PTKP), impor massal, dan perencanaan tenaga kerja (Manpower Planning).

Sistem terdiri dari dua komponen:
- **Backend**: FastAPI (`ignitia_server`) — menyediakan REST API dengan autentikasi JWT
- **Client**: Flutter Android (`ignitia_android`) — antarmuka pengguna mobile/tablet

### Gap Analisis: Kondisi Saat Ini vs. Yang Dibutuhkan

| Fungsionalitas | Status Saat Ini | Yang Dibutuhkan |
|---|---|---|
| Lihat daftar karyawan | ✅ Ada (`GET /api/Employees`) | — |
| Lihat profil karyawan | ✅ Ada (`GET /api/Employees/profile`) | — |
| Lihat info kontak | ✅ Ada (`GET /api/Employees/GetContactInfo`) | — |
| Edit profil & kontak | ✅ Ada (`PUT /api/Employees`) | — |
| Tambah karyawan baru | ❌ Belum ada | `POST /api/Employees` |
| Nonaktifkan karyawan | ❌ Belum ada | `PUT /api/Employees/deactivate` |
| Informasi departemen | ❌ Belum ada (hanya `designation`) | Model `Department` baru |
| Informasi payroll lengkap (tunjangan, PTKP) | ⚠️ Parsial (`basic_salary` saja) | Field PTKP, tunjangan per karyawan |
| Riwayat transfer karyawan | ❌ Belum ada | Model `EmployeeTransfer` baru |
| Penyesuaian status PTKP | ❌ Belum ada | Model `PtkpStatus` baru |
| Impor massal karyawan | ❌ Belum ada | `POST /api/Employees/import` |
| Manpower Planning — headcount target | ❌ Belum ada | Model `ManpowerPlan` baru |
| Manpower Planning — karyawan pengganti | ❌ Belum ada | Model `ReplacementTracking` baru |

---

## Glosarium

- **System**: Sistem Ignitia secara keseluruhan (backend FastAPI + client Flutter)
- **API**: Backend FastAPI (`ignitia_server`) yang menyediakan endpoint REST
- **Client**: Aplikasi Flutter Android (`ignitia_android`)
- **Admin**: Pengguna dengan `type_id = 1`, memiliki akses penuh ke semua fitur employee management
- **Employee**: Pengguna dengan `type_id = 2`, hanya dapat melihat dan mengedit profil sendiri
- **Supervisor**: Karyawan dengan subordinat (`supervisor_id` karyawan lain merujuk ke `id` supervisor)
- **Department**: Satuan organisasi perusahaan (divisi/departemen)
- **Designation**: Jabatan/posisi karyawan dalam sebuah departemen
- **PTKP**: Penghasilan Tidak Kena Pajak — batas penghasilan yang tidak dikenakan pajak PPh 21, ditentukan oleh status pernikahan dan jumlah tanggungan
- **Transfer**: Perpindahan karyawan antar departemen atau perubahan jabatan, disertai riwayat tercatat
- **Bulk_Import**: Proses impor data sejumlah besar karyawan sekaligus melalui file CSV atau Excel
- **Manpower_Plan**: Rencana jumlah karyawan yang dibutuhkan per bulan per departemen/jabatan
- **Replacement_Tracking**: Pencatatan karyawan pengganti ketika ada karyawan yang resign atau cuti panjang
- **JWT_Token**: JSON Web Token yang digunakan untuk autentikasi setiap permintaan ke API
- **Response_Envelope**: Format respons standar API: `{"isSuccess": bool, "message": str, "data": ...}`

---

## Persyaratan

### Persyaratan 1: Penambahan Karyawan Baru

**User Story:** Sebagai Admin, saya ingin menambahkan karyawan baru ke dalam sistem, sehingga data karyawan tersimpan sejak hari pertama bergabung.

#### Kriteria Penerimaan

1. WHEN Admin mengirimkan permintaan `POST /api/Employees` dengan payload data karyawan yang valid, THE API SHALL menyimpan data karyawan baru ke database dan mengembalikan Response_Envelope dengan `isSuccess: true` beserta data karyawan yang baru dibuat.

2. WHEN Admin mengirimkan permintaan `POST /api/Employees` dengan `email` yang sudah terdaftar di sistem, THE API SHALL mengembalikan Response_Envelope dengan `isSuccess: false` dan pesan error yang menjelaskan email sudah digunakan.

3. WHEN Admin mengirimkan permintaan `POST /api/Employees` dengan `employee_id` yang sudah terdaftar di sistem, THE API SHALL mengembalikan Response_Envelope dengan `isSuccess: false` dan pesan error yang menjelaskan ID karyawan sudah digunakan.

4. WHEN Admin mengirimkan permintaan `POST /api/Employees` dengan field wajib yang kosong (nama, email, employee_id, department_id, designation, joining_date), THE API SHALL mengembalikan Response_Envelope dengan `isSuccess: false` dan daftar field yang tidak lengkap.

5. THE API SHALL menetapkan nilai default `status_id = 1` (aktif), `type_id = 2` (employee), dan `basic_salary = 0.0` untuk setiap karyawan baru yang dibuat tanpa nilai eksplisit pada field tersebut.

6. WHEN Admin berhasil menambahkan karyawan baru, THE API SHALL secara otomatis membuat record `EmployeeContactInfo` kosong dengan `id` yang sama dengan karyawan baru tersebut.

7. WHERE fitur tambah karyawan diakses oleh pengguna dengan `type_id = 2` (Employee), THE API SHALL mengembalikan respons HTTP 403 Forbidden.

8. WHEN Client menampilkan formulir penambahan karyawan baru, THE Client SHALL menampilkan semua field wajib (nama, employee_id, email, department, designation, joining_date) dengan indikator visual yang jelas bahwa field tersebut wajib diisi.

---

### Persyaratan 2: Manajemen Departemen

**User Story:** Sebagai Admin, saya ingin mengelola daftar departemen dan jabatan, sehingga struktur organisasi perusahaan terdefinisi dengan baik untuk pengelompokan karyawan.

#### Kriteria Penerimaan

1. THE API SHALL menyediakan endpoint `GET /api/Departments` yang mengembalikan daftar semua departemen beserta daftar jabatan (designation) di setiap departemen dalam Response_Envelope.

2. WHEN Admin mengirimkan `POST /api/Departments` dengan nama departemen yang valid dan unik, THE API SHALL menyimpan departemen baru dan mengembalikan data departemen yang dibuat.

3. IF nama departemen yang dikirimkan pada `POST /api/Departments` sudah ada di database, THEN THE API SHALL mengembalikan `isSuccess: false` dengan pesan error duplikasi nama.

4. WHEN Admin mengirimkan `PUT /api/Departments/{id}` dengan data departemen yang valid, THE API SHALL memperbarui data departemen dan mengembalikan `isSuccess: true`.

5. THE System SHALL mengasosiasikan setiap karyawan dengan satu departemen melalui field `department_id` pada model Employee.

6. WHEN Client menampilkan formulir karyawan, THE Client SHALL memuat daftar departemen dari API dan menampilkannya sebagai dropdown pilihan.

---

### Persyaratan 3: Update Informasi Karyawan Lengkap (oleh Admin)

**User Story:** Sebagai Admin, saya ingin memperbarui semua informasi karyawan termasuk jabatan, departemen, dan gaji pokok, sehingga data SDM selalu akurat dan terkini.

#### Kriteria Penerimaan

1. WHEN Admin mengirimkan `PUT /api/Employees/{id}` dengan payload yang berisi perubahan data kepegawaian (designation, department_id, supervisor_id, status_id, joining_date, permanent_date), THE API SHALL memperbarui field-field tersebut dan mengembalikan `isSuccess: true`.

2. WHEN Admin mengirimkan `PUT /api/Employees/{id}` dengan perubahan `basic_salary`, THE API SHALL memperbarui nilai gaji pokok karyawan dan mengembalikan `isSuccess: true`.

3. WHEN Employee (bukan Admin) mengirimkan `PUT /api/Employees/{id}` dengan perubahan pada field kepegawaian (designation, department_id, basic_salary, supervisor_id, status_id), THE API SHALL mengabaikan perubahan pada field-field tersebut dan hanya memproses perubahan yang diizinkan (nama, kontak, alamat).

4. IF `id` karyawan yang diminta pada `PUT /api/Employees/{id}` tidak ditemukan di database, THEN THE API SHALL mengembalikan `isSuccess: false` dengan pesan "Karyawan tidak ditemukan".

5. WHEN Admin memperbarui `designation` atau `department_id` karyawan, THE API SHALL secara otomatis mencatat perubahan tersebut sebagai record baru di tabel `employee_transfers` dengan timestamp saat ini.

---

### Persyaratan 4: Nonaktifkan Karyawan (Resign/Pensiun)

**User Story:** Sebagai Admin, saya ingin menonaktifkan karyawan yang resign atau pensiun tanpa menghapus data historis mereka, sehingga integritas riwayat kehadiran, cuti, dan payroll tetap terjaga.

#### Kriteria Penerimaan

1. WHEN Admin mengirimkan `PUT /api/Employees/{id}/deactivate` dengan `effective_date` dan `reason`, THE API SHALL mengubah `status_id` karyawan menjadi `2` (nonaktif) dan menyimpan tanggal efektif beserta alasan nonaktif.

2. WHILE status karyawan adalah nonaktif (`status_id = 2`), THE API SHALL tetap mengembalikan data karyawan tersebut pada endpoint `GET /api/Employees` tanpa menghapus record apapun yang berkaitan.

3. WHEN Admin mengirimkan `PUT /api/Employees/{id}/deactivate` untuk karyawan yang sudah berstatus nonaktif, THE API SHALL mengembalikan `isSuccess: false` dengan pesan yang menjelaskan karyawan sudah berstatus nonaktif.

4. WHERE fitur nonaktifkan karyawan diakses oleh pengguna dengan `type_id = 2`, THE API SHALL mengembalikan respons HTTP 403 Forbidden.

5. WHEN Client menampilkan daftar karyawan, THE Client SHALL menampilkan indikator status visual yang berbeda antara karyawan aktif dan nonaktif (misalnya warna atau badge).

---

### Persyaratan 5: Riwayat Transfer Karyawan

**User Story:** Sebagai Admin, saya ingin melihat dan mencatat riwayat perpindahan departemen atau perubahan jabatan seorang karyawan, sehingga histori karier karyawan tersebut dapat dilacak.

#### Kriteria Penerimaan

1. THE API SHALL menyediakan endpoint `GET /api/Employees/{id}/transfers` yang mengembalikan daftar riwayat transfer karyawan secara kronologis (terbaru lebih dulu) dalam Response_Envelope.

2. WHEN Admin mengirimkan `POST /api/Employees/{id}/transfers` dengan `from_department_id`, `to_department_id`, `from_designation`, `to_designation`, `effective_date`, dan `reason`, THE API SHALL menyimpan record transfer baru dan mengembalikan `isSuccess: true`.

3. IF `from_department_id` atau `to_department_id` pada permintaan transfer tidak ditemukan di tabel departemen, THEN THE API SHALL mengembalikan `isSuccess: false` dengan pesan error yang menyebutkan departemen yang tidak valid.

4. THE System SHALL menyimpan setiap record transfer dengan minimal field: `employee_id`, `from_department_id`, `from_designation`, `to_department_id`, `to_designation`, `effective_date`, `reason`, `created_by`, `created_at`.

5. WHEN Client menampilkan halaman detail karyawan, THE Client SHALL menampilkan tab atau seksi "Riwayat Transfer" yang memuat daftar riwayat transfer karyawan tersebut.

---

### Persyaratan 6: Manajemen Status PTKP

**User Story:** Sebagai Admin, saya ingin mengelola status PTKP setiap karyawan, sehingga perhitungan pajak PPh 21 pada payslip akurat sesuai kondisi keluarga karyawan.

#### Kriteria Penerimaan

1. THE System SHALL mendefinisikan tabel referensi `ptkp_statuses` yang memuat kode PTKP standar DJP Indonesia: TK/0, TK/1, TK/2, TK/3, K/0, K/1, K/2, K/3 beserta nilai PTKP tahunan yang berlaku.

2. THE API SHALL menyediakan endpoint `GET /api/PtkpStatuses` yang mengembalikan daftar semua kode PTKP dan nilai tahunannya dalam Response_Envelope.

3. WHEN Admin mengirimkan `PUT /api/Employees/{id}/ptkp` dengan `ptkp_status_id` yang valid, THE API SHALL memperbarui status PTKP karyawan dan mengembalikan `isSuccess: true`.

4. IF `ptkp_status_id` yang dikirimkan pada `PUT /api/Employees/{id}/ptkp` tidak ditemukan di tabel `ptkp_statuses`, THEN THE API SHALL mengembalikan `isSuccess: false` dengan pesan "Kode PTKP tidak valid".

5. WHEN Admin memperbarui status PTKP karyawan, THE API SHALL menyimpan riwayat perubahan PTKP dengan field: `employee_id`, `old_ptkp_status_id`, `new_ptkp_status_id`, `effective_date`, `changed_by`, `created_at`.

6. WHEN endpoint `GET /api/Payroll/GetPayslip` dipanggil untuk karyawan yang memiliki status PTKP terdaftar, THE API SHALL menggunakan nilai PTKP karyawan tersebut dalam perhitungan AIT (PPh 21), menggantikan perhitungan flat 10% yang saat ini digunakan.

7. WHERE fitur pengelolaan PTKP diakses oleh pengguna dengan `type_id = 2`, THE API SHALL mengembalikan respons HTTP 403 Forbidden.

---

### Persyaratan 7: Impor Massal Karyawan (Bulk Import)

**User Story:** Sebagai Admin, saya ingin mengimpor data banyak karyawan sekaligus dari file, sehingga proses onboarding batch dapat dilakukan secara efisien tanpa input manual satu per satu.

#### Kriteria Penerimaan

1. THE API SHALL menyediakan endpoint `POST /api/Employees/import` yang menerima file dalam format CSV atau Excel (.xlsx) dengan encoding UTF-8.

2. WHEN Admin mengunggah file impor yang valid, THE API SHALL memvalidasi setiap baris data sebelum menyimpan ke database dan mengembalikan laporan hasil impor yang mencantumkan: jumlah baris berhasil diimpor, jumlah baris gagal, dan daftar error per baris.

3. THE API SHALL menetapkan kolom wajib dalam file impor sebagai: `employee_id`, `name`, `email`, `designation`, `department_id`, `joining_date`. IF satu atau lebih kolom wajib tidak ada dalam file, THEN THE API SHALL menolak seluruh file dan mengembalikan `isSuccess: false` dengan daftar kolom yang hilang.

4. WHEN file impor berisi baris dengan `email` atau `employee_id` yang sudah terdaftar di sistem, THE API SHALL melewati baris tersebut tanpa menghentikan proses impor baris lain, dan mencatat baris tersebut sebagai "gagal - duplikat" pada laporan hasil.

5. WHEN file impor berhasil diproses, THE API SHALL mengembalikan `isSuccess: true` beserta ringkasan impor dalam field `data`: `{total_rows, success_count, failed_count, errors: [{row, field, message}]}`.

6. THE API SHALL menyediakan endpoint `GET /api/Employees/importTemplate` yang mengembalikan file CSV template dengan header kolom yang benar sebagai panduan pengisian file impor.

7. WHERE fitur impor massal diakses oleh pengguna dengan `type_id = 2`, THE API SHALL mengembalikan respons HTTP 403 Forbidden.

8. WHEN Client menampilkan halaman impor karyawan, THE Client SHALL menyediakan tombol untuk mengunduh template CSV dan tombol untuk memilih dan mengunggah file dari perangkat.

---

### Persyaratan 8: Manpower Planning — Target Headcount

**User Story:** Sebagai Admin, saya ingin menetapkan target jumlah karyawan per bulan per departemen dan jabatan, sehingga kebutuhan rekrutmen dapat direncanakan secara proaktif.

#### Kriteria Penerimaan

1. THE API SHALL menyediakan endpoint `POST /api/ManpowerPlans` yang menerima payload berisi `department_id`, `designation`, `plan_year`, `plan_month`, `target_headcount`, dan `notes` opsional, lalu menyimpannya ke database.

2. WHEN Admin mengirimkan `POST /api/ManpowerPlans` dengan kombinasi `department_id`, `designation`, `plan_year`, `plan_month` yang sudah ada, THE API SHALL memperbarui record yang ada (upsert) dan mengembalikan `isSuccess: true`.

3. THE API SHALL menyediakan endpoint `GET /api/ManpowerPlans` yang mendukung filter `year`, `month`, dan `department_id` via query parameter, dan mengembalikan daftar rencana headcount yang sesuai filter.

4. WHEN Admin mengakses laporan manpower planning melalui `GET /api/ManpowerPlans/summary`, THE API SHALL mengembalikan data yang membandingkan `target_headcount` dengan jumlah karyawan aktif (`actual_headcount`) per departemen per jabatan untuk periode yang diminta.

5. IF `target_headcount` yang dikirimkan pada `POST /api/ManpowerPlans` bernilai kurang dari `1`, THEN THE API SHALL mengembalikan `isSuccess: false` dengan pesan "Target headcount harus minimal 1".

6. WHERE fitur manpower planning diakses oleh pengguna dengan `type_id = 2`, THE API SHALL mengembalikan respons HTTP 403 Forbidden.

7. WHEN Client menampilkan halaman Manpower Planning, THE Client SHALL menampilkan perbandingan antara target headcount dan jumlah karyawan aktual dalam bentuk tabel yang dapat difilter berdasarkan departemen dan periode bulan/tahun.

---

### Persyaratan 9: Manpower Planning — Tracking Karyawan Pengganti

**User Story:** Sebagai Admin, saya ingin mencatat dan memantau status karyawan pengganti ketika ada karyawan yang resign atau mengambil cuti panjang, sehingga kesinambungan operasional dapat dijaga.

#### Kriteria Penerimaan

1. THE API SHALL menyediakan endpoint `POST /api/ReplacementTrackings` yang menerima `departing_employee_id`, `replacement_employee_id` (opsional jika belum ada pengganti), `department_id`, `designation`, `departure_reason` (nilai yang valid: "Resign", "Long_Leave", "Transfer"), `effective_date`, dan `expected_fill_date`.

2. WHEN Admin mengirimkan `POST /api/ReplacementTrackings` dengan `departing_employee_id` yang tidak ditemukan di database, THE API SHALL mengembalikan `isSuccess: false` dengan pesan "Karyawan yang akan digantikan tidak ditemukan".

3. THE API SHALL menyediakan endpoint `GET /api/ReplacementTrackings` dengan filter opsional `department_id` dan `status` (nilai yang valid: "Open", "Filled", "Cancelled"), yang mengembalikan daftar kebutuhan penggantian dalam Response_Envelope.

4. WHEN Admin mengirimkan `PUT /api/ReplacementTrackings/{id}` dengan `replacement_employee_id` yang valid dan `fill_date`, THE API SHALL memperbarui status tracking menjadi "Filled" dan mencatat tanggal penggantian terpenuhi.

5. WHEN Admin mengirimkan `PUT /api/ReplacementTrackings/{id}` dengan `status = "Cancelled"` beserta alasan pembatalan, THE API SHALL memperbarui status tracking menjadi "Cancelled" tanpa menghapus record.

6. WHILE terdapat kebutuhan penggantian dengan status "Open" yang melewati `expected_fill_date`, THE API SHALL menandai record tersebut dengan flag `is_overdue = true` saat data dikembalikan ke client.

7. WHEN Client menampilkan halaman Replacement Tracking, THE Client SHALL menampilkan daftar kebutuhan penggantian yang dikelompokkan berdasarkan status ("Open", "Filled", "Cancelled") dengan indikator visual berbeda untuk record yang sudah melewati tanggal target.

---

### Persyaratan 10: Tampilan Profil Karyawan Lengkap

**User Story:** Sebagai Admin atau Employee, saya ingin melihat profil lengkap karyawan dalam satu halaman terstruktur, sehingga semua informasi yang diperlukan mudah ditemukan tanpa berpindah halaman.

#### Kriteria Penerimaan

1. THE API SHALL memperluas respons `GET /api/Employees/profile?id=` untuk menyertakan `department_name`, `ptkp_status_code`, `ptkp_annual_value`, dan ringkasan transfer terakhir (`last_transfer_date`, `last_from_designation`, `last_to_designation`).

2. WHEN Client menampilkan halaman detail karyawan, THE Client SHALL mengelompokkan informasi dalam seksi-seksi terpisah: "Informasi Pribadi", "Kepegawaian", "Kontak & Keluarga", "Payroll", dan "Riwayat Transfer".

3. WHILE pengguna yang mengakses halaman profil memiliki `type_id = 2` (Employee) dan mengakses profil diri sendiri, THE Client SHALL menampilkan semua seksi informasi tetapi menyembunyikan field `basic_salary` dan informasi payroll detail.

4. WHERE pengguna yang mengakses halaman profil adalah Admin (`type_id = 1`), THE Client SHALL menampilkan tombol "Edit" yang memberikan akses ke semua field yang dapat diedit termasuk data kepegawaian dan payroll.

5. WHEN Client menampilkan daftar karyawan di halaman Employee List, THE Client SHALL mendukung pencarian berdasarkan nama, employee_id, dan departemen secara real-time tanpa memerlukan pemanggilan API tambahan.

---

### Persyaratan 11: Keamanan dan Otorisasi

**User Story:** Sebagai sistem, saya ingin memastikan hanya pengguna yang berwenang yang dapat mengakses atau memodifikasi data karyawan, sehingga integritas dan privasi data SDM terlindungi.

#### Kriteria Penerimaan

1. WHEN permintaan ke semua endpoint `/api/Employees*`, `/api/Departments*`, `/api/ManpowerPlans*`, `/api/ReplacementTrackings*`, dan `/api/PtkpStatuses*` diterima tanpa header `Authorization` yang valid, THE API SHALL mengembalikan respons HTTP 401 Unauthorized.

2. THE System SHALL menerapkan kontrol akses berbasis peran (Role-Based Access Control) berikut:
   - Admin (`type_id = 1`): akses penuh (baca, tambah, edit, nonaktifkan) untuk semua karyawan
   - Employee (`type_id = 2`): hanya dapat membaca profil sendiri dan memperbarui field kontak/alamat sendiri

3. WHEN Employee mengirimkan permintaan baca (`GET`) ke profil karyawan lain melalui `GET /api/Employees/profile?id=X` (di mana X bukan id karyawan tersebut), THE API SHALL mengembalikan HTTP 403 Forbidden.

4. IF JWT_Token yang dikirimkan pada header `Authorization` sudah kedaluwarsa, THEN THE API SHALL mengembalikan HTTP 401 Unauthorized dengan pesan "Token telah kedaluwarsa".

5. THE API SHALL mencatat audit log untuk operasi tulis (create, update, deactivate) pada data karyawan, menyimpan minimal: `action`, `target_employee_id`, `performed_by`, `timestamp`, dan `changed_fields`.

---

### Persyaratan 12: Sinkronisasi dan Konsistensi Data

**User Story:** Sebagai sistem, saya ingin memastikan data karyawan tetap konsisten di seluruh fitur yang bergantung padanya, sehingga payslip, absensi, dan perencanaan SDM selalu mencerminkan data terkini.

#### Kriteria Penerimaan

1. WHEN status karyawan diubah menjadi nonaktif (`status_id = 2`), THE System SHALL tetap mempertahankan semua record Attendance, UserLeave, Overtime, dan payslip historis karyawan tersebut tanpa penghapusan.

2. WHEN departemen karyawan diperbarui melalui `PUT /api/Employees/{id}`, THE System SHALL secara otomatis memperbarui field `actual_headcount` pada kalkulasi Manpower_Plan untuk departemen lama dan departemen baru.

3. WHEN data karyawan yang terkait dengan perhitungan payroll diperbarui (basic_salary, ptkp_status_id), THE API SHALL mengembalikan flag `payroll_recalculation_needed: true` dalam respons sehingga Client dapat menginformasikan Admin bahwa payslip bulan berjalan perlu diregenerasi.

4. FOR ALL operasi impor massal, THE System SHALL menggunakan transaksi database sehingga kegagalan pada satu baris tidak mempengaruhi baris lain yang valid dalam batch yang sama.
