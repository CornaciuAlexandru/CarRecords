from pydantic_settings import BaseSettings
from pathlib import Path


class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./carmanager.db"
    SECRET_KEY: str = "dev-secret-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    UPLOAD_DIR: str = "uploads"
    MAX_FILE_SIZE_MB: int = 10
    TESSERACT_PATH: str = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

    class Config:
        env_file = ".env"


settings = Settings()

UPLOAD_PATH = Path(settings.UPLOAD_DIR)
DOCUMENTS_PATH = UPLOAD_PATH / "documents"
PHOTOS_PATH = UPLOAD_PATH / "photos"
