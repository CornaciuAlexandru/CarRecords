"""Ce poate face un cont, pe fiecare plan.

Regulile astea decid cine plateste, deci merita verificate mai atent decat
restul: o limita care nu se aplica inseamna venit pierdut, iar una care se
aplica gresit inseamna un om blocat din aplicatia pentru care a platit.
"""
import io

import pytest

from app.core import entitlements as ent
from tests.conftest import auth, exhaust_car_scans, make_car, make_user, set_tier


# ── Reguli pure, fara HTTP ───────────────────────────────────────────

class _User:
    def __init__(self, tier=None, max_cars=0, scan_credits=0):
        self.subscription_tier = tier
        self.max_cars = max_cars
        self.scan_credits = scan_credits


class _Car:
    def __init__(self, used=0):
        self.ocr_scans = used


def test_each_tier_has_its_car_limit():
    assert ent.max_cars(_User(ent.FREE)) == 2
    assert ent.max_cars(_User(ent.PRO)) == 10
    assert ent.max_cars(_User(ent.MAXI)) == 25


def test_unknown_tier_falls_back_to_free():
    """Un plan stricat in baza de date trebuie sa piarda accesul platit, nu sa
    primeasca totul."""
    for junk in (None, "", "gold", "PREMIUM_PLUS", "maxi; drop table"):
        assert ent.tier_of(_User(junk)) == ent.FREE


def test_legacy_premium_becomes_pro():
    """Conturile dinainte de PRO/MAXI nu-si pierd ce au platit."""
    assert ent.tier_of(_User("premium")) == ent.PRO
    assert ent.max_cars(_User("premium")) == ent.MAX_CARS[ent.PRO]


def test_tier_is_case_insensitive():
    assert ent.tier_of(_User("MAXI")) == ent.MAXI


def test_manual_override_beats_the_plan():
    """Un administrator poate acorda mai mult intr-un caz de suport."""
    assert ent.max_cars(_User(ent.FREE, max_cars=7)) == 7


def test_scans_come_from_the_car_first_then_from_credits():
    """Creditele cumparate sunt ultimele cheltuite: altfel omul plateste pentru
    ceva ce avea deja inclus."""
    user = _User(ent.FREE, scan_credits=2)
    car = _Car()

    for _ in range(ent.SCANS_PER_CAR):
        assert ent.consume_scan(user, car)
    assert car.ocr_scans == ent.SCANS_PER_CAR
    assert user.scan_credits == 2, "creditele s-au atins prea devreme"

    assert ent.consume_scan(user, car)
    assert user.scan_credits == 1


def test_consume_returns_false_when_nothing_is_left():
    user = _User(ent.FREE, scan_credits=0)
    car = _Car(used=ent.SCANS_PER_CAR)
    assert not ent.consume_scan(user, car)
    assert not ent.can_scan(user, car)


def test_scans_are_counted_per_car_not_per_account():
    """Fiecare masina vine cu propriile scanari incluse - a doua masina nu
    porneste cu cele consumate de prima."""
    user = _User(ent.PRO)
    first, second = _Car(used=ent.SCANS_PER_CAR), _Car()
    assert not ent.can_scan(_User(ent.PRO), first)
    assert ent.scans_left_on_car(second) == ent.SCANS_PER_CAR
    assert ent.can_scan(user, second)


# ── Aceleasi reguli, prin API ────────────────────────────────────────

@pytest.mark.parametrize("tier", [ent.FREE, ent.PRO, ent.MAXI])
def test_car_limit_matches_the_plan(client, tier):
    email = f"tier_{tier}@test.ro"
    tok = make_user(client, email)
    set_tier(email, tier)
    limit = ent.MAX_CARS[tier]

    for i in range(limit):
        r = client.post("/api/v1/cars", json={
            "brand": "X", "model": "Y", "year": 2020,
            "license_plate": f"B-{tier[:2]}{i:03d}-TR"}, headers=auth(tok))
        assert r.status_code == 201, f"masina {i + 1} din {limit}: {r.text}"

    r = client.post("/api/v1/cars", json={
        "brand": "X", "model": "Y", "year": 2020,
        "license_plate": f"B-{tier[:2]}999-TR"}, headers=auth(tok))
    assert r.status_code == 402
    assert str(limit) in r.json()["detail"]


