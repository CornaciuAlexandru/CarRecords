import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Date, Float, DateTime, ForeignKey, Enum, Text, Boolean, JSON
from sqlalchemy.orm import relationship
from app.core.database import Base


class CarModification(Base):
    __tablename__ = "car_modifications"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    car_id = Column(String, ForeignKey("cars.id", ondelete="CASCADE"), nullable=False)
    category = Column(
        Enum("motor", "exterior", "interior", "suspensie", "audio",
             "electronic", "frane", "altul", name="modification_category"),
        nullable=False
    )
    description = Column(Text, nullable=False)
    modification_date = Column(Date, nullable=True)
    performed_by = Column(String, nullable=True)
    cost = Column(Float, nullable=True)
    currency = Column(String, default="RON")
    is_homologated = Column(Boolean, default=False)
    homologation_number = Column(String, nullable=True)
    photos = Column(JSON, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    car = relationship("Car", back_populates="modifications")
