"""Teste pentru izolarea datelor intre utilizatori si limita de masini.

Acestea acopera bug-ul major din iunie 2026, cand orice utilizator vedea
datele tuturor celorlalti.
"""
import pytest
from tests.conftest import auth, make_user, make_car


@pytest.fixture(scope="module")
def two_users(client):
    """Doi utilizatori distincti; A are o masina cu documente."""
    tok_a = make_user(client, "iso_a@gmail.com")
    tok_b = make_user(client, "iso_b@gmail.com")
    car_a = make_car(client, tok_a, plate="B-501-AAA")
    client.post(f"/api/v1/cars/{car_a}/registration",
                json={"registration_number": "B501AAA", "owner_name": "A"},
                headers=auth(tok_a))
    return tok_a, tok_b, car_a


def test_user_sees_only_own_cars(client, two_users):
    tok_a, tok_b, _ = two_users
    assert len(client.get("/api/v1/cars", headers=auth(tok_a)).json()) >= 1
    assert client.get("/api/v1/cars", headers=auth(tok_b)).json() == []


def test_user_cannot_read_others_car(client, two_users):
    _, tok_b, car_a = two_users
    assert client.get(f"/api/v1/cars/{car_a}", headers=auth(tok_b)).status_code == 404


def test_user_cannot_modify_others_car(client, two_users):
    _, tok_b, car_a = two_users
    assert client.put(f"/api/v1/cars/{car_a}", json={"model": "Furat"},
                      headers=auth(tok_b)).status_code == 404


def test_user_cannot_delete_others_car(client, two_users):
    _, tok_b, car_a = two_users
    assert client.delete(f"/api/v1/cars/{car_a}", headers=auth(tok_b)).status_code == 404


@pytest.mark.parametrize("resource", [
    "registration", "vignettes", "insurance", "maintenance", "modifications",
])
def test_user_cannot_access_others_documents(client, two_users, resource):
    """Niciun tip de document al altui utilizator nu e accesibil."""
    _, tok_b, car_a = two_users
    r = client.get(f"/api/v1/cars/{car_a}/{resource}", headers=auth(tok_b))
    assert r.status_code == 404


def test_user_cannot_add_documents_to_others_car(client, two_users):
    _, tok_b, car_a = two_users
    r = client.post(f"/api/v1/cars/{car_a}/registration",
                    json={"owner_name": "Intrus"}, headers=auth(tok_b))
    assert r.status_code == 404


def test_car_limit_enforced(client):
    """Un utilizator normal poate adauga maximum 3 masini."""
    tok = make_user(client, "iso_limit@gmail.com")
    for i in range(3):
        r = client.post("/api/v1/cars", json={
            "brand": "X", "model": "Y", "year": 2020,
            "license_plate": f"B-60{i}-LIM"}, headers=auth(tok))
        assert r.status_code == 201, f"masina {i+1} ar fi trebuit acceptata"

    r = client.post("/api/v1/cars", json={
        "brand": "X", "model": "Y", "year": 2020, "license_plate": "B-604-LIM"},
        headers=auth(tok))
    assert r.status_code == 400
    assert "3" in r.json()["detail"]
