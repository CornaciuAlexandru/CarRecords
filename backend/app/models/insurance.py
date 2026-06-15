import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Date, Float, DateTime, ForeignKey, Enum, Text, Boolean, JSON
from sqlalchemy.orm import relationship
from app.core.database import Base


class InsurancePolicy(Base):
    __tablename__ = "insurance_policies"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    car_id = Column(String, ForeignKey("cars.id", ondelete="CASCADE"), nullable=False)
    type = Column(Enum("RCA", "CASCO", "alta", name="insurance_type"), nullable=False)
    policy_number = Column(String, nullable=True)
    insurer_company = Column(String, nullable=False)
    agent_name = Column(String, nullable=True)
    agent_phone = Column(String, nullable=True)
    purchase_date = Column(Date, nullable=False)
    valid_from = Column(Date, nullable=False)
    valid_until = Column(Date, nullable=False)
    premium_amount = Column(Float, nullable=True)
    currency = Column(String, default="RON")
    payment_frequency = Column(
        Enum("anual", "semestrial", "trimestrial", "lunar", name="payment_freq"),
        default="anual"
    )
    coverage_details = Column(JSON, nullable=True)
    deductible_amount = Column(Float, nullable=True)
    roadside_assistance = Column(Boolean, default=False)
    document_image_path = Column(String, nullable=True)
    ocr_raw_text = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    car = relationship("Car", back_populates="insurance_policies")
