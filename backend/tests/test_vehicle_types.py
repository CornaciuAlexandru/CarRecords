"""Tipul vehiculului.

Exista ca sa se deosebeasca dintr-o privire o motocicleta de un TIR in lista.
Nu schimba nicio limita si nicio plata - dar se salveaza, deci merita sa nu se
piarda la editare si sa nu accepte orice.
"""
import pytest

from app.core import vehicles
from tests.conftest import auth, make_user


def _create(client, tok, plate, **extra):
    payload = {"brand": "X", "model": "Y", "year": 2020, "license_plate": plate}
    payload.update(extra)
    return client.post("/api/v1/cars", json=payload, headers=auth(tok))


def test_default_is_a_car(client):
    """Cine nu alege nimic primeste "masina" - cazul obisnuit."""
    tok = make_user(client, "veh_default@test.ro")
    r = _create(client, tok, "B-VEH-001")
    assert r.status_code == 201
    assert r.json()["vehicle_type"] == vehicles.DEFAULT_VEHICLE_TYPE


@pytest.mark.parametrize("kind", vehicles.VEHICLE_TYPES)
def test_every_type_is_accepted_and_returned(client, kind):
    tok = make_user(client, f"veh_{kind}@test.ro")
    r = _create(client, tok, f"B-V{kind[:2].upper()}-02", vehicle_type=kind)
    assert r.status_code == 201, r.text
    assert r.json()["vehicle_type"] == kind

    listed = client.get("/api/v1/cars", headers=auth(tok)).json()
    assert listed[0]["vehicle_type"] == kind


def test_unknown_type_is_refused(client):
    """Lista de iconite din aplicatie e fixa: o valoare din afara ei ar aparea
    fara iconita, fara sa spuna nimeni de ce."""
    tok = make_user(client, "veh_junk@test.ro")
    r = _create(client, tok, "B-VEH-003", vehicle_type="elicopter")
    assert r.status_code == 422


def test_editing_something_else_keeps_the_type(client):
    """Capcana: la editare, un camp netrimis nu trebuie sa readuca tipul la
    valoarea implicita. Un TIR nu devine masina fiindca i-ai schimbat
    kilometrajul."""
    tok = make_user(client, "veh_edit@test.ro")
    car_id = _create(client, tok, "B-VEH-004", vehicle_type=vehicles.SEMI).json()["id"]

    r = client.put(f"/api/v1/cars/{car_id}", json={"mileage": 250000},
                   headers=auth(tok))
    assert r.status_code == 200
    assert r.json()["vehicle_type"] == vehicles.SEMI


def test_the_type_can_be_changed(client):
    tok = make_user(client, "veh_change@test.ro")
    car_id = _create(client, tok, "B-VEH-005").json()["id"]

    r = client.put(f"/api/v1/cars/{car_id}",
                   json={"vehicle_type": vehicles.MOTORCYCLE}, headers=auth(tok))
    assert r.json()["vehicle_type"] == vehicles.MOTORCYCLE


def test_normalize_protects_against_broken_rows():
    assert vehicles.normalize(None) == vehicles.CAR
    assert vehicles.normalize("") == vehicles.CAR
    assert vehicles.normalize("elicopter") == vehicles.CAR
    assert vehicles.normalize("TIR") == vehicles.SEMI
