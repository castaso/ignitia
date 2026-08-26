# Ignitia — Monorepo

Attendance Management System (Flutter + FastAPI) — monorepo containing all components.

## Structure

```
ignitia/
├── ignitia_server/      # FastAPI backend (Python) — attendance, payroll, leave, overtime, face verification
├── ignitia_dashboard/   # Flutter web — admin dashboard (holiday, overtime, shift, employee directory)
└── ignitia_android/     # Flutter mobile — i_employment app (GPS + face liveness attendance)
```

## Quick Start

### Server (Python)
```bash
cd ignitia_server
cp .env.example .env  # configure DB, FACE_* keys
pip install -r requirements.txt
python run.py          # or uvicorn app.main:app --reload
python seed.py         # seed data
```

### Dashboard (Flutter Web)
```bash
cd ignitia_dashboard
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

### Android / Mobile (Flutter)
```bash
cd ignitia_android
flutter pub get
flutter run
# release web override handled via _enablePlatformOverrideForDesktop in lib/main.dart:68
```

## Development

- **Monorepo:** single `main` branch at `castaso/ignitia` (public). Former separate repos (`ignitia_server`, `ignitia_dashboard`, `ignitia-android-legacy`) archived/deleted after migration.
- **CodeGraph:** unified index at `.codegraph/` (gitignored). Query via `codegraph explore "<symbols>"` or MCP `codegraph_explore` with `projectPath: "C:/Repo/GitHub.com/castaso/ignitia"`. Keep fresh with `codegraph sync`.
- **History:** fresh init (no preserved history). Backups of old `.git` bundles at `C:\Temp\ignitia_backup\` (server/dashboard/android).

## Tech Stack

- Backend: FastAPI, SQLAlchemy, face detection (YuNet/SFace ONNX) — `ignitia_server/requirements.txt:1`
- Mobile: Flutter + Dio + Geolocator + Provider + Firebase — `ignitia_android/pubspec.yaml`
- Dashboard: Flutter web + Retrofit + TrinaGrid — `ignitia_dashboard/pubspec.yaml`

## License

Private / internal — see previous repo licenses.
