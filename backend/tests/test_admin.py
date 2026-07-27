"""Teste pentru panoul de administrare si notificari."""
import pytest
from tests.conftest import auth, make_user, make_car, promote_to_admin


@pytest.fixture(scope="module")
def admin_token(client):
    make_user(client, "adm_root@gmail.com")
    promote_to_admin("adm_root@gmail.com")
    return client.post("/api/v1/auth/login", json={
        "email": "adm_root@gmail.com", "password": "Test1234"}).json()["access_token"]


@pytest.fixture(scope="module")
def normal_token(client):
    return make_user(client, "adm_normal@gmail.com")


@pytest.mark.parametrize("path", ["/stats", "/users"])
def test_admin_routes_blocked_for_normal_user(client, normal_token, path):
    r = client.get(f"/api/v1/admin{path}", headers=auth(normal_token))
    assert r.status_code == 403


def test_admin_stats(client, admin_token):
    r = client.get("/api/v1/admin/stats", headers=auth(admin_token))
    assert r.status_code == 200
    for key in ("total_users", "total_cars", "total_vignettes"):
        assert key in r.json()


def test_admin_user_list_has_counts(client, admin_token):
    """Lista de utilizatori include numarul de masini si de documente."""
    r = client.get("/api/v1/admin/users", headers=auth(admin_token))
    assert r.status_code == 200
    assert r.json(), "lista de utilizatori nu ar trebui sa fie goala"
    user = r.json()[0]
    for key in ("car_count", "records_count", "created_at", "role"):
        assert key in user


def test_admin_can_update_user(client, admin_token):
    tok = make_user(client, "adm_target@gmail.com")
    users = client.get("/api/v1/admin/users", headers=auth(admin_token)).json()
    uid = next(u["id"] for u in users if u["email"] == "adm_target@gmail.com")

    r = client.put(f"/api/v1/admin/users/{uid}",
                   json={"max_cars": 5, "is_active": True},
                   headers=auth(admin_token))
    assert r.status_code == 200
    assert r.json()["max_cars"] == 5

    # Limita noua se aplica efectiv
    assert client.get("/api/v1/auth/me", headers=auth(tok)).json()["max_cars"] == 5


def test_admin_cannot_delete_self(client, admin_token):
    users = client.get("/api/v1/admin/users", headers=auth(admin_token)).json()
    uid = next(u["id"] for u in users if u["email"] == "adm_root@gmail.com")
    assert client.delete(f"/api/v1/admin/users/{uid}",
                         headers=auth(admin_token)).status_code == 400


def test_admin_can_delete_user(client, admin_token):
    make_user(client, "adm_doomed@gmail.com")
    users = client.get("/api/v1/admin/users", headers=auth(admin_token)).json()
    uid = next(u["id"] for u in users if u["email"] == "adm_doomed@gmail.com")
    assert client.delete(f"/api/v1/admin/users/{uid}",
                         headers=auth(admin_token)).status_code == 204


def test_deactivated_user_cannot_login(client, admin_token):
    make_user(client, "adm_blocked@gmail.com")
    users = client.get("/api/v1/admin/users", headers=auth(admin_token)).json()
    uid = next(u["id"] for u in users if u["email"] == "adm_blocked@gmail.com")
    client.put(f"/api/v1/admin/users/{uid}", json={"is_active": False},
               headers=auth(admin_token))
    r = client.post("/api/v1/auth/login", json={
        "email": "adm_blocked@gmail.com", "password": "Test1234"})
    assert r.status_code == 403


# ── Notificari ─────────────────────────────────────────────────────

def test_notifications_generated_for_expiring_itp(client):
    """Un ITP care expira curand trebuie sa produca o notificare."""
    from datetime import date, timedelta
    tok = make_user(client, "notif_user@gmail.com")
    car_id = make_car(client, tok, plate="B-800-NOT")
    soon = (date.today() + timedelta(days=20)).isoformat()
    client.post(f"/api/v1/cars/{car_id}/registration",
                json={"itp_expiry_date": soon, "is_active": True},
                headers=auth(tok))

    created = client.post("/api/v1/notifications/check", headers=auth(tok))
    assert created.status_code == 200

    notifs = client.get("/api/v1/notifications", headers=auth(tok)).json()
    assert any(n["type"] == "itp_expira" for n in notifs), \
        "ar fi trebuit generata o notificare de expirare ITP"


def test_notifications_are_per_user(client):
    """Notificarile unui utilizator nu apar la altul."""
    tok_other = make_user(client, "notif_other@gmail.com")
    assert client.get("/api/v1/notifications", headers=auth(tok_other)).json() == []


def test_mark_all_notifications_read(client):
    tok = client.post("/api/v1/auth/login", json={
        "email": "notif_user@gmail.com", "password": "Test1234"}).json()["access_token"]
    assert client.put("/api/v1/notifications/read-all",
                      headers=auth(tok)).status_code == 204
    notifs = client.get("/api/v1/notifications", headers=auth(tok)).json()
    assert all(n["is_read"] for n in notifs)


# ── Sanatate / versionare ──────────────────────────────────────────

def test_health_endpoint(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_version_endpoint_publishes_hash(client):
    """Update-urile trebuie sa aiba hash SHA-256 pentru verificare."""
    r = client.get("/version?client_version=1.0.0")
    assert r.status_code == 200
    data = r.json()
    assert data["update_available"] is True
    assert data.get("sha256"), "version.json trebuie sa contina sha256"
