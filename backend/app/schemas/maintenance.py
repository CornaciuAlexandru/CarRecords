from pydantic import BaseModel
from typing import Optional, Literal, Any
from datetime import date, datetime


MaintenanceType = Literal[
    "schimb_ulei", "filtre", "placute_frana", "anvelope",
    "distributie", "curea_alternator", "baterie", "amortizoare", "bujii", "altul"
]


class MaintenanceCreate(BaseModel):
    type: MaintenanceType
    description: Optional[str] = None
    performed_date: date
    mileage_at_service: Optional[int] = None
    next_service_date: Optional[date] = None
    next_service_mileage: Optional[int] = None
    service_shop_name: Optional[str] = None
    city: Optional[str] = None
    cost: Optional[float] = None
    currency: str = "RON"
    parts_replaced: Optional[list[dict[str, Any]]] = None
    invoice_number: Optional[str] = None
    notes: Optional[str] = None


class MaintenanceUpdate(MaintenanceCreate):
    type: Optional[MaintenanceType] = None
    performed_date: Optional[date] = None


class MaintenanceOut(BaseModel):
    id: str
    car_id: str
    type: str
    description: Optional[str]
    performed_date: date
    mileage_at_service: Optional[int]
    next_service_date: Optional[date]
    next_service_mileage: Optional[int]
    service_shop_name: Optional[str]
    city: Optional[str]
    cost: Optional[float]
    currency: str
    parts_replaced: Optional[list]
    invoice_number: Optional[str]
    document_image_path: Optional[str]
    notes: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}
