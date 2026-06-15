import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Boolean, DateTime, ForeignKey, Enum, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    car_id = Column(String, ForeignKey("cars.id", ondelete="CASCADE"), nullable=True)
    type = Column(
        Enum("rovinieta_expira", "asigurare_expira", "itp_expira",
             "revizie_km", "revizie_data", "sistem", name="notification_type"),
        nullable=False
    )
    title = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    days_before_alert = Column(Integer, nullable=True)
    is_read = Column(Boolean, default=False)
    triggered_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="notifications")
    car = relationship("Car", back_populates="notifications")
