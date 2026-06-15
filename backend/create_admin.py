"""
Script pentru crearea contului de administrator.
Rulare: python create_admin.py
"""
import sys
from app.core.database import SessionLocal, engine, Base
import app.models  # noqa
from app.models.user import User
from app.core.security import hash_password

Base.metadata.create_all(bind=engine)

email = input("Email admin: ").strip()
password = input("Parola admin (min 8 caractere, 1 majuscula, 1 cifra): ").strip()
full_name = input("Nume complet: ").strip()

db = SessionLocal()
try:
    if db.query(User).filter(User.email == email).first():
        print("Eroare: email deja existent.")
        sys.exit(1)

    admin = User(
        email=email,
        password_hash=hash_password(password),
        full_name=full_name,
        role="admin",
        max_cars=999,
        subscription_tier="premium",
    )
    db.add(admin)
    db.commit()
    print(f"\nAdmin creat cu succes! ID: {admin.id}")
finally:
    db.close()
