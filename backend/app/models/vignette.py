import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Date, Float, DateTime, ForeignKey, Enum, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class Vignette(Base):
    __tablename__ = "vignettes"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    car_id = Column(String, ForeignKey("cars.id", ondelete="CASCADE"), nullable=False)
    purchase_date = Column(Date, nullable=False)
    valid_from = Column(Date, nullable=False)
    valid_until = Column(Date, nullable=False)
    validity_period = Column(
        Enum("7_zile", "30_zile", "90_zile", "1_an", name="validity_period"),
        nullable=False
    )
    issuer_company = Column(String, nullable=True)
    city = Column(String, nullable=True)
    price = Column(Float, nullable=True)
    currency = Column(String, default="RON")
    invoice_number = Column(String, nullable=True)
    invoice_series = Column(String, nullable=True)
    document_image_path = Column(String, nullable=True)
    ocr_raw_text = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    car = relationship("Car", back_populates="vignettes")
