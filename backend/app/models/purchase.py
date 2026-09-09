import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base


class Purchase(Base):
    """O cumparare verificata la magazin.

    Exista in principal ca sa nu poata fi folosita de doua ori. `store_token` e
    unic: aceeasi chitanta nu poate fi trimisa de pe doua conturi, si nici de
    doua ori de pe acelasi cont ca sa adune credite.
    """
    __tablename__ = "purchases"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(String, nullable=False)
    kind = Column(String, nullable=False)
    # Chitanta de la magazin. Unic la nivel de tabel - asta e apararea.
    store_token = Column(String, nullable=False, unique=True, index=True)
    # Ce a primit contul, pastrat ca sa se poata reconstitui un cont din
    # istoricul cumpararilor daca vreodata se strica ceva.
    granted_tier = Column(String, nullable=True)
    granted_scans = Column(Integer, default=0)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="purchases")
