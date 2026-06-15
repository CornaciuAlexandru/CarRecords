from pydantic import BaseModel
from typing import Optional, Literal
from datetime import date, datetime


ModificationCategory = Literal[
    "motor", "exterior", "interior", "suspensie",
    "audio", "electronic", "frane", "altul"
]


class ModificationCreate(BaseModel):
    category: ModificationCategory
    description: str
    modification_date: Optional[date] = None
    performed_by: Optional[str] = None
    cost: Optional[float] = None
    currency: str = "RON"
    is_homologated: bool = False
    homologation_number: Optional[str] = None
    notes: Optional[str] = None


class ModificationUpdate(ModificationCreate):
    category: Optional[ModificationCategory] = None
    description: Optional[str] = None


class ModificationOut(BaseModel):
    id: str
    car_id: str
    category: str
    description: str
    modification_date: Optional[date]
    performed_by: Optional[str]
    cost: Optional[float]
    currency: str
    is_homologated: bool
    homologation_number: Optional[str]
    photos: Optional[list]
    notes: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}
