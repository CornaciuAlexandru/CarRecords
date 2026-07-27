"""Teste CRUD pentru toate tipurile de documente.

Testul de creare a talonului acopera bug-ul din iulie 2026 (eroare 500
pentru ca schema avea campul 'notes', iar modelul nu avea coloana).
"""
import pytest
from tests.conftest import auth, make_user, make_car

# (nume, sufix ruta, payload de creare, camp modificat la editare)
DOCUMENTS = [
    ("talon", "registration", {
        "registration_number": "B100AAA",
        "registration_date": "2024-10-10",
        "itp_expiry_date": "2027-10-07",
        "owner_name": "ION POPESCU",
        "owner_address": "Str. Test Nr. 1",
        "car_series": "VF1BT1RG648222399",
        "brand": "DACIA", "model": "LOGAN",
        "manufacturing_year": "2020",
        "notes": "verificat",
    }, {"owner_name": "MARIA POPESCU"}),

    ("rovinieta", "vignettes", {
        "purchase_date": "2026-07-01", "valid_from": "2026-07-01",
        "valid_until": "2027-07-01", "validity_period": "1_an", "price": 28.5,
    }, {"price": 30.0}),

    ("asigurare", "insurance", {
        "type": "RCA", "policy_number": "RO123456",
        "insurer_company": "Allianz", "purchase_date": "2026-07-01",
        "valid_from": "2026-07-01", "valid_until": "2027-07-01",
        "premium_amount": 650.0,
    }, {"premium_amount": 700.0}),

    ("service", "maintenance", {
        "type": "schimb_ulei", "performed_date": "2026-07-01",
        "cost": 350.0, "next_service_mileage": 150000,
    }, {"cost": 400.0}),

    ("modificare", "modifications", {
        "category": "exterior", "description": "Jante aliaj",
        "cost": 1500.0, "is_homologated": False,
    }, {"description": "Jante aliaj 17 inch"}),
]


@pytest.fixture(scope="module")
def car(client):
    tok = make_user(client, "doc_owner@gmail.com")
    return tok, make_car(client, tok, plate="B-700-DOC")


@pytest.mark.parametrize("name,path,payload,update", DOCUMENTS,
                         ids=[d[0] for d in DOCUMENTS])
def test_document_full_crud(client, car, name, path, payload, update):
    """Creare → listare → citire → editare → stergere, pentru fiecare tip."""
    tok, car_id = car
    base = f"/api/v1/cars/{car_id}/{path}"

    created = client.post(base, json=payload, headers=auth(tok))
    assert created.status_code == 201, f"{name}: creare esuata — {created.text}"
    doc_id = created.json()["id"]

    listed = client.get(base, headers=auth(tok))
    assert listed.status_code == 200
    assert any(d["id"] == doc_id for d in listed.json())

    assert client.get(f"{base}/{doc_id}", headers=auth(tok)).status_code == 200

    edited = client.put(f"{base}/{doc_id}", json=update, headers=auth(tok))
    assert edited.status_code == 200
    for key, value in update.items():
        assert edited.json()[key] == value

    assert client.delete(f"{base}/{doc_id}", headers=auth(tok)).status_code == 204
    assert client.get(f"{base}/{doc_id}", headers=auth(tok)).status_code == 404


def test_schemas_match_database_columns():
    """Fiecare camp din schema de creare trebuie sa existe ca si coloana.

    O nepotrivire produce eroare 500 la salvare (vezi bug-ul cu 'notes').
    """
    from app.schemas import (registration as rs, insurance as ins,
                             vignette as vs, maintenance as ms,
                             modification as mos, car as cs)
    from app.models.registration import VehicleRegistration
    from app.models.insurance import InsurancePolicy
    from app.models.vignette import Vignette
    from app.models.maintenance import MaintenanceRecord
    from app.models.modification import CarModification
    from app.models.car import Car

    pairs = [
        ("talon", rs.RegistrationCreate, VehicleRegistration),
        ("asigurare", ins.InsuranceCreate, InsurancePolicy),
        ("rovinieta", vs.VignetteCreate, Vignette),
        ("service", ms.MaintenanceCreate, MaintenanceRecord),
        ("modificare", mos.ModificationCreate, CarModification),
        ("masina", cs.CarCreate, Car),
    ]
    for name, schema, model in pairs:
        columns = {c.name for c in model.__table__.columns}
        missing = [f for f in schema.model_fields if f not in columns]
        assert not missing, f"{name}: campuri fara coloana in model: {missing}"
