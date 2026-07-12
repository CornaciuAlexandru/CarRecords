from pydantic import BaseModel
from typing import Optional
from datetime import datetime


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
