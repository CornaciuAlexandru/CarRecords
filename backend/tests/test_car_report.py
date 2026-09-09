"""Raportul PDF cu istoricul masinii.

E cel mai bun motiv de plata din aplicatie: la vanzare, un istoric documentat
schimba pretul, iar datele exista doar aici. Deci trebuie sa fie rezervat
planurilor platite si sa nu se strice pe date incomplete.
"""
import pytest

from app.core import entitlements as ent
from tests.conftest import auth, make_car, make_user, set_tier


def _report(client, tok, car_id):
    return client.get(f"/api/v1/cars/{car_id}/report.pdf", headers=auth(tok))


def test_free_accounts_are_offered_the_upgrade(client):
    tok = make_user(client, "rep_free@test.ro")
    car_id = make_car(client, tok, "B-REP-001")
    r = _report(client, tok, car_id)
    assert r.status_code == 402
    assert "PRO" in r.json()["detail"]


@pytest.mark.parametrize("tier", [ent.PRO, ent.MAXI])
def test_paid_accounts_get_a_pdf(client, tier):
    email = f"rep_{tier}@test.ro"
    tok = make_user(client, email)
    set_tier(email, tier)
    car_id = make_car(client, tok, f"B-RP{tier[:1].upper()}-02")

    r = _report(client, tok, car_id)
    assert r.status_code == 200, r.text
    assert r.headers["content-type"] == "application/pdf"
    assert r.content.startswith(b"%PDF"), "continutul nu e un PDF"
    assert "CarRecords-" in r.headers["content-disposition"]


def test_report_survives_a_car_with_no_history(client):
    """O masina abia adaugata n-are nimic in ea. Raportul trebuie sa iasa
    oricum - altfel functia cade exact la primul om care o incearca."""
    email = "rep_empty@test.ro"
    tok = make_user(client, email)
    set_tier(email, ent.PRO)
    car_id = make_car(client, tok, "B-REP-003")

    r = _report(client, tok, car_id)
    assert r.status_code == 200
    assert len(r.content) > 500


def test_report_includes_the_history(client):
    """Un PDF mai mare cu date decat fara: continutul chiar ajunge in fisier."""
    email = "rep_full@test.ro"
    tok = make_user(client, email)
    set_tier(email, ent.PRO)
    empty_car = make_car(client, tok, "B-REP-004")
    full_car = make_car(client, tok, "B-REP-005")

    for i in range(6):
        client.post(f"/api/v1/cars/{full_car}/maintenance", json={
            "type": "schimb_ulei", "performed_date": f"2026-0{i + 1}-10",
            "cost": 350.0, "mileage_at_service": 100000 + i * 1000,
            "service_shop_name": "Service Bucuresti",
        }, headers=auth(tok))

    small = _report(client, tok, empty_car).content
    big = _report(client, tok, full_car).content
    assert len(big) > len(small)


def test_report_of_someone_elses_car_is_not_found(client):
    mine = make_user(client, "rep_mine@test.ro")
    theirs = make_user(client, "rep_theirs@test.ro")
    set_tier("rep_theirs@test.ro", ent.MAXI)
    my_car = make_car(client, mine, "B-REP-006")

    assert _report(client, theirs, my_car).status_code == 404


def test_losing_the_plan_takes_the_report_with_it(client):
    email = "rep_downgrade@test.ro"
    tok = make_user(client, email)
    set_tier(email, ent.PRO)
    car_id = make_car(client, tok, "B-REP-007")
    assert _report(client, tok, car_id).status_code == 200

    set_tier(email, ent.FREE)
    assert _report(client, tok, car_id).status_code == 402
