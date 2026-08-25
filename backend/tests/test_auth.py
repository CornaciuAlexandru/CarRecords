"""Teste pentru autentificare si securitatea conturilor."""
from app.core.config import settings
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

    # Schimbare corecta: raspunde cu tokenuri noi, apoi login cu parola noua
    r = client.put("/api/v1/auth/me/password", json={
        "current_password": "Test1234", "new_password": "NouaParola1"},
        headers=auth(tok))
    assert r.status_code == 200
    assert client.get("/api/v1/auth/me",
                      headers=auth(r.json()["access_token"])).status_code == 200
    assert client.post("/api/v1/auth/login", json={
        "email": "auth_pwd@gmail.com", "password": "NouaParola1"}).status_code == 200


def test_weak_new_password_rejected(client):
    """Parola noua trece prin aceleasi reguli ca la inregistrare."""
    client.post("/api/v1/auth/register", json={
        "email": "auth_weak_change@gmail.com", "password": "Test1234", "full_name": "W"})
    tok = client.post("/api/v1/auth/login", json={
        "email": "auth_weak_change@gmail.com", "password": "Test1234"}).json()["access_token"]
    assert client.put("/api/v1/auth/me/password", json={
        "current_password": "Test1234", "new_password": "scurt"},
        headers=auth(tok)).status_code == 422


def test_password_change_ends_old_sessions(client):
    """Tokenurile emise inainte de schimbarea parolei nu mai sunt acceptate."""
    r = client.post("/api/v1/auth/register", json={
        "email": "auth_sessions@gmail.com", "password": "Test1234", "full_name": "S"})
    old_access = r.json()["access_token"]
    old_refresh = r.json()["refresh_token"]

    client.put("/api/v1/auth/me/password", json={
        "current_password": "Test1234", "new_password": "AltaParola1"},
        headers=auth(old_access))

    assert client.get("/api/v1/auth/me", headers=auth(old_access)).status_code == 401
    assert client.post("/api/v1/auth/refresh",
                       json={"refresh_token": old_refresh}).status_code == 401



# ── Incercari repetate de autentificare ──────────────────────────────

def _make(client, email, password="Test1234"):
    client.post("/api/v1/auth/register", json={
        "email": email, "password": password, "full_name": "Rate"})


def _wrong_login(client, email):
    return client.post("/api/v1/auth/login",
                       json={"email": email, "password": "Gresita999"})


def test_login_blocked_after_repeated_failures(client):
    """Dupa N parole gresite, contul nu mai raspunde nici la parola corecta."""
    _make(client, "rate_lock@gmail.com")

    for _ in range(settings.LOGIN_MAX_FAILURES):
        assert _wrong_login(client, "rate_lock@gmail.com").status_code == 401

    blocked = client.post("/api/v1/auth/login", json={
        "email": "rate_lock@gmail.com", "password": "Test1234"})
    assert blocked.status_code == 429
    assert int(blocked.headers["Retry-After"]) > 0


def test_successful_login_clears_the_failure_counter(client):
    """Greselile de tastare nu trebuie sa se adune peste o autentificare
    reusita."""
    _make(client, "rate_clear@gmail.com")

    for _ in range(settings.LOGIN_MAX_FAILURES - 1):
        assert _wrong_login(client, "rate_clear@gmail.com").status_code == 401
    assert client.post("/api/v1/auth/login", json={
        "email": "rate_clear@gmail.com", "password": "Test1234"}).status_code == 200

    # Contorul a repornit de la zero: mai avem dreptul la tot atatea greseli
    for _ in range(settings.LOGIN_MAX_FAILURES - 1):
        assert _wrong_login(client, "rate_clear@gmail.com").status_code == 401
    assert client.post("/api/v1/auth/login", json={
        "email": "rate_clear@gmail.com", "password": "Test1234"}).status_code == 200


def test_lockout_is_per_account(client):
    """Blocarea unui cont nu inchide usa si celorlalte de pe aceeasi retea."""
    _make(client, "rate_victim@gmail.com")
    _make(client, "rate_neighbour@gmail.com")

    for _ in range(settings.LOGIN_MAX_FAILURES):
        _wrong_login(client, "rate_victim@gmail.com")

    assert client.post("/api/v1/auth/login", json={
        "email": "rate_victim@gmail.com", "password": "Test1234"}).status_code == 429
    assert client.post("/api/v1/auth/login", json={
        "email": "rate_neighbour@gmail.com", "password": "Test1234"}).status_code == 200


def test_login_attempts_capped_per_ip(client):
    """Peste plafonul pe IP nu mai trece nimic, nici pe conturi diferite."""
    _make(client, "rate_ip@gmail.com")

    for i in range(settings.LOGIN_MAX_ATTEMPTS_PER_IP):
        # Adrese diferite, ca sa nu intervina contorul de esecuri pe cont
        client.post("/api/v1/auth/login",
                    json={"email": f"rate_ip_{i}@gmail.com", "password": "Gresita999"})

    assert client.post("/api/v1/auth/login", json={
        "email": "rate_ip@gmail.com", "password": "Test1234"}).status_code == 429


