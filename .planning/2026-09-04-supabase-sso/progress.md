# Progress — Supabase Google SSO

## Session 2026-09-04
- Created isolated plan .planning/2026-09-04-supabase-sso, set active, wrote task_plan/findings/progress
- Phase 0 complete

## Phase 1 Server
- config.py SUPABASE_URL/JWT_SECRET, security.py verify_supabase_token, login.py POST /Login/supabase (503/401/404/200), .env.example
- tests/test_login_supabase.py 6 tests
- pytest 85 passed

## Phase 2 Dashboard Web
- pubspec supabase_flutter 2.16, api_service loginWithSupabase, login_services supabaseLogin, login_view_model doGoogleLogin (OAuth web redirectTo Uri.base.origin), main Supabase.initialize via dart-define, login_screen Google button + divider

## Phase 3 Android
- same pubspec/api_service/login_services/view_model (redirectTo com.naas.i_employment://login-callback), main Supabase init, login_screen Google button, AndroidManifest deep-link intent-filter

## Phase 4 Docs & Verify
- docs/google-sso.md shared project guide
- pytest 85 pass verified; flutter pub get both apps succeeded (dashboard 18 deps changed, android 24 deps); manual g.dart patched (build_runner timeout avoided)

## Error Log
- build_runner timeout 120s (expected large build) -> manual patch of api_service.g.dart instead
- tail pipeline error -> switched to Select-Object

## Test Results
- pytest: 85 passed
- flutter analyze: pending full (timeout 120s, likely still ok; pub get success)

## Phase 5 — Wire live Supabase creds + E2E (2026-09-04)
- User supplied shared-project creds (project ref `rtamczdkyiwbesapmuxj`): SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_JWT_SECRET
- Created `ignitia_server/.env` (git-ignored, line .gitignore:7) with URL + JWT_SECRET only (secret never to git/clients/docs)
- Verified anon key accepted by Supabase GoTrue (apikey check passes; rejected reserved example.com test email)
- Verified JWT secret: anon key signature validates against raw-string secret (base64-decoded fails) -> server verify_supabase_token uses raw string ✓
- Live E2E against running server (python run.py), token crafted signed with real secret (iss=supabase, role/aud=authenticated, exp):
  | case | result |
  |------|--------|
  | valid signed, unknown email | 404 Account not found (sig pass + email extract + DB lookup) ✓ |
  | expired | 401 Supabase session expired ✓ |
  | wrong signature | 401 Invalid Supabase token ✓ |
  | missing | 401 Missing Supabase token ✓ |
- Server SSO path LIVE; code already in ebdf3db (pushed)
- **Blocked on user:** enable Google provider in Supabase Dashboard + add redirect URLs (web origin, localhost:*, com.naas.i_employment://login-callback) + Google Cloud OAuth client -> then run clients with --dart-define

## Phase 6 — Compile fix + full verification (2026-09-04)
- BUG: committed ebdf3db used `Provider.google` (won't compile — `Provider` is the state-mgmt class, no `.google`)
- FIX: supabase/gotrue OAuth enum is `OAuthProvider.google` (gotrue lib/types.dart:40 `static const google = OAuthProvider('google')`, re-exported via supabase_flutter; matches doc example supabase_auth.dart:313). Changed dashboard login_view_model.dart:89 + android login_view_model.dart:90
- Confirmed `onAuthStateChange` + `data.session` correct (package's own listener supabase_auth.dart:89-91)
- flutter analyze dashboard: 279 issues (all info/warning), **0 errors**; my SSO files clean
- flutter analyze android: 658 issues, 10 `const_with_non_const` errors — all in pre-existing settings pages (never touched, surfaced for first time in this toolchain), 0 in my SSO files
- flutter build web --release: **Built build/web, exit 0** (311s) — definitive compile proof
