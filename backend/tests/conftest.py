"""Configurare comuna pentru teste — baza de date temporara, izolata."""
import os
import tempfile
from pathlib import Path

import pytest

# Baza de date de test. Implicit un fisier SQLite temporar, sters dupa rulare.
# Daca se furnizeaza TEST_DATABASE_URL, testele ruleaza pe acea baza — util
# pentru a verifica aceleasi teste pe PostgreSQL, ca in productie:
#   TEST_DATABASE_URL=postgresql+psycopg2://user:parola@host:5432/db pytest
# Trebuie setat INAINTE de importul aplicatiei.
_EXTERNAL_DB = os.environ.get("TEST_DATABASE_URL")
_TMP_DB = Path(tempfile.gettempdir()) / "carrecords_test.db"
os.environ["DATABASE_URL"] = _EXTERNAL_DB or f"sqlite:///{_TMP_DB.as_posix()}"

from fastapi.testclient import TestClient  # noqa: E402
from app.main import app                    # noqa: E402
from app.core.database import SessionLocal, engine, Base  # noqa: E402
from app.core import rate_limit             # noqa: E402
from app.models.user import User            # noqa: E402


@pytest.fixture(scope="session", autouse=True)
def _clean_db():
    """Porneste de la o baza de date goala si curata dupa rulare."""
    if _EXTERNAL_DB:
        # Baza externa (ex. PostgreSQL): golim schema, nu stergem fisiere
        Base.metadata.drop_all(bind=engine)
        yield
        Base.metadata.drop_all(bind=engine)
        engine.dispose()
    else:
        if _TMP_DB.exists():
            _TMP_DB.unlink()
        yield
        engine.dispose()
        if _TMP_DB.exists():
            try:
                _TMP_DB.unlink()
            except PermissionError:
                pass


@pytest.fixture(autouse=True)
def _reset_rate_limits():
    """Contoarele de limitare traiesc in memoria procesului si s-ar aduna de
    la un test la altul, blocand teste care nu au nicio legatura intre ele."""
    rate_limit.clear()
    yield


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
    """Creeaza (sau reutilizeaza) un cont si returneaza access_token.

    Goleste intai contoarele de limitare. Helperul e chemat si din fixture-uri
    cu scope de modul, care se initializeaza inaintea fixture-ului
    `_reset_rate_limits` (function scope) — altfel un test care tocmai a
    atins plafonul ar bloca setup-ul urmatorului fisier de teste.
    """
    rate_limit.clear()
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
