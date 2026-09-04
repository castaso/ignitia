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
