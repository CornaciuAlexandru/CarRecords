from pydantic import AfterValidator, BaseModel, EmailStr, field_validator
from typing import Annotated, Optional, Literal
from datetime import datetime
import re


def normalize_email(v: str) -> str:
    """Adresa, cu litere mici si fara spatii la capete.

    Formal, partea dinaintea lui @ e sensibila la majuscule (RFC 5321), dar
    niciun furnizor real nu face diferenta, iar utilizatorul nu tine minte cu
    ce litere si-a scris adresa la inregistrare. Normalizam la intrare, ca in
    baza de date sa existe o singura forma, si cautarea sa ramana o simpla
    egalitate pe coloana indexata.
    """
    return v.strip().lower()


# Adresa de email a unui cont, mereu in forma normalizata.
Email = Annotated[EmailStr, AfterValidator(normalize_email)]


def validate_password_strength(v: str) -> str:
    """Regulile de parola, in acelasi loc pentru inregistrare, schimbare si
    resetare — altfel o parola respinsa la inregistrare ar putea fi setata
    prin resetare."""
    if len(v) < 8:
        raise ValueError("Parola trebuie sa aiba minim 8 caractere")
    if not re.search(r"[A-Z]", v):
        raise ValueError("Parola trebuie sa contina cel putin o litera mare")
    if not re.search(r"[0-9]", v):
        raise ValueError("Parola trebuie sa contina cel putin o cifra")
    return v


class UserCreate(BaseModel):
    email: Email
    password: str
    full_name: str
    phone: Optional[str] = None
    # Limba aplicatiei, pentru emailul de confirmare a adresei
    lang: Optional[str] = None

    @field_validator("password")
    @classmethod
    def password_strength(cls, v):
        return validate_password_strength(v)


class UserLogin(BaseModel):
    email: Email
    password: str


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None


class UserPasswordChange(BaseModel):
    current_password: str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def password_strength(cls, v):
        return validate_password_strength(v)


class UserOut(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str]
    role: str
    is_active: bool
    email_verified: bool = False
    subscription_tier: str
    max_cars: int
    created_at: datetime

    model_config = {"from_attributes": True}


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserOut


class RefreshRequest(BaseModel):
    refresh_token: str


class AdminUserUpdate(BaseModel):
    is_active: Optional[bool] = None
    role: Optional[Literal["user", "admin"]] = None
    max_cars: Optional[int] = None
    subscription_tier: Optional[Literal["free", "premium"]] = None


# ── Recuperarea contului si stergerea lui ────────────────────────────

class ForgotPasswordRequest(BaseModel):
    email: Email
    # Limba in care se trimite emailul; lipsa ei inseamna engleza
    lang: Optional[str] = None


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def password_strength(cls, v):
        return validate_password_strength(v)


class EmailTokenRequest(BaseModel):
    token: str


class ResendVerificationRequest(BaseModel):
    lang: Optional[str] = None


class AccountDeleteRequest(BaseModel):
    """Stergerea contului cere parola: un telefon lasat deblocat nu trebuie
    sa fie de ajuns ca sa dispara toate datele."""
    password: str