def test_case_variants_share_the_same_counter(client):
    """Scrisul cu majuscule nu trebuie sa dea un contor nou."""
    _make(client, "rate_case@gmail.com")

    for _ in range(settings.LOGIN_MAX_FAILURES):
        _wrong_login(client, "rate_case@gmail.com")

    assert client.post("/api/v1/auth/login", json={
        "email": "Rate_Case@Gmail.com", "password": "Test1234"}).status_code == 429



# ── Creari repetate de cont ──────────────────────────────────────────

def _register(client, email, password="Test1234"):
    return client.post("/api/v1/auth/register", json={
        "email": email, "password": password, "full_name": "Reg"})


def test_account_creation_capped_per_ip(client):
    """Peste plafon nu se mai pot fabrica conturi de la aceeasi adresa."""
    for i in range(settings.REGISTER_MAX_ACCOUNTS_PER_IP):
        assert _register(client, f"reg_cap_{i}@gmail.com").status_code == 201

    assert _register(client, "reg_cap_last@gmail.com").status_code == 429


def test_rejected_registrations_do_not_use_up_the_quota(client):
    """Cine da peste o adresa deja folosita trebuie sa poata incerca cu alta."""
    assert _register(client, "reg_quota@gmail.com").status_code == 201
    for _ in range(4):
        assert _register(client, "reg_quota@gmail.com").status_code == 400

    # Au ramas locuri: mai putem crea pana la plafon
    for i in range(settings.REGISTER_MAX_ACCOUNTS_PER_IP - 1):
        assert _register(client, f"reg_quota_{i}@gmail.com").status_code == 201


def test_registration_attempts_capped_per_ip(client):
    """Nici cererile respinse nu pot curge la nesfarsit: raspunsul
    "Email deja inregistrat" ar spune altfel cine are cont."""
    assert _register(client, "reg_probe@gmail.com").status_code == 201
    for _ in range(settings.REGISTER_MAX_ATTEMPTS_PER_IP - 1):
        assert _register(client, "reg_probe@gmail.com").status_code == 400

    assert _register(client, "reg_probe@gmail.com").status_code == 429



# ── Majuscule in adresa de email ─────────────────────────────────────

def test_login_ignores_email_case(client):
    """Adresa scrisa altfel decat la inregistrare duce la acelasi cont."""
    client.post("/api/v1/auth/register", json={
        "email": "Case.Test@Gmail.COM", "password": "Test1234", "full_name": "C"})

    for variant in ["case.test@gmail.com", "CASE.TEST@GMAIL.COM", "Case.Test@Gmail.com"]:
        r = client.post("/api/v1/auth/login",
                        json={"email": variant, "password": "Test1234"})
        assert r.status_code == 200, f"varianta {variant} ar fi trebuit sa mearga"


def test_email_stored_in_lowercase(client):
    """Adresa se salveaza normalizata, nu asa cum a fost tastata."""
    r = client.post("/api/v1/auth/register", json={
        "email": "  MixedCase@Gmail.com  ", "password": "Test1234", "full_name": "M"})
    assert r.json()["user"]["email"] == "mixedcase@gmail.com"


def test_case_variant_is_not_a_new_account(client):
    """Nu se pot face doua conturi din aceeasi adresa scrisa diferit."""
    assert client.post("/api/v1/auth/register", json={
        "email": "dublu@gmail.com", "password": "Test1234",
        "full_name": "A"}).status_code == 201
    assert client.post("/api/v1/auth/register", json={
        "email": "DUBLU@Gmail.com", "password": "Test1234",
        "full_name": "B"}).status_code == 400


def test_password_reset_ignores_email_case(client):
    from app.core.email import outbox

    client.post("/api/v1/auth/register", json={
        "email": "reset.case@gmail.com", "password": "Test1234", "full_name": "R"})
    outbox.clear()
    assert client.post("/api/v1/auth/forgot-password",
                       json={"email": "Reset.Case@GMAIL.com"}).status_code == 204
    assert outbox and outbox[-1]["to"] == "reset.case@gmail.com"


def test_existing_mixed_case_accounts_are_migrated(client):
    """Conturile salvate inainte de normalizare devin accesibile."""
    from app.core.database import SessionLocal
    from app.main import _migrate_lowercase_emails
    from app.models.user import User

    client.post("/api/v1/auth/register", json={
        "email": "vechi@gmail.com", "password": "Test1234", "full_name": "V"})

    # Simulam un cont creat de versiunea veche, cu adresa asa cum a fost tastata
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == "vechi@gmail.com").first()
        user.email = "Vechi@Gmail.com"
        db.commit()
    finally:
        db.close()

    assert client.post("/api/v1/auth/login", json={
        "email": "vechi@gmail.com", "password": "Test1234"}).status_code == 401

    _migrate_lowercase_emails()

    assert client.post("/api/v1/auth/login", json={
        "email": "vechi@gmail.com", "password": "Test1234"}).status_code == 200
