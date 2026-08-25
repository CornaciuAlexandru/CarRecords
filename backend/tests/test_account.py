"""Teste pentru recuperarea contului, confirmarea adresei si stergerea contului.

Emailurile nu pleaca nicaieri in teste: `app.core.email.outbox` pastreaza
ultimele mesaje "trimise", de unde se citeste linkul.
"""
from datetime import timedelta
from urllib.parse import parse_qs, urlparse

from app.core.email import outbox
from app.core.security import utcnow
from app.core.database import SessionLocal
from app.models.car import Car
from app.models.email_token import EmailToken
from app.models.user import User
from tests.conftest import auth, make_car, make_user


def last_link() -> str:
    """Linkul din ultimul email trimis."""
    assert outbox, "nu s-a trimis niciun email"
    for line in outbox[-1]["text"].splitlines():
        if line.startswith("http"):
            return line.strip()
    raise AssertionError("emailul nu contine niciun link")


def token_from(link: str) -> str:
    return parse_qs(urlparse(link).query)["token"][0]


def register(client, email: str, password: str = "Test1234", **extra) -> dict:
    r = client.post("/api/v1/auth/register", json={
        "email": email, "password": password, "full_name": "Test", **extra})
    assert r.status_code == 201, r.text
    return r.json()


# ── Resetarea parolei ────────────────────────────────────────────────

def test_forgot_password_sends_link(client):
    register(client, "reset_send@gmail.com")
    outbox.clear()

    r = client.post("/api/v1/auth/forgot-password", json={"email": "reset_send@gmail.com"})
    assert r.status_code == 204
    assert outbox[-1]["to"] == "reset_send@gmail.com"
    assert "/auth/reset-password?token=" in last_link()


def test_forgot_password_unknown_email_says_nothing(client):
    """Acelasi raspuns si pentru adrese inexistente — altfel endpointul ar
    dezvalui cine are cont."""
    outbox.clear()
    r = client.post("/api/v1/auth/forgot-password", json={"email": "nimeni@gmail.com"})
    assert r.status_code == 204
    assert outbox == []


def test_reset_password_changes_password(client):
    register(client, "reset_ok@gmail.com")
    client.post("/api/v1/auth/forgot-password", json={"email": "reset_ok@gmail.com"})
    token = token_from(last_link())

    r = client.post("/api/v1/auth/reset-password",
                    json={"token": token, "new_password": "ParolaNoua9"})
    assert r.status_code == 204

    assert client.post("/api/v1/auth/login", json={
        "email": "reset_ok@gmail.com", "password": "ParolaNoua9"}).status_code == 200
    assert client.post("/api/v1/auth/login", json={
        "email": "reset_ok@gmail.com", "password": "Test1234"}).status_code == 401


def test_reset_token_works_only_once(client):
    register(client, "reset_once@gmail.com")
    client.post("/api/v1/auth/forgot-password", json={"email": "reset_once@gmail.com"})
    token = token_from(last_link())

    assert client.post("/api/v1/auth/reset-password",
                       json={"token": token, "new_password": "Prima1234"}).status_code == 204
    assert client.post("/api/v1/auth/reset-password",
                       json={"token": token, "new_password": "ADoua1234"}).status_code == 400


def test_new_reset_link_invalidates_the_previous_one(client):
    register(client, "reset_two@gmail.com")
    client.post("/api/v1/auth/forgot-password", json={"email": "reset_two@gmail.com"})
    first = token_from(last_link())
    client.post("/api/v1/auth/forgot-password", json={"email": "reset_two@gmail.com"})
    second = token_from(last_link())

    assert first != second
    assert client.post("/api/v1/auth/reset-password",
                       json={"token": first, "new_password": "Veche1234"}).status_code == 400
    assert client.post("/api/v1/auth/reset-password",
                       json={"token": second, "new_password": "Noua12345"}).status_code == 204


def test_expired_reset_token_rejected(client):
    register(client, "reset_exp@gmail.com")
    client.post("/api/v1/auth/forgot-password", json={"email": "reset_exp@gmail.com"})
    token = token_from(last_link())

    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == "reset_exp@gmail.com").first()
        (db.query(EmailToken)
           .filter(EmailToken.user_id == user.id, EmailToken.purpose == "reset")
           .update({"expires_at": utcnow() - timedelta(minutes=1)}))
        db.commit()
    finally:
        db.close()

    assert client.post("/api/v1/auth/reset-password",
                       json={"token": token, "new_password": "Expirat123"}).status_code == 400


def test_reset_rejects_weak_password(client):
    register(client, "reset_weak@gmail.com")
    client.post("/api/v1/auth/forgot-password", json={"email": "reset_weak@gmail.com"})
    token = token_from(last_link())

    assert client.post("/api/v1/auth/reset-password",
                       json={"token": token, "new_password": "scurt"}).status_code == 422


def test_reset_ends_existing_sessions(client):
    """Cine reseteaza parola nu mai vrea sesiunile vechi active."""
    tokens = register(client, "reset_sess@gmail.com")
    client.post("/api/v1/auth/forgot-password", json={"email": "reset_sess@gmail.com"})
    client.post("/api/v1/auth/reset-password",
                json={"token": token_from(last_link()), "new_password": "AltaParola1"})

    assert client.get("/api/v1/auth/me",
                      headers=auth(tokens["access_token"])).status_code == 401
    assert client.post("/api/v1/auth/refresh",
                       json={"refresh_token": tokens["refresh_token"]}).status_code == 401


