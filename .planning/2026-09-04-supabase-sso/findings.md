# Findings — Supabase Google SSO

## Current auth (verified 2026-09-04)
- Server `login.py:59` POST /api/Login email/password → `security.py:69` create_token (HS256, sub=employee.id, exp=JWT_EXPIRE_HOURS) → `ok(data=employee_json:255, message=jwt)`. Failures 401. `security.py:38` hash PBKDF2, `verify_password:47`. `deps.py:11` get_current_employee decodes app JWT, checks status_id==1.
- Config `config.py:21` Settings via _env, `.env` via python-dotenv. No SUPABASE_* yet.
- Dashboard `lib/view_models/login_view_model.dart:51` doLogin → LoginServices.doLogin → _storeData:68 (FieldValue + SessionManager). `lib/views/login_screen.dart:1` email+password only. Same pattern Android `lib/view_models/login_view_model.dart:56`.
- No Google SSO anywhere; Android has firebase_core/messaging but no firebase_auth/google_sign_in.

## Supabase plan
- Add config.py SUPABASE_URL/JWT_SECRET (empty=disabled). security.py verify_supabase_token checks signature HS256 with SUPABASE_JWT_SECRET, exp, aud=authenticated, extracts email. login.py POST /Login/supabase verifies, lookup Employee.email lower, status check, create_token.
- Clients: supabase_flutter, dart-define URL/anonKey, Supabase.initialize guarded, doGoogleLogin → signInWithOAuth Google → session.accessToken → POST supabase → _storeData.
- Shared project, local verify, reject unknown.

## Verification targets
- pytest 85, flutter analyze 0, build web OK.

## Visual findings
- No UI image for this feature.
