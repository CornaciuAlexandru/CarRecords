import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Date, DateTime, ForeignKey, Boolean, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class VehicleRegistration(Base):
    __tablename__ = "vehicle_registrations"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    car_id = Column(String, ForeignKey("cars.id", ondelete="CASCADE"), nullable=False)
    registration_number = Column(String, nullable=True)
    registration_date = Column(Date, nullable=True)
    itp_expiry_date = Column(Date, nullable=True)
    owner_name = Column(String, nullable=True)
    owner_address = Column(String, nullable=True)
    owner_cnp_masked = Column(String, nullable=True)
    car_series = Column(String, nullable=True)   # VIN / serie sasiu
    brand = Column(String, nullable=True)
    model = Column(String, nullable=True)
    manufacturing_year = Column(String, nullable=True)
    registration_authority = Column(String, nullable=True)
    category = Column(String, nullable=True)
    homologation_number = Column(String, nullable=True)
    document_image_path = Column(String, nullable=True)
    ocr_raw_text = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    car = relationship("Car", back_populates="registrations")
