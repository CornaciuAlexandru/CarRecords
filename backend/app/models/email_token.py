import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, Enum
from sqlalchemy.orm import relationship
from app.core.database import Base
from app.core.security import utcnow


class EmailToken(Base):
    """Token trimis pe email: resetare parola sau confirmare adresa.

    Se pastreaza in baza de date (nu JWT) pentru ca trebuie sa poata fi
    folosit o singura data si anulat inainte de termen. In tabel intra doar
    hash-ul: din continutul bazei nu se poate reconstrui linkul.
    """
    __tablename__ = "email_tokens"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"),
                     nullable=False, index=True)
    token_hash = Column(String, unique=True, index=True, nullable=False)
    purpose = Column(Enum("reset", "verify", name="email_token_purpose"), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    used_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=utcnow)

    user = relationship("User", back_populates="email_tokens")

    @property
    def is_usable(self) -> bool:
        return self.used_at is None and self.expires_at > utcnow()
