# Task Plan: Google SSO via Supabase (Dashboard + Android + Server) — shared project

## Goal
Add “Sign in with Google” (Supabase Auth) to Dashboard Web and Android, verifying the Supabase access token on the server and issuing the existing app JWT; unknown emails rejected; single shared Supabase project; env-gated with graceful fallback.

## Next Step
Phase 1 server implementation — config, security, login router, env example, tests.

## Current Phase
Phase 1 — Server

## Phases

### Phase 0: Planning & Discovery
- [x] Inspect current auth (server login.py:59, security.py:38/69, dashboard login_services/view_model/login_screen, android mirrors, config.py)
- [x] Decisions: Supabase brokers Google only, app JWT stays canonical; local JWT verify via SUPABASE_JWT_SECRET (pyjwt existing); reject unknown 404; shared Supabase project; code-now configure-later (empty SUPABASE_* → 503/toast guard)
- [x] Create isolated plan .planning/2026-09-04-supabase-sso + set active
- **Status:** complete

### Phase 1: Server (`ignitia_server`)
- [ ] `app/config.py:74` add SUPABASE_URL, SUPABASE_JWT_SECRET ( _env default "")
- [ ] `app/security.py:69` add verify_supabase_token(token)->email (HS256, exp/aud/email checks, ValueError on fail)
- [ ] `app/routers/login.py:145` add POST /Login/supabase `{accessToken}` → 503 unconfigured / 401 invalid / 404 Account not found / 401 inactive / 200 ok(data=employee_json, message=appJWT) matching login():69
- [ ] `.env.example` add SUPABASE_URL, SUPABASE_JWT_SECRET with comments
- [ ] `tests/test_login_supabase.py` (forge HS256 JWT with test secret): active → app JWT, unknown → 404, inactive → 401, bad sig → 401, expired → 401, unconfigured → 503
- [ ] `pytest -q` green (85)
- **Status:** in_progress

### Phase 2: Dashboard Web (`ignitia_dashboard`)
- [ ] `pubspec.yaml:9` add supabase_flutter ^2.8
- [ ] `lib/main.dart:27` Supabase.initialize(url/anonKey from --dart-define, try/catch no-op if empty)
- [ ] `lib/repo/api_service.dart:41` @POST('Login/supabase') loginWithSupabase
- [ ] `lib/repo/login_services.dart:11` supabaseLogin(accessToken)
- [ ] `lib/view_models/login_view_model.dart:51` add doGoogleLogin() → signInWithOAuth(Provider.google, redirectTo: Uri.base.origin) → session.accessToken → supabaseLogin → _storeData (reuse)
- [ ] `lib/views/login_screen.dart:103` add “Sign in with Google” button + SSO-not-configured toast
- [ ] `flutter analyze` 0 errors, `flutter build web` OK
- **Status:** pending

### Phase 3: Android (`ignitia_android`)
- [ ] Same pubspec/main/api_service/login_services/view_model/login_screen as dashboard (redirectTo: 'com.naas.i_employment://login-callback')
- [ ] `android/app/src/main/AndroidManifest.xml` deep-link intent-filter for com.naas.i_employment://login-callback (if missing)
- [ ] `flutter analyze` 0 errors
- **Status:** pending

### Phase 4: Docs & Verification
- [ ] `docs/google-sso.md` (Google Cloud OAuth → Supabase Auth → URL Configuration → env + dart-define mapping, shared-project note)
- [ ] Full verify: pytest, flutter analyze (both apps), build web
- [ ] Update progress.md, check-complete
- **Status:** pending

## Key Questions
1. Firebase vs Supabase? → **Supabase** (shared project for both clients)
2. Which clients? → **Both** (dashboard + android)
3. Unknown email handling? → **Reject 404 “Account not found”**
4. Supabase project access? → **No** → code env-gated, configure later
5. Shared or separate Supabase project? → **Shared**
6. Verify via local JWT vs GoTrue HTTP? → **Local JWT (SUPABASE_JWT_SECRET, HS256)**
7. New server dep? → **No** (pyjwt already present)

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Supabase brokers Google only, app JWT stays canonical | Zero change to get_current_employee/create_token/deps.py and all Bearer callers |
| Local HS256 verify with SUPABASE_JWT_SECRET | No new dep, no network hop; reuses pyjwt; matches existing JWT pattern |
| Shared project | One URL/anonKey/JWT secret, one Google OAuth client, simpler ops |
| Reject unknown email 404 | User requested “account not found”, no auto-provision |
| Env-gated 503 + toast guard | Code ships safe before console configured; no hardcoding |
| dart-define for web anonKey/URL | Matches existing API_BASE_URL pattern |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
|       |         |            |

## Notes
- Redirects: web `Uri.base.origin`, android `com.naas.i_employment://login-callback` — both must be allowlisted in Supabase URL Configuration.
- Email match is case-insensitive lower().
