from datetime import datetime, timedelta, timezone
from typing import Optional, Tuple
import hashlib
import secrets
from jose import JWTError, jwt
import bcrypt
from app.core.config import settings


def utcnow() -> datetime:
    """Ora UTC fara fus orar.

    Coloanele DateTime nu pastreaza fusul nici pe SQLite, nici pe PostgreSQL,
    iar compararea unei date "aware" cu una citita din baza da TypeError.
    Tinem totul naiv, in UTC.
    """
    return datetime.now(timezone.utc).replace(tzinfo=None)


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt(rounds=12)).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))


def issue_tokens(user) -> Tuple[str, str]:
    """Pereche access + refresh pentru un utilizator.

    Amandoua poarta versiunea de token a contului (`tv`): la schimbarea sau
    resetarea parolei versiunea creste, iar tokenurile emise inainte devin
    invalide — altfel un refresh token furat ar ramane valabil 30 de zile.
    """
    data = {"sub": user.id, "tv": user.token_version or 0}
    return create_access_token(data), create_refresh_token(data)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode["exp"] = expire
    to_encode["type"] = "access"
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode["exp"] = expire
    to_encode["type"] = "refresh"
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_token(token: str) -> Optional[dict]:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except JWTError:
        return None


# ── Tokenuri trimise pe email ────────────────────────────────────────
# Nu sunt JWT: se pastreaza in baza de date ca sa poata fi anulate si
# folosite o singura data. In tabel intra doar hash-ul, deci cine citeste
# baza de date nu poate reconstrui linkul din email.

def generate_email_token() -> Tuple[str, str]:
    """Returneaza (token pentru link, hash pentru baza de date)."""
    raw = secrets.token_urlsafe(32)
    return raw, hash_email_token(raw)


def hash_email_token(raw: str) -> str:
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()
