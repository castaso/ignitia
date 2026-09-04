"""Supabase SSO — POST /api/Login/supabase"""
import jwt
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
