import shutil
import uuid
import aiofiles
from pathlib import Path
from fastapi import UploadFile, HTTPException
from app.core.config import settings, DOCUMENTS_PATH, PHOTOS_PATH

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp", "image/heic"}
MAX_BYTES = settings.MAX_FILE_SIZE_MB * 1024 * 1024


async def _save_file(file: UploadFile, dest_dir: Path, user_id: str) -> Path:
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(status_code=400, detail="Tip fisier nepermis. Acceptat: JPEG, PNG, WEBP")

    content = await file.read()
    if len(content) > MAX_BYTES:
        raise HTTPException(status_code=400, detail=f"Fisierul depaseste limita de {settings.MAX_FILE_SIZE_MB}MB")

    user_dir = dest_dir / user_id
    user_dir.mkdir(parents=True, exist_ok=True)

    ext = Path(file.filename).suffix.lower() if file.filename else ".jpg"
    filename = f"{uuid.uuid4()}{ext}"
    file_path = user_dir / filename

    async with aiofiles.open(file_path, "wb") as f:
        await f.write(content)

    return file_path


async def save_document(file: UploadFile, user_id: str) -> Path:
    return await _save_file(file, DOCUMENTS_PATH, user_id)


async def save_photo(file: UploadFile, user_id: str) -> Path:
    return await _save_file(file, PHOTOS_PATH, user_id)


def delete_user_files(user_id: str) -> None:
    """Sterge pozele si documentele unui utilizator.

    Chemata la stergerea contului: fara asta, fisierele ar ramane pe disc
    dupa ce randurile din baza de date dispar.
    """
    for base in (DOCUMENTS_PATH, PHOTOS_PATH):
        shutil.rmtree(base / user_id, ignore_errors=True)
