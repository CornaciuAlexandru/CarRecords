import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Date, Float, DateTime, Integer, ForeignKey, Enum, Text, JSON
from sqlalchemy.orm import relationship
from app.core.database import Base


class MaintenanceRecord(Base):
    __tablename__ = "maintenance_records"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    car_id = Column(String, ForeignKey("cars.id", ondelete="CASCADE"), nullable=False)
    type = Column(
        Enum("schimb_ulei", "filtre", "placute_frana", "anvelope", "distributie",
             "curea_alternator", "baterie", "amortizoare", "bujii", "altul",
             name="maintenance_type"),
        nullable=False
    )
    description = Column(Text, nullable=True)
    performed_date = Column(Date, nullable=False)
    mileage_at_service = Column(Integer, nullable=True)
    next_service_date = Column(Date, nullable=True)
    next_service_mileage = Column(Integer, nullable=True)
    service_shop_name = Column(String, nullable=True)
    city = Column(String, nullable=True)
    cost = Column(Float, nullable=True)
    currency = Column(String, default="RON")
    parts_replaced = Column(JSON, nullable=True)
    invoice_number = Column(String, nullable=True)
    document_image_path = Column(String, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    car = relationship("Car", back_populates="maintenance_records")
