"""Supabase SSO — POST /api/Login/supabase"""
import jwt
from cryptography.hazmat.primitives.asymmetric import ec
from datetime import datetime, timedelta, timezone

from app.config import settings

TEST_SUPABASE_SECRET = "test-supabase-jwt-secret-32chars-long!!"
TEST_AUD = "authenticated"


def _supabase_jwt(email, secret=TEST_SUPABASE_SECRET, exp_delta_hours=1, aud=TEST_AUD):
    now = datetime.now(timezone.utc)
    payload = {
        "aud": aud,
        "exp": now + timedelta(hours=exp_delta_hours),
        "iat": now,
        "email": email,
        "role": "authenticated",
        "sub": "00000000-0000-0000-0000-000000000000",
    }
    return jwt.encode(payload, secret, algorithm="HS256")


def test_supabase_unconfigured_returns_503(client, monkeypatch):
    monkeypatch.setattr(settings, "SUPABASE_URL", "")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", "")
    r = client.post("/api/Login/supabase", json={"accessToken": "anything"})
    assert r.status_code == 503


def test_supabase_active_returns_app_jwt(client, monkeypatch):
    monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)
    tok = _supabase_jwt("demo@ignitia.local")
    r = client.post("/api/Login/supabase", json={"accessToken": tok})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["isSuccess"] is True
    assert body["data"]["email"] == "demo@ignitia.local"
    assert body["message"].count(".") == 2  # app JWT


def test_supabase_unknown_email_404(client, monkeypatch):
    monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)
    tok = _supabase_jwt("unknown@ignitia.local")
    r = client.post("/api/Login/supabase", json={"accessToken": tok})
    assert r.status_code == 404
    assert "Account not found" in r.json()["message"]


def test_supabase_inactive_401(client, monkeypatch):
    from app.database import SessionLocal
    from app.models import Employee
    db = SessionLocal()
    emp = db.query(Employee).filter(Employee.email == "demo@ignitia.local").first()
    orig = emp.status_id
    emp.status_id = 2
    db.commit()
    db.close()
    try:
        monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
        monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)
        tok = _supabase_jwt("demo@ignitia.local")
        r = client.post("/api/Login/supabase", json={"accessToken": tok})
        assert r.status_code == 401
    finally:
        db = SessionLocal()
        emp = db.query(Employee).filter(Employee.email == "demo@ignitia.local").first()
        emp.status_id = orig
        db.commit()
        db.close()


def test_supabase_bad_signature_401(client, monkeypatch):
    monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)
    tok = _supabase_jwt("demo@ignitia.local", secret="wrong-secret")
    r = client.post("/api/Login/supabase", json={"accessToken": tok})
    assert r.status_code == 401


def test_supabase_expired_401(client, monkeypatch):
    monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)
    tok = _supabase_jwt("demo@ignitia.local", exp_delta_hours=-1)
    r = client.post("/api/Login/supabase", json={"accessToken": tok})
    assert r.status_code == 401


def test_supabase_gmail_sso_returns_app_jwt(client, monkeypatch):
    monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)
    tok = _supabase_jwt("castasoft@gmail.com")
    r = client.post("/api/Login/supabase", json={"accessToken": tok})
    assert r.status_code == 200, r.text
    body = r.json()
    assert body["isSuccess"] is True
    assert body["data"]["email"] == "castasoft@gmail.com"
    assert body["data"]["type_id"] == 1
    assert body["message"].count(".") == 2


def test_supabase_email_in_user_metadata(client, monkeypatch):
    monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)
    now = datetime.now(timezone.utc)
    payload = {
        "aud": TEST_AUD,
        "exp": now + timedelta(hours=1),
        "iat": now,
        "role": "authenticated",
        "sub": "00000000-0000-0000-0000-000000000000",
        "user_metadata": {"email": "castasoft@gmail.com"},
    }
    tok = jwt.encode(payload, TEST_SUPABASE_SECRET, algorithm="HS256")
    r = client.post("/api/Login/supabase", json={"accessToken": tok})
    assert r.status_code == 200, r.text
    assert r.json()["data"]["email"] == "castasoft@gmail.com"


def test_supabase_personal_email_match(client, monkeypatch):
    monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)
    tok = _supabase_jwt("personal.sso@gmail.com")
    r = client.post("/api/Login/supabase", json={"accessToken": tok})
    assert r.status_code == 200, r.text
    assert r.json()["data"]["email"] == "work.personal@ignitia.local"


class _StubJWK:
    def __init__(self, key):
        self.key = key


class _StubJWKSClient:
    def __init__(self, key):
        self._key = key

    def get_signing_key_from_jwt(self, token):
        return _StubJWK(self._key)


def test_supabase_es256_signing_keys(client, monkeypatch):
    """Newer Supabase projects sign tokens with asymmetric keys published
    via JWKS; HS256 with the legacy secret no longer applies."""
    import app.security as security

    monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)

    private_key = ec.generate_private_key(ec.SECP256R1())
    stub = _StubJWKSClient(private_key.public_key())
    monkeypatch.setattr(security, "_supabase_jwks_client", lambda: stub)

    now = datetime.now(timezone.utc)
    payload = {
        "aud": TEST_AUD,
        "exp": now + timedelta(hours=1),
        "iat": now,
        "email": "castasoft@gmail.com",
        "role": "authenticated",
        "sub": "00000000-0000-0000-0000-000000000000",
    }
    tok = jwt.encode(payload, private_key, algorithm="ES256")
    r = client.post("/api/Login/supabase", json={"accessToken": tok})
    assert r.status_code == 200, r.text
    assert r.json()["data"]["email"] == "castasoft@gmail.com"
    assert r.json()["data"]["type_id"] == 1


def test_supabase_es256_expired_401(client, monkeypatch):
    import app.security as security

    monkeypatch.setattr(settings, "SUPABASE_URL", "https://test.supabase.co")
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", TEST_SUPABASE_SECRET)

    private_key = ec.generate_private_key(ec.SECP256R1())
    stub = _StubJWKSClient(private_key.public_key())
    monkeypatch.setattr(security, "_supabase_jwks_client", lambda: stub)

    now = datetime.now(timezone.utc)
    payload = {
        "aud": TEST_AUD,
        "exp": now - timedelta(hours=1),
        "iat": now - timedelta(hours=2),
        "email": "castasoft@gmail.com",
        "role": "authenticated",
        "sub": "00000000-0000-0000-0000-000000000000",
    }
    tok = jwt.encode(payload, private_key, algorithm="ES256")
    r = client.post("/api/Login/supabase", json={"accessToken": tok})
    assert r.status_code == 401
