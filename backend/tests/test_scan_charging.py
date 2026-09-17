"""Cand se plateste o scanare.

Regula: se taxeaza doar o scanare din care a iesit ceva util si care a ajuns
la utilizator. Un dictionar plin de None nu e o scanare, e o poza din care nu
s-a putut citi; o cerere care a depasit termenul n-a livrat nimic.

Utilizatorul a vazut exact contrariul: "scan failed" si cota scazuta. De doua
ori. Testele astea nu lasa sa se repete.
"""
import asyncio

import pytest

from app.api.v1.endpoints import registration
from app.core import entitlements as ent
from tests.conftest import auth, make_car, make_user

EMPTY = {"owner_name": None, "owner_address": None, "itp_expiry_date": None,
         "registration_date": None, "registration_number": None,
         "car_series": None, "brand": None, "model": None,
         "manufacturing_year": None, "ocr_raw_text": "gunoi ilizibil"}

USEFUL = dict(EMPTY, brand="DACIA", registration_number="B123ABC")


def _scan(client, tok, car_id):
    return client.post(
        f"/api/v1/cars/{car_id}/registration/scan",
        files={"file": ("doc.png", b"nu conteaza", "image/png")},
        headers=auth(tok),
    )


def _scans_left(client, tok, car_id):
    return client.get(f"/api/v1/cars/{car_id}", headers=auth(tok)).json()["ocr_scans_left"]


def _fake_extractor(result=None, exc=None):
    async def fake(_path):
        if exc:
            raise exc
        return dict(result)
    return fake


def test_a_useful_scan_is_charged(client, monkeypatch):
    monkeypatch.setattr(registration, "extract_registration_data", _fake_extractor(USEFUL))
    tok = make_user(client, "charge_useful@test.ro")
    car_id = make_car(client, tok, "B-CHG-001")

    r = _scan(client, tok, car_id)
    assert r.status_code == 200
    assert r.json()["scans_left"] == ent.SCANS_PER_CAR - 1
    assert _scans_left(client, tok, car_id) == ent.SCANS_PER_CAR - 1


def test_a_scan_that_read_nothing_is_free(client, monkeypatch):
    """Toate cheile prezente, toate None: inainte, `if extracted:` era adevarat
    si se taxa. Esecul de citire e al nostru, nu al utilizatorului."""
    monkeypatch.setattr(registration, "extract_registration_data", _fake_extractor(EMPTY))
    tok = make_user(client, "charge_empty@test.ro")
    car_id = make_car(client, tok, "B-CHG-002")

    r = _scan(client, tok, car_id)
    assert r.status_code == 200
    assert r.json()["scans_left"] == ent.SCANS_PER_CAR
    assert _scans_left(client, tok, car_id) == ent.SCANS_PER_CAR


def test_a_scan_that_timed_out_is_504_and_free(client, monkeypatch):
    """Termenul depasit inseamna ca omul n-a primit nimic. 504, nu 500: aplicatia
    il arata ca "incearca din nou", nu ca eroare interna. Si nu se taxeaza."""
    monkeypatch.setattr(registration, "extract_registration_data",
                        _fake_extractor(exc=asyncio.TimeoutError()))
    tok = make_user(client, "charge_timeout@test.ro")
    car_id = make_car(client, tok, "B-CHG-003")

    r = _scan(client, tok, car_id)
    assert r.status_code == 504
    assert "prea mult" in r.json()["detail"]
    assert _scans_left(client, tok, car_id) == ent.SCANS_PER_CAR


def test_only_the_raw_text_does_not_count_as_a_result():
    from app.core.deps import scan_found_something
    assert not scan_found_something({"ocr_raw_text": "ceva", "brand": None})
    assert not scan_found_something({"ocr_raw_text": "", "brand": ""})
    assert scan_found_something({"ocr_raw_text": "", "brand": "DACIA"})
    assert scan_found_something({"valid_until": "2027-01-01"})
