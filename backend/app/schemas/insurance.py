from pydantic import BaseModel
from typing import Optional, Literal, Any
from datetime import date, datetime


class InsuranceCreate(BaseModel):
    type: Literal["RCA", "CASCO", "alta"]
    policy_number: Optional[str] = None
    insurer_company: str
    agent_name: Optional[str] = None
    agent_phone: Optional[str] = None
    purchase_date: date
    valid_from: date
    valid_until: date
    premium_amount: Optional[float] = None
    currency: str = "RON"
    payment_frequency: Literal["anual", "semestrial", "trimestrial", "lunar"] = "anual"
    coverage_details: Optional[dict[str, Any]] = None
    deductible_amount: Optional[float] = None
    roadside_assistance: bool = False
    notes: Optional[str] = None


class InsuranceUpdate(InsuranceCreate):
    type: Optional[Literal["RCA", "CASCO", "alta"]] = None
    insurer_company: Optional[str] = None
    purchase_date: Optional[date] = None
    valid_from: Optional[date] = None
    valid_until: Optional[date] = None


class InsuranceOut(BaseModel):
    id: str
    car_id: str
    type: str
    policy_number: Optional[str]
    insurer_company: str
    agent_name: Optional[str]
    agent_phone: Optional[str]
    purchase_date: date
    valid_from: date
    valid_until: date
    premium_amount: Optional[float]
    currency: str
    payment_frequency: str
    coverage_details: Optional[dict]
    deductible_amount: Optional[float]
    roadside_assistance: bool
    document_image_path: Optional[str]
    notes: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}
