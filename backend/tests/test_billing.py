"""Cumpararile.

Regula pe care o apara testele astea: singura cale prin care un cont urca pe alt
plan e o chitanta verificata la magazin. Aplicatia nu poate cere "fa-ma PRO".
"""
import pytest

from app.core import billing, entitlements as ent
from tests.conftest import auth, exhaust_car_scans, make_car, make_user


def _buy(client, tok, product_id, token="test-ok-1"):
    return client.post("/api/v1/billing/verify",
                       json={"product_id": product_id, "purchase_token": token},
                       headers=auth(tok))


def test_catalog_is_public_and_complete(client):
    """Ecranul de planuri trebuie sa se poata afisa si inainte de autentificare."""
    r = client.get("/api/v1/billing/catalog")
    assert r.status_code == 200
    ids = {p["product_id"] for p in r.json()}
    assert ids == set(billing.CATALOG)


def test_catalog_reports_what_each_plan_gives(client):
    by_id = {p["product_id"]: p for p in client.get("/api/v1/billing/catalog").json()}
    assert by_id["pro_yearly"]["max_cars"] == ent.MAX_CARS[ent.PRO]
    assert by_id["maxi_yearly"]["max_cars"] == ent.MAX_CARS[ent.MAXI]
    assert by_id["scans_10"]["scans"] == 10


def test_verify_requires_authentication(client):
    r = client.post("/api/v1/billing/verify",
                    json={"product_id": "pro_yearly", "purchase_token": "test-x"})
    assert r.status_code in (401, 403)


def test_unknown_product_is_refused(client):
    tok = make_user(client, "buy_unknown@test.ro")
    r = _buy(client, tok, "maxi_forever_free")
    assert r.status_code == 400


def test_invalid_receipt_grants_nothing(client):
    """Chitanta trebuie sa treaca prin verificare. Un sir inventat nu urca contul."""
    tok = make_user(client, "buy_invalid@test.ro")
    r = _buy(client, tok, "pro_yearly", token="chitanta-inventata")
    assert r.status_code == 400

    me = client.get("/api/v1/auth/me", headers=auth(tok)).json()
    assert me["subscription_tier"] == ent.FREE


@pytest.mark.parametrize("product_id,tier", [
    ("pro_yearly", ent.PRO),
    ("maxi_yearly", ent.MAXI),
])
def test_subscription_moves_the_account_and_its_car_limit(client, product_id, tier):
    tok = make_user(client, f"buy_{product_id}@test.ro")
    r = _buy(client, tok, product_id, token=f"test-{product_id}")
    assert r.status_code == 200, r.text

    user = r.json()
    assert user["subscription_tier"] == tier
    assert user["max_cars"] == ent.MAX_CARS[tier]


def test_scan_pack_adds_credits_and_they_accumulate(client):
    tok = make_user(client, "buy_scans@test.ro")
    first = _buy(client, tok, "scans_10", token="test-scans-a")
    assert first.status_code == 200
    assert first.json()["scan_credits"] == 10

    second = _buy(client, tok, "scans_1", token="test-scans-b")
    assert second.json()["scan_credits"] == 11


def test_bought_scans_are_usable_on_an_exhausted_car(client):
    """Capatul celalalt al lantului: creditele platite chiar deblocheaza o
    scanare, nu raman doar un numar in profil."""
    tok = make_user(client, "buy_then_scan@test.ro")
    car_id = make_car(client, tok, "B-BUY-001")
    exhaust_car_scans(car_id)

    blocked = client.post(f"/api/v1/cars/{car_id}/registration/scan",
                          files={"file": ("d.png", b"x", "image/png")}, headers=auth(tok))
    assert blocked.status_code == 402

    _buy(client, tok, "scans_1", token="test-unlock-1")
    after = client.post(f"/api/v1/cars/{car_id}/registration/scan",
                        files={"file": ("d.png", b"x", "image/png")}, headers=auth(tok))
    assert after.status_code != 402


def test_the_same_receipt_cannot_be_used_twice(client):
    """Altfel o singura cumparare de 6 euro ar da credite la nesfarsit."""
    tok = make_user(client, "buy_twice@test.ro")
    assert _buy(client, tok, "scans_10", token="test-reuse").status_code == 200
    again = _buy(client, tok, "scans_10", token="test-reuse")
    assert again.status_code == 409

    me = client.get("/api/v1/auth/me", headers=auth(tok)).json()
    assert me["scan_credits"] == 10, "creditele s-au acordat de doua ori"


def test_a_receipt_cannot_be_moved_to_another_account(client):
    """Un abonament cumparat o data nu poate urca doua conturi."""
    mine = make_user(client, "buy_owner@test.ro")
    theirs = make_user(client, "buy_thief@test.ro")
    assert _buy(client, mine, "pro_yearly", token="test-shared").status_code == 200

    stolen = _buy(client, theirs, "pro_yearly", token="test-shared")
    assert stolen.status_code == 409

    me = client.get("/api/v1/auth/me", headers=auth(theirs)).json()
    assert me["subscription_tier"] == ent.FREE