def test_reset_page_is_served_and_checks_the_token(client):
    register(client, "reset_page@gmail.com")
    client.post("/api/v1/auth/forgot-password", json={"email": "reset_page@gmail.com"})
    token = token_from(last_link())

    ok = client.get(f"/api/v1/auth/reset-password?token={token}&lang=ro")
    assert ok.status_code == 200
    assert "Parolă nouă" in ok.text

    assert client.get("/api/v1/auth/reset-password?token=inventat").status_code == 400


def test_forgot_password_is_rate_limited(client):
    register(client, "reset_rate@gmail.com")
    for _ in range(3):
        assert client.post("/api/v1/auth/forgot-password",
                           json={"email": "reset_rate@gmail.com"}).status_code == 204
    assert client.post("/api/v1/auth/forgot-password",
                       json={"email": "reset_rate@gmail.com"}).status_code == 429


# ── Confirmarea adresei de email ─────────────────────────────────────

def test_registration_sends_verification_email(client):
    outbox.clear()
    data = register(client, "verify_new@gmail.com", lang="ro")
    assert data["user"]["email_verified"] is False
    assert outbox[-1]["to"] == "verify_new@gmail.com"
    assert "/auth/verify-email?token=" in last_link()


def test_verification_link_confirms_the_address(client):
    tokens = register(client, "verify_ok@gmail.com")
    link = last_link()

    page = client.get(link.replace("http://127.0.0.1:8000", ""))
    assert page.status_code == 200

    me = client.get("/api/v1/auth/me", headers=auth(tokens["access_token"]))
    assert me.json()["email_verified"] is True


def test_verification_via_api_confirms_the_address(client):
    tokens = register(client, "verify_api@gmail.com")
    token = token_from(last_link())

    r = client.post("/api/v1/auth/verify-email", json={"token": token})
    assert r.status_code == 200 and r.json()["email_verified"] is True
    assert client.get("/api/v1/auth/me",
                      headers=auth(tokens["access_token"])).json()["email_verified"] is True


def test_invalid_verification_token_rejected(client):
    assert client.post("/api/v1/auth/verify-email",
                       json={"token": "inventat"}).status_code == 400
    assert client.get("/api/v1/auth/verify-email?token=inventat").status_code == 400


def test_resend_verification_sends_a_new_link(client):
    tokens = register(client, "verify_resend@gmail.com")
    outbox.clear()

    r = client.post("/api/v1/auth/resend-verification", json={"lang": "ro"},
                    headers=auth(tokens["access_token"]))
    assert r.status_code == 204
    assert outbox[-1]["to"] == "verify_resend@gmail.com"

    # Dupa confirmare nu se mai trimite nimic
    client.post("/api/v1/auth/verify-email", json={"token": token_from(last_link())})
    outbox.clear()
    assert client.post("/api/v1/auth/resend-verification", json={},
                       headers=auth(tokens["access_token"])).status_code == 204
    assert outbox == []


def test_reset_also_confirms_the_address(client):
    """Cine primeste linkul pe email dovedeste ca adresa e a lui."""
    tokens = register(client, "verify_by_reset@gmail.com")
    client.post("/api/v1/auth/forgot-password", json={"email": "verify_by_reset@gmail.com"})
    client.post("/api/v1/auth/reset-password",
                json={"token": token_from(last_link()), "new_password": "DupaReset1"})

    new_tokens = client.post("/api/v1/auth/login", json={
        "email": "verify_by_reset@gmail.com", "password": "DupaReset1"}).json()
    assert new_tokens["user"]["email_verified"] is True


# ── Stergerea contului ───────────────────────────────────────────────

def test_delete_account_requires_the_password(client):
    tokens = register(client, "del_pwd@gmail.com")
    r = client.request("DELETE", "/api/v1/auth/me", json={"password": "Gresita9"},
                       headers=auth(tokens["access_token"]))
    assert r.status_code == 400
    assert client.get("/api/v1/auth/me", headers=auth(tokens["access_token"])).status_code == 200


def test_delete_account_removes_user_and_data(client):
    tokens = register(client, "del_ok@gmail.com")
    access = tokens["access_token"]
    car_id = make_car(client, access, plate="B-999-DEL")

    r = client.request("DELETE", "/api/v1/auth/me", json={"password": "Test1234"},
                       headers=auth(access))
    assert r.status_code == 204

    assert client.get("/api/v1/auth/me", headers=auth(access)).status_code == 401
    assert client.post("/api/v1/auth/login", json={
        "email": "del_ok@gmail.com", "password": "Test1234"}).status_code == 401
    assert client.post("/api/v1/auth/refresh",
                       json={"refresh_token": tokens["refresh_token"]}).status_code == 401

    db = SessionLocal()
    try:
        assert db.query(User).filter(User.email == "del_ok@gmail.com").first() is None
        assert db.query(Car).filter(Car.id == car_id).first() is None
    finally:
        db.close()


def test_delete_account_frees_the_email(client):
    """Adresa poate fi refolosita pentru un cont nou dupa stergere."""
    tokens = register(client, "del_reuse@gmail.com")
    client.request("DELETE", "/api/v1/auth/me", json={"password": "Test1234"},
                   headers=auth(tokens["access_token"]))
    register(client, "del_reuse@gmail.com", password="AltaParola1")


def test_delete_account_leaves_other_users_alone(client):
    victim = make_user(client, "del_other@gmail.com")
    victim_car = make_car(client, victim, plate="B-111-OTH")

    tokens = register(client, "del_self@gmail.com")
    client.request("DELETE", "/api/v1/auth/me", json={"password": "Test1234"},
                   headers=auth(tokens["access_token"]))

    cars = client.get("/api/v1/cars", headers=auth(victim))
    assert cars.status_code == 200
    assert [c["id"] for c in cars.json()] == [victim_car]