def test_upgrading_the_plan_raises_the_car_limit(client):
    """Contul urcat pe alt plan trebuie sa poata adauga imediat, fara sa astepte
    o reautentificare."""
    email = "tier_upgrade@test.ro"
    tok = make_user(client, email)
    for i in range(ent.MAX_CARS[ent.FREE]):
        client.post("/api/v1/cars", json={
            "brand": "X", "model": "Y", "year": 2020,
            "license_plate": f"B-UP{i}-GRD"}, headers=auth(tok))

    blocked = client.post("/api/v1/cars", json={
        "brand": "X", "model": "Y", "year": 2020, "license_plate": "B-UP9-GRD"},
        headers=auth(tok))
    assert blocked.status_code == 402

    set_tier(email, ent.PRO)
    allowed = client.post("/api/v1/cars", json={
        "brand": "X", "model": "Y", "year": 2020, "license_plate": "B-UP9-GRD"},
        headers=auth(tok))
    assert allowed.status_code == 201


def test_new_car_reports_its_included_scans(client):
    tok = make_user(client, "scan_fresh@test.ro")
    car_id = make_car(client, tok, "B-SCN-001")
    car = client.get(f"/api/v1/cars/{car_id}", headers=auth(tok)).json()
    assert car["ocr_scans"] == 0
    assert car["ocr_scans_left"] == ent.SCANS_PER_CAR


def _scan(client, tok, car_id, kind="registration"):
    return client.post(
        f"/api/v1/cars/{car_id}/{kind}/scan",
        files={"file": ("doc.png", io.BytesIO(b"nu conteaza"), "image/png")},
        headers=auth(tok),
    )


@pytest.mark.parametrize("kind", ["registration", "insurance", "vignettes"])
def test_scanning_is_refused_when_the_quota_is_gone(client, kind):
    """402, nu 403: aplicatia deosebeste "trebuie sa cumperi" de "n-ai voie" si
    arata oferta in loc de un mesaj de eroare."""
    tok = make_user(client, f"scan_out_{kind}@test.ro")
    car_id = make_car(client, tok, f"B-SO{kind[:1].upper()}-99")
    exhaust_car_scans(car_id)

    r = _scan(client, tok, car_id, kind)
    assert r.status_code == 402
    assert str(ent.SCANS_PER_CAR) in r.json()["detail"]


def test_bought_scans_unlock_a_car_that_ran_out(client):
    """Scanarile cumparate se pot folosi pe orice masina a contului, inclusiv pe
    una care si-a consumat deja cele incluse."""
    email = "scan_credits@test.ro"
    tok = make_user(client, email)
    car_id = make_car(client, tok, "B-CRD-001")
    exhaust_car_scans(car_id)
    assert _scan(client, tok, car_id).status_code == 402

    set_tier(email, ent.FREE, scan_credits=1)
    assert _scan(client, tok, car_id).status_code != 402


def test_a_second_car_starts_with_a_full_quota(client):
    tok = make_user(client, "scan_second@test.ro")
    first = make_car(client, tok, "B-SEC-001")
    exhaust_car_scans(first)
    second = make_car(client, tok, "B-SEC-002")

    assert _scan(client, tok, first).status_code == 402
    assert _scan(client, tok, second).status_code != 402


def test_quota_is_not_shared_between_accounts(client):
    """Scanarile epuizate ale altcuiva nu ma opresc pe mine."""
    mine = make_user(client, "scan_mine@test.ro")
    theirs = make_user(client, "scan_theirs@test.ro")
    my_car = make_car(client, mine, "B-MIN-001")
    their_car = make_car(client, theirs, "B-THR-001")
    exhaust_car_scans(their_car)

    assert _scan(client, mine, my_car).status_code != 402
