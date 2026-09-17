from pydantic import BaseModel
from typing import Optional, Literal
from datetime import datetime

from app.core.vehicles import DEFAULT_VEHICLE_TYPE

# Tinut sincron cu app/core/vehicles.VEHICLE_TYPES. Literal cere valori
# scrise la propriu, deci nu se poate construi din tuplu.
VehicleType = Literal["masina", "motocicleta", "camion", "tir", "utilaj", "altul"]


class CarCreate(BaseModel):
    nickname: Optional[str] = None
    vehicle_type: VehicleType = DEFAULT_VEHICLE_TYPE
    brand: str
    model: str
    year: int
    color: Optional[str] = None
    vin_number: Optional[str] = None
    engine_capacity: Optional[int] = None
    fuel_type: Optional[Literal["benzina", "motorina", "hybrid", "electric", "gpl"]] = None
    engine_power: Optional[int] = None
    license_plate: str
    registration_number: Optional[str] = None
    mileage: Optional[int] = None


class CarUpdate(CarCreate):
    # La editare, un camp nemodificat nu trebuie sa readuca tipul la "masina".
    vehicle_type: Optional[VehicleType] = None
    brand: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = None
    license_plate: Optional[str] = None


class CarOut(BaseModel):
    id: str
    user_id: str
    nickname: Optional[str]
    brand: str
    model: str
    year: int
    color: Optional[str]
    vin_number: Optional[str]
    engine_capacity: Optional[int]
    fuel_type: Optional[str]
    engine_power: Optional[int]
    license_plate: str
    registration_number: Optional[str]
    mileage: Optional[int]
    vehicle_type: str = DEFAULT_VEHICLE_TYPE
    # Cate scanari OCR s-au folosit din cele incluse cu masina si cate au ramas.
    # Ajung la aplicatie ca sa poata arata "mai ai 3 scanari" inainte ca omul sa
    # faca poza, nu dupa.
    ocr_scans: int = 0
    ocr_scans_left: int = 0
    created_at: datetime

    model_config = {"from_attributes": True}
