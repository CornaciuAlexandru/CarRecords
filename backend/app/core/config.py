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

    # ── Protectie la incercari repetate de autentificare ─────────
    # Fereastra in care se numara incercarile de login.
    LOGIN_WINDOW_MINUTES: int = 15
    # Cate parole gresite acceptam de la acelasi IP pentru acelasi cont.
    LOGIN_MAX_FAILURES: int = 5
    # Cate cereri de login acceptam de la un IP, indiferent de rezultat.
    # Mai mare decat limita de mai sus: de pe aceeasi retea se pot autentifica
    # mai multi oameni.
    LOGIN_MAX_ATTEMPTS_PER_IP: int = 20

    # ── Protectie la creari repetate de cont ─────────────────────
    REGISTER_WINDOW_MINUTES: int = 60
    # Cate conturi noi pot pleca de la acelasi IP intr-o fereastra.
    REGISTER_MAX_ACCOUNTS_PER_IP: int = 5
    # Cate cereri de inregistrare acceptam, indiferent de rezultat. Peste
    # asta, cineva incearca sa afle ce adrese au deja cont.
    REGISTER_MAX_ATTEMPTS_PER_IP: int = 20

    # ── Email (resetare parola, verificare adresa) ────────────────
    # Fara SMTP_HOST configurat mesajele nu se pierd: se scriu in
    # backend/sent_emails.log si in consola, deci linkul e folosibil si in
    # dezvoltare, fara cont de mail.
    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM: str = "CarRecords <noreply@carrecords.ro>"
    SMTP_STARTTLS: bool = True

    # Adresa publica a backend-ului, folosita in linkurile din email.
    # Local: IP-ul din retea. In cloud: https://api.carrecords.ro
    PUBLIC_URL: str = "http://127.0.0.1:8000"

    # Cat timp raman valabile linkurile trimise pe email
    RESET_TOKEN_EXPIRE_MINUTES: int = 30
    VERIFY_TOKEN_EXPIRE_HOURS: int = 48

    # Cand e activat, conturile cu adresa neconfirmata nu se pot autentifica.
    # Implicit oprit: conturile existente nu au adresa confirmata si nu vrem
    # sa le blocam retroactiv.
    REQUIRE_EMAIL_VERIFICATION: bool = False

    # ── Descoperire in retea locala (doar pentru rulare pe PC) ────
    DISCOVERY_ENABLED: bool = True

    class Config:
        env_file = ".env"

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT.lower() in ("production", "prod")

    @property
    def mail_enabled(self) -> bool:
        """Exista un server SMTP configurat? Daca nu, emailurile se scriu in fisier."""
        return bool(self.SMTP_HOST.strip())

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
