"""Configurare comuna pentru teste — baza de date temporara, izolata."""
import os
import tempfile
from pathlib import Path

import pytest

# Baza de date de test: fisier temporar, sters dupa rulare.
# Trebuie setat INAINTE de importul aplicatiei.
_TMP_DB = Path(tempfile.gettempdir()) / "carrecords_test.db"
os.environ["DATABASE_URL"] = f"sqlite:///{_TMP_DB.as_posix()}"

from fastapi.testclient import TestClient  # noqa: E402
from app.main import app                    # noqa: E402
from app.core.database import SessionLocal, engine, Base  # noqa: E402
from app.models.user import User            # noqa: E402


@pytest.fixture(scope="session", autouse=True)
def _clean_db():
    """Sterge baza de test inainte si dupa intreaga sesiune."""
    if _TMP_DB.exists():
        _TMP_DB.unlink()
    yield
    engine.dispose()
    if _TMP_DB.exists():
        try:
            _TMP_DB.unlink()
        except PermissionError:
            pass


@pytest.fixture(scope="session")
def client():
    """Client HTTP de test — declanseaza si lifespan-ul aplicatiei."""
    with TestClient(app, raise_server_exceptions=False) as c:
        yield c


# ── Helpers ────────────────────────────────────────────────────────

def auth(token: str) -> dict:
    """Header de autorizare."""
    return {"Authorization": f"Bearer {token}"}


def make_user(client, email: str, password: str = "Test1234") -> str:
    """Creeaza (sau reutilizeaza) un cont si returneaza access_token."""
    r = client.post("/api/v1/auth/register", json={
        "email": email, "password": password, "full_name": f"User {email}"})
    if r.status_code == 201:
        return r.json()["access_token"]
    r = client.post("/api/v1/auth/login", json={"email": email, "password": password})
    return r.json()["access_token"]


def make_car(client, token: str, plate: str = "B-100-AAA") -> str:
    """Adauga o masina si returneaza id-ul ei."""
    r = client.post("/api/v1/cars", json={
        "brand": "Dacia", "model": "Logan", "year": 2020, "license_plate": plate},
        headers=auth(token))
    assert r.status_code == 201, r.text
    return r.json()["id"]


def promote_to_admin(email: str):
    """Ridica un cont la rol de administrator (direct in baza de date)."""
    db = SessionLocal()
    try:
        u = db.query(User).filter(User.email == email).first()
        u.role = "admin"
        u.max_cars = 999
        db.commit()
    finally:
        db.close()
