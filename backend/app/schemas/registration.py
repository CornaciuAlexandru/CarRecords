from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime


class RegistrationCreate(BaseModel):
    registration_number: Optional[str] = None
    registration_date: Optional[date] = None
    itp_expiry_date: Optional[date] = None
    owner_name: Optional[str] = None
    owner_address: Optional[str] = None
    owner_cnp_masked: Optional[str] = None
    car_series: Optional[str] = None
    brand: Optional[str] = None
    model: Optional[str] = None
    manufacturing_year: Optional[str] = None
    registration_authority: Optional[str] = None
    category: Optional[str] = None
    homologation_number: Optional[str] = None
    notes: Optional[str] = None


class RegistrationUpdate(RegistrationCreate):
    pass


class RegistrationOut(BaseModel):
    id: str
    car_id: str
    registration_number: Optional[str] = None
    registration_date: Optional[date] = None
    itp_expiry_date: Optional[date] = None
    owner_name: Optional[str] = None
    owner_address: Optional[str] = None
    owner_cnp_masked: Optional[str] = None
    car_series: Optional[str] = None
    brand: Optional[str] = None
    model: Optional[str] = None
    manufacturing_year: Optional[str] = None
    registration_authority: Optional[str] = None
    category: Optional[str] = None
    homologation_number: Optional[str] = None
    notes: Optional[str] = None
    document_image_path: Optional[str] = None
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}
