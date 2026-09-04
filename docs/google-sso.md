# Google SSO via Supabase — Setup Guide (shared project)

This project uses **one Supabase project** for both Dashboard (web) and Android.

## 1) Create Supabase project
- https://supabase.com → New project → note **Project URL** and **anon key** + **JWT Secret** (Project Settings → API).

## 2) Google Cloud OAuth
- https://console.cloud.google.com → APIs & Services → Credentials → Create OAuth client:
  - Web application: Authorized redirect URI = `https://<project>.supabase.co/auth/v1/callback`
  - Copy Client ID + Client Secret.

## 3) Supabase Auth → Providers
- Dashboard → Authentication → Providers → Google → Enable, paste Client ID/Secret.
- Authentication → URL Configuration:
  - Site URL: your web origin, e.g. `http://localhost:3000` (dev) / `https://yourdomain.com` (prod)
  - Additional Redirect URLs: add `http://localhost:*/`, production web origin, **and** `com.naas.i_employment://login-callback` (Android), `http://localhost:*/` already covers dashboard dev.

## 4) Server env
Copy `ignitia_server/.env.example` to `.env` and set:
```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_JWT_SECRET=<jwt-secret from API settings>
```
Empty values → `POST /api/Login/supabase` returns 503 (SSO disabled, email login still works).

## 5) Clients
Shared Supabase project — same URL/anonKey for both:
```
# Dashboard web
flutter run -d chrome --dart-define=SUPABASE_URL=https://<project>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon> --dart-define=API_BASE_URL=http://localhost:86/api/ --target lib/main.dart
flutter build web --dart-define=... (same)

# Android
flutter run --dart-define=SUPABASE_URL=https://<project>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon>
```
If defines are missing, the “Sign in with Google” button shows *Google SSO not configured* toast.

## 6) Android deep link
`android/app/src/main/AndroidManifest.xml` already has `com.naas.i_employment://login-callback` intent-filter. Ensure the Supabase redirect URL above matches exactly. For release, add SHA-1/SHA-256 from your keystore to Google Cloud OAuth client.

## 7) Verify
- Unknown Google email → 404 `Account not found` (no auto-provision, per spec).
- Inactive employee → 401.
- Valid Google user whose email exists in `employees` → returns app JWT, same session as email login.

## Env summary
| Place | Vars | Source |
|-------|------|--------|
| Server `.env` | `SUPABASE_URL`, `SUPABASE_JWT_SECRET` | Supabase Project Settings → API |
| Flutter `--dart-define` | `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Same project |

See `ignitia_server/tests/test_login_supabase.py` for expected server behavior.

