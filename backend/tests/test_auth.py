"""Teste pentru autentificare si securitatea conturilor."""
from tests.conftest import auth


def test_register_creates_account(client):
    r = client.post("/api/v1/auth/register", json={
        "email": "auth_new@gmail.com", "password": "Test1234", "full_name": "Nou"})
    assert r.status_code == 201
    assert "access_token" in r.json()
    assert "refresh_token" in r.json()


def test_new_user_defaults(client):
    """Utilizatorii noi primesc rol 'user' si limita de 3 masini."""
    r = client.post("/api/v1/auth/register", json={
        "email": "auth_defaults@gmail.com", "password": "Test1234", "full_name": "D"})
    user = r.json()["user"]
    assert user["role"] == "user"
    assert user["max_cars"] == 3


def test_weak_password_rejected(client):
    """Parola trebuie sa aiba 8+ caractere, o majuscula si o cifra."""
    for bad in ["abc", "toatemici1", "FARACIFRE", "Scurt1"]:
        r = client.post("/api/v1/auth/register", json={
            "email": f"weak_{bad}@gmail.com", "password": bad, "full_name": "W"})
        assert r.status_code == 422, f"parola '{bad}' ar fi trebuit respinsa"


def test_duplicate_email_rejected(client):
    client.post("/api/v1/auth/register", json={
        "email": "auth_dup@gmail.com", "password": "Test1234", "full_name": "A"})
    r = client.post("/api/v1/auth/register", json={
        "email": "auth_dup@gmail.com", "password": "Test1234", "full_name": "B"})
    assert r.status_code == 400


def test_login_wrong_password_rejected(client):
    client.post("/api/v1/auth/register", json={
        "email": "auth_login@gmail.com", "password": "Test1234", "full_name": "L"})
    r = client.post("/api/v1/auth/login", json={
        "email": "auth_login@gmail.com", "password": "Gresita99"})
    assert r.status_code == 401


def test_protected_route_requires_token(client):
    assert client.get("/api/v1/cars").status_code in (401, 403)
    assert client.get("/api/v1/cars", headers=auth("token-inventat")).status_code == 401


def test_refresh_token_returns_new_tokens(client):
    r = client.post("/api/v1/auth/register", json={
        "email": "auth_refresh@gmail.com", "password": "Test1234", "full_name": "R"})
    refresh = r.json()["refresh_token"]
    r2 = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh})
    assert r2.status_code == 200
    assert "access_token" in r2.json()


def test_access_token_not_valid_as_refresh(client):
    """Un access token nu trebuie acceptat pe ruta de refresh."""
    r = client.post("/api/v1/auth/register", json={
        "email": "auth_swap@gmail.com", "password": "Test1234", "full_name": "S"})
    access = r.json()["access_token"]
    assert client.post("/api/v1/auth/refresh",
                       json={"refresh_token": access}).status_code == 401


def test_change_password(client):
    client.post("/api/v1/auth/register", json={
        "email": "auth_pwd@gmail.com", "password": "Test1234", "full_name": "P"})
    tok = client.post("/api/v1/auth/login", json={
        "email": "auth_pwd@gmail.com", "password": "Test1234"}).json()["access_token"]

    # Parola curenta gresita → respins
    assert client.put("/api/v1/auth/me/password", json={
        "current_password": "Gresita9", "new_password": "NouaParola1"},
        headers=auth(tok)).status_code == 400

    # Schimbare corecta, apoi login cu parola noua
    assert client.put("/api/v1/auth/me/password", json={
        "current_password": "Test1234", "new_password": "NouaParola1"},
        headers=auth(tok)).status_code == 204
    assert client.post("/api/v1/auth/login", json={
        "email": "auth_pwd@gmail.com", "password": "NouaParola1"}).status_code == 200
