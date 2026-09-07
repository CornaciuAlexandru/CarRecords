"""Alarmele programate pe telefon.

Datele de expirare se stiu dinainte, deci telefonul isi pune singur alarmele
in loc sa astepte un push de la server. Serverul spune doar CAND si CE, iar
testele astea verifica exact acele doua lucruri: momentul calculat corect si
faptul ca ce a trecut deja nu se mai programeaza.
"""
from datetime import date, timedelta

from tests.conftest import auth, make_user, make_car


def _schedule(client, token):
    r = client.get("/api/v1/notifications/schedule", headers=auth(token))
    assert r.status_code == 200, r.text
    return r.json()


def _fire_dates(items, kind):
    return sorted(i["fire_on"] for i in items if i["type"] == kind)


def test_schedule_fires_at_each_threshold_before_expiry(client):
    token = make_user(client, "plan1@test.ro")
    car = make_car(client, token, "B-900-PL1")
    expires = date.today() + timedelta(days=200)

    r = client.post(f"/api/v1/cars/{car}/vignettes", json={
        "purchase_date": date.today().isoformat(),
        "valid_from": date.today().isoformat(),
        "valid_until": expires.isoformat(),
        "validity_period": "1_an", "price": 28.5,
    }, headers=auth(token))
    assert r.status_code == 201, r.text

    dates = _fire_dates(_schedule(client, token), "rovinieta_expira")
    assert dates == sorted(
        (expires - timedelta(days=t)).isoformat() for t in (30, 7, 1)
    )


def test_thresholds_already_passed_are_not_scheduled(client):
    """O rovinieta care expira peste 5 zile nu mai poate suna "cu 30 de zile
    inainte" - acel moment a trecut. Programarea lui ar insemna o alarma in
    trecut, pe care Android o declanseaza imediat."""
    token = make_user(client, "plan2@test.ro")
    car = make_car(client, token, "B-900-PL2")
    expires = date.today() + timedelta(days=5)

    client.post(f"/api/v1/cars/{car}/vignettes", json={
        "purchase_date": date.today().isoformat(),
        "valid_from": date.today().isoformat(),
        "valid_until": expires.isoformat(),
        "validity_period": "1_an", "price": 28.5,
    }, headers=auth(token))

    items = _schedule(client, token)
    assert _fire_dates(items, "rovinieta_expira") == [
        (expires - timedelta(days=1)).isoformat()
    ]
    assert all(i["fire_on"] >= date.today().isoformat() for i in items)


def test_itp_and_insurance_use_their_own_thresholds(client):
    token = make_user(client, "plan3@test.ro")
    car = make_car(client, token, "B-900-PL3")
    expires = date.today() + timedelta(days=300)

    client.post(f"/api/v1/cars/{car}/registration", json={
        "registration_number": "B900PL3",
        "registration_date": date.today().isoformat(),
        "itp_expiry_date": expires.isoformat(),
        "owner_name": "ION POPESCU", "owner_address": "Str. Test 1",
        "car_series": "VF1BT1RG648222399", "brand": "DACIA",
        "model": "LOGAN", "manufacturing_year": "2020",
    }, headers=auth(token))
    client.post(f"/api/v1/cars/{car}/insurance", json={
        "type": "RCA", "policy_number": "RO900PL3",
        "insurer_company": "Allianz",
        "purchase_date": date.today().isoformat(),
        "valid_from": date.today().isoformat(),
        "valid_until": expires.isoformat(), "premium_amount": 650.0,
    }, headers=auth(token))

    items = _schedule(client, token)
    assert _fire_dates(items, "itp_expira") == sorted(
        (expires - timedelta(days=t)).isoformat() for t in (60, 30, 7))
    assert _fire_dates(items, "asigurare_expira") == sorted(
        (expires - timedelta(days=t)).isoformat() for t in (45, 14, 3))


def test_keys_are_unique_and_carry_the_expiry_date(client):
    """Cheia identifica alarma intre sincronizari. Daca utilizatorul schimba
    data de expirare, cheia trebuie sa se schimbe si ea - altfel o alarma
    veche ar ramane agatata de o data care nu mai exista."""
    token = make_user(client, "plan4@test.ro")
    car = make_car(client, token, "B-900-PL4")
    expires = date.today() + timedelta(days=200)

    client.post(f"/api/v1/cars/{car}/vignettes", json={
        "purchase_date": date.today().isoformat(),
        "valid_from": date.today().isoformat(),
        "valid_until": expires.isoformat(),
        "validity_period": "1_an", "price": 28.5,
    }, headers=auth(token))

    items = _schedule(client, token)
    keys = [i["key"] for i in items]
    assert len(keys) == len(set(keys))
    assert all(expires.isoformat() in k for k in keys)


def test_schedule_is_per_user(client):
    """Alarmele altcuiva nu au ce cauta pe telefonul meu."""
    mine = make_user(client, "plan5@test.ro")
    theirs = make_user(client, "plan6@test.ro")
    car = make_car(client, mine, "B-900-PL5")
    client.post(f"/api/v1/cars/{car}/vignettes", json={
        "purchase_date": date.today().isoformat(),
        "valid_from": date.today().isoformat(),
        "valid_until": (date.today() + timedelta(days=200)).isoformat(),
        "validity_period": "1_an", "price": 28.5,
    }, headers=auth(mine))

    assert _schedule(client, mine)
    assert _schedule(client, theirs) == []


def test_schedule_requires_authentication(client):
    r = client.get("/api/v1/notifications/schedule")
    assert r.status_code in (401, 403)
