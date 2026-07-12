import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from app.core.database import Base


class Car(Base):
    __tablename__ = "cars"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    nickname = Column(String, nullable=True)
    brand = Column(String, nullable=False)
    model = Column(String, nullable=False)
    year = Column(Integer, nullable=False)
    color = Column(String, nullable=True)
    vin_number = Column(String, nullable=True)
    engine_capacity = Column(Integer, nullable=True)
    fuel_type = Column(Enum("benzina", "motorina", "hybrid", "electric", "gpl", name="fuel_type"),
                       nullable=True)
    engine_power = Column(Integer, nullable=True)
    license_plate = Column(String, nullable=False)
    registration_number = Column(String, nullable=True)
    mileage = Column(Integer, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc),
                        onupdate=lambda: datetime.now(timezone.utc))

    owner = relationship("User", back_populates="cars")
    vignettes = relationship("Vignette", back_populates="car", cascade="all, delete-orphan")
    insurance_policies = relationship("InsurancePolicy", back_populates="car", cascade="all, delete-orphan")
    registrations = relationship("VehicleRegistration", back_populates="car", cascade="all, delete-orphan")
    maintenance_records = relationship("MaintenanceRecord", back_populates="car", cascade="all, delete-orphan")
    modifications = relationship("CarModification", back_populates="car", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="car", cascade="all, delete-orphan")
