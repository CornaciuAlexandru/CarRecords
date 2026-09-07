from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date


class NotificationOut(BaseModel):
    id: str
    user_id: str
    car_id: Optional[str]
    type: str
    title: str
    message: str
    days_before_alert: Optional[int]
    is_read: bool
    triggered_at: datetime

    model_config = {"from_attributes": True}


class PlannedNotification(BaseModel):
    """O alarma pe care telefonul urmeaza sa o programeze local."""
    key: str
    type: str
    car_id: Optional[str]
    title: str
    body: str
    fire_on: date
