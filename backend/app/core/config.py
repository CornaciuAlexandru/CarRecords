from pydantic_settings import BaseSettings
from pathlib import Path
from typing import List
import secrets


class Settings(BaseSettings):
    # ── Mediu ────────────────────────────────────────────────────
    # "local"      = pe calculatorul propriu (SQLite, CORS permisiv)
    # "production" = server in cloud (PostgreSQL, CORS restrans, HTTPS)
    ENVIRONMENT: str = "local"

    # ── Baza de date ─────────────────────────────────────────────
    # Local:  sqlite:///./carmanager.db
    # Cloud:  postgresql+psycopg2://user:parola@db:5432/carrecords
    DATABASE_URL: str = "sqlite:///./carmanager.db"

    # ── Securitate ───────────────────────────────────────────────
    SECRET_KEY: str = "dev-secret-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # Originile permise sa apeleze API-ul. In productie se restrange la
    # domeniile proprii; aplicatiile mobile nu trimit Origin, deci nu sunt
    # afectate de CORS.
    CORS_ORIGINS: str = "*"

    # ── Fisiere ──────────────────────────────────────────────────
    UPLOAD_DIR: str = "uploads"
    MAX_FILE_SIZE_MB: int = 10

    # ── OCR ──────────────────────────────────────────────────────
    # Pe Windows e calea catre .exe; in container e simplu "tesseract".
    TESSERACT_PATH: str = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

    # ── Descoperire in retea locala (doar pentru rulare pe PC) ────
    DISCOVERY_ENABLED: bool = True

    class Config:
        env_file = ".env"

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT.lower() in ("production", "prod")

    @property
    def cors_origins_list(self) -> List[str]:
        if self.CORS_ORIGINS.strip() == "*":
            return ["*"]
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]


settings = Settings()

# In productie o cheie implicita ar permite oricui sa isi fabrice tokenuri
# de administrator. Oprim pornirea daca nu a fost setata explicit.
if settings.is_production and settings.SECRET_KEY in ("dev-secret-key", "", None):
    raise RuntimeError(
        "SECRET_KEY nu este setat in productie. Genereaza unul cu:\n"
        f"  python -c \"import secrets; print(secrets.token_hex(32))\"\n"
        f"  (exemplu: {secrets.token_hex(32)})"
    )

UPLOAD_PATH = Path(settings.UPLOAD_DIR)
DOCUMENTS_PATH = UPLOAD_PATH / "documents"
PHOTOS_PATH = UPLOAD_PATH / "photos"
