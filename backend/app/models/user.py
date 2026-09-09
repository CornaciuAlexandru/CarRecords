import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Boolean, Integer, DateTime, Enum
from sqlalchemy.orm import relationship
from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    phone = Column(String, nullable=True)
    role = Column(Enum("user", "admin", name="user_role"), default="user", nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    email_verified = Column(Boolean, default=False, nullable=False)
    email_verified_at = Column(DateTime, nullable=True)
    # Creste la fiecare schimbare/resetare de parola. Tokenurile emise
    # inainte poarta o versiune mai veche si sunt refuzate.
    token_version = Column(Integer, default=0, nullable=False)
    # Text, nu Enum: planurile se schimba (free -> pro -> maxi, si ce mai vine),
    # iar un enum nativ de PostgreSQL cere o migrare de tip la fiecare valoare
    # noua. Valorile permise sunt in app/core/entitlements.py, verificate acolo.
    subscription_tier = Column(String, default="free", nullable=False)
    # Depasire acordata manual peste limita planului. 0 inseamna "cat da planul".
    max_cars = Column(Integer, default=0)
    # Scanari OCR cumparate la bucata, in afara abonamentului. Se consuma dupa
    # ce se termina cele incluse cu masina si nu expira.
    scan_credits = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc),
                        onupdate=lambda: datetime.now(timezone.utc))

    cars = relationship("Car", back_populates="owner", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")
    email_tokens = relationship("EmailToken", back_populates="user", cascade="all, delete-orphan")
