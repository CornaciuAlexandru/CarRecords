"""
Script de migrare: adauga coloanele noi la tabelul vehicle_registrations
fara sa stearga datele existente.

Ruleaza o singura data: python migrate_registration.py
"""
import sqlite3
from pathlib import Path
from app.core.config import settings

# Extrage calea SQLite din DATABASE_URL (forma: sqlite:///./path/to/db.sqlite3)
db_url = settings.DATABASE_URL
if not db_url.startswith("sqlite"):
    print("Migrarea manuala este necesara doar pentru SQLite.")
    exit(0)

db_path = db_url.replace("sqlite:///", "").replace("sqlite://", "")
if db_path.startswith("./"):
    db_path = db_path[2:]

db_path = Path(db_path)
if not db_path.is_absolute():
    db_path = Path(__file__).parent / db_path

print(f"DB path: {db_path}")

conn = sqlite3.connect(db_path)
cur = conn.cursor()

# Verifica coloanele existente
cur.execute("PRAGMA table_info(vehicle_registrations)")
existing = {row[1] for row in cur.fetchall()}
print(f"Coloane existente: {existing}")

new_columns = {
    "registration_number":  "TEXT",
    "owner_address":        "TEXT",
    "car_series":           "TEXT",
    "brand":                "TEXT",
    "model":                "TEXT",
    "manufacturing_year":   "TEXT",
    "notes":                "TEXT",
}

for col, col_type in new_columns.items():
    if col not in existing:
        cur.execute(f"ALTER TABLE vehicle_registrations ADD COLUMN {col} {col_type}")
        print(f"  + Adaugat: {col} {col_type}")
    else:
        print(f"  = Exista deja: {col}")

conn.commit()
conn.close()
print("Migrare finalizata.")
