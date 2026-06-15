from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional, Literal
from datetime import datetime
import re


class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    phone: Optional[str] = None

    @field_validator("password")
    @classmethod
    def password_strength(cls, v):
        if len(v) < 8:
            raise ValueError("Parola trebuie sa aiba minim 8 caractere")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Parola trebuie sa contina cel putin o litera mare")
        if not re.search(r"[0-9]", v):
            raise ValueError("Parola trebuie sa contina cel putin o cifra")
        return v


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None


class UserPasswordChange(BaseModel):
    current_password: str
    new_password: str


class UserOut(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str]
    role: str
    is_active: bool
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
