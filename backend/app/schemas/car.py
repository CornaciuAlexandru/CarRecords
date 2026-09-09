from pydantic import BaseModel
from typing import Optional, Literal
from datetime import datetime


class CarCreate(BaseModel):
    nickname: Optional[str] = None
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
    # Cate scanari OCR s-au folosit din cele incluse cu masina si cate au ramas.
    # Ajung la aplicatie ca sa poata arata "mai ai 3 scanari" inainte ca omul sa
    # faca poza, nu dupa.
    ocr_scans: int = 0
    ocr_scans_left: int = 0
    created_at: datetime

    model_config = {"from_attributes": True}
