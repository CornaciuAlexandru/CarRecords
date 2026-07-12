from pydantic import BaseModel
from typing import Optional, Literal
from datetime import date, datetime


class VignetteCreate(BaseModel):
    purchase_date: date
    valid_from: date
    valid_until: date
    validity_period: Literal["7_zile", "30_zile", "90_zile", "1_an"]
    issuer_company: Optional[str] = None
    city: Optional[str] = None
    price: Optional[float] = None
    currency: str = "RON"
    invoice_number: Optional[str] = None
    invoice_series: Optional[str] = None
    notes: Optional[str] = None


class VignetteUpdate(VignetteCreate):
    purchase_date: Optional[date] = None
    valid_from: Optional[date] = None
    valid_until: Optional[date] = None
    validity_period: Optional[Literal["7_zile", "30_zile", "90_zile", "1_an"]] = None


class VignetteOut(BaseModel):
    id: str
    car_id: str
    purchase_date: date
    valid_from: date
    valid_until: date
    validity_period: str
    issuer_company: Optional[str]
    city: Optional[str]
    price: Optional[float]
    currency: str
    invoice_number: Optional[str]
    invoice_series: Optional[str]
    document_image_path: Optional[str]
    notes: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}
