import json
import shutil
import socket
import threading
import time
from datetime import date
from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
from app.core.database import engine, Base
from app.api.v1.router import api_router
from app.core.config import DOCUMENTS_PATH, PHOTOS_PATH, settings
from app.core.database import SessionLocal
import app.models  # noqa: F401 - ensures all models are registered

DISCOVERY_PORT = 8765
DISCOVERY_MSG  = b"CARRECORDS_DISCOVER"
DISCOVERY_RESP = b"CARRECORDS_HERE:8000"

BASE_DIR = Path(__file__).resolve().parent.parent
VERSION_FILE = BASE_DIR / "version.json"
DOWNLOADS_DIR = BASE_DIR / "downloads"
DB_FILE = BASE_DIR / "carmanager.db"
BACKUPS_DIR = BASE_DIR / "backups"
BACKUP_KEEP = 14          # pastram ultimele 14 backup-uri zilnice
BACKUP_INTERVAL = 86400   # 24 ore, pentru sesiuni lungi fara restart


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    DOCUMENTS_PATH.mkdir(parents=True, exist_ok=True)
    PHOTOS_PATH.mkdir(parents=True, exist_ok=True)
    DOWNLOADS_DIR.mkdir(parents=True, exist_ok=True)
    _migrate_missing_columns()
    _migrate_max_cars()
    _migrate_lowercase_emails()
    # Descoperirea prin broadcast are sens doar in retea locala.
    # In cloud clientii folosesc un domeniu fix.
    if settings.DISCOVERY_ENABLED and not settings.is_production:
        _start_discovery_server()
    # Backup-ul local e util doar cu SQLite; in cloud se folosesc
    # snapshot-urile bazei de date PostgreSQL.
    if DB_FILE.exists():
        _start_backup_scheduler()
    yield


def _backup_database():
    """Copiaza baza de date in backups/ (max un backup pe zi, pastreaza ultimele 14)."""
    try:
        if not DB_FILE.exists():
            return
        BACKUPS_DIR.mkdir(parents=True, exist_ok=True)
        target = BACKUPS_DIR / f"carmanager_{date.today().isoformat()}.db"
        if not target.exists():
            shutil.copy2(DB_FILE, target)
        # Pastram doar ultimele BACKUP_KEEP backup-uri
        backups = sorted(BACKUPS_DIR.glob("carmanager_*.db"))
        for old in backups[:-BACKUP_KEEP]:
            old.unlink(missing_ok=True)
    except Exception:
        pass  # backup-ul nu trebuie sa blocheze niciodata pornirea


def _start_backup_scheduler():
    """Backup imediat la pornire + o data la 24h (pentru sesiuni lungi)."""
    _backup_database()

    def _loop():
        while True:
            time.sleep(BACKUP_INTERVAL)
            _backup_database()

    threading.Thread(target=_loop, daemon=True).start()


def _start_discovery_server():
    """Server UDP care raspunde la broadcast-uri de descoperire de pe telefon."""
    def _listen():
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.bind(("", DISCOVERY_PORT))
        except Exception:
            return  # Portul poate fi ocupat — ignoram silentios
        while True:
            try:
                data, addr = sock.recvfrom(256)
                if data.strip() == DISCOVERY_MSG:
                    sock.sendto(DISCOVERY_RESP, addr)
            except Exception:
                break

    t = threading.Thread(target=_listen, daemon=True)
    t.start()


def _migrate_missing_columns():
    """Adauga automat coloanele noi din modele care lipsesc din tabelele
    existente (create_all nu modifica tabele deja create).

    Tipul coloanei se compileaza pentru dialectul curent, deci functioneaza
    identic pe SQLite si pe PostgreSQL.
    """
    from sqlalchemy import text, inspect as sa_inspect
    try:
        inspector = sa_inspect(engine)
        existing_tables = set(inspector.get_table_names())
        for table in Base.metadata.tables.values():
            if table.name not in existing_tables:
                continue
            existing = {c["name"] for c in inspector.get_columns(table.name)}
            for col in table.columns:
                if col.name in existing:
                    continue
                sql_type = col.type.compile(dialect=engine.dialect)
                with engine.begin() as conn:
                    conn.execute(text(
                        f'ALTER TABLE "{table.name}" '
                        f'ADD COLUMN "{col.name}" {sql_type}'
                    ))
                    # ALTER lasa NULL pe randurile existente, chiar daca in
                    # model coloana are default. Le completam, altfel
                    # randurile vechi ies din aplicatie cu valori nule
                    # acolo unde codul asteapta un numar sau un boolean.
                    if col.default is not None and getattr(col.default, "is_scalar", False):
                        conn.execute(
                            text(f'UPDATE "{table.name}" SET "{col.name}" = :v '
                                 f'WHERE "{col.name}" IS NULL'),
                            {"v": col.default.arg},
                        )
    except Exception:
        pass  # migrarea nu trebuie sa blocheze pornirea


def _migrate_lowercase_emails():
    """Trece adresele salvate la litere mici.

    Cautarea contului e o egalitate simpla pe coloana `email`, iar aceasta e
    sensibila la majuscule. Conturile create inainte de normalizarea la
    intrare ar ramane inaccesibile pentru cine isi scrie adresa altfel decat
    la inregistrare.

    Daca doua conturi difera doar prin litere mari, nu le atingem: le-am
    ciocni pe indexul unic. Raman ca inainte si se rezolva manual.
    """
    from collections import Counter
    from app.models.user import User
    db = SessionLocal()
    try:
        users = db.query(User).all()
        mixed = [u for u in users if u.email != u.email.lower()]
        if not mixed:
            return
        # Cate conturi ar ajunge la aceeasi adresa dupa normalizare
        counts = Counter(u.email.lower() for u in users)
        for user in mixed:
            target = user.email.lower()
            if counts[target] > 1:
                print(f"[migrare] {user.email} s-ar ciocni cu {target}; il las asa")
                continue
            user.email = target
        db.commit()
    except Exception:
        db.rollback()
    finally:
        db.close()


def _migrate_max_cars():
    """Migrare: seteaza max_cars=3 pentru utilizatorii normali (nu admin) care inca au valoarea
    implicita veche de 10."""
    from app.models.user import User
    db = SessionLocal()
    try:
        updated = (
            db.query(User)
            .filter(User.role == "user", User.max_cars == 10)
            .update({"max_cars": 3}, synchronize_session=False)
        )
        if updated:
            db.commit()
    except Exception:
        db.rollback()
    finally:
        db.close()


app = FastAPI(
    title="CarManager API",
    description="API pentru gestionarea documentelor si datelor auto",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")

# Folderele trebuie sa existe INAINTE de mount (StaticFiles verifica la
# creare, iar intr-un container proaspat directoarele nu exista inca).
from app.core.config import PHOTOS_PATH  # noqa: E402
for _d in (DOWNLOADS_DIR, PHOTOS_PATH, DOCUMENTS_PATH):
    _d.mkdir(parents=True, exist_ok=True)

# Servire fisiere installer (folosit doar de aplicatia Windows)
app.mount("/downloads", StaticFiles(directory=str(DOWNLOADS_DIR)), name="downloads")

# Servire poze modificari
app.mount("/photos", StaticFiles(directory=str(PHOTOS_PATH)), name="photos")


@app.get("/health")
def health_check():
    data = json.loads(VERSION_FILE.read_text()) if VERSION_FILE.exists() else {}
    return {"status": "ok", "version": data.get("version", "1.0.0")}


@app.get("/version")
def get_version(client_version: str = "0.0.0"):
    """Returneaza informatii despre versiunea curenta a aplicatiei."""
    if not VERSION_FILE.exists():
        return JSONResponse({"version": "1.0.0", "update_available": False})

    data = json.loads(VERSION_FILE.read_text())
    server_ver  = tuple(int(x) for x in data["version"].split("."))
    client_ver  = tuple(int(x) for x in client_version.split("."))
    min_ver     = tuple(int(x) for x in data.get("min_version", "1.0.0").split("."))

    update_available = server_ver > client_ver
    force_update     = client_ver < min_ver or data.get("force_update", False)

    return {
        "version":          data["version"],
        "update_available": update_available,
        "force_update":     force_update,
        "changelog":        data.get("changelog", ""),
        "download_url":     f"/downloads/{data['installer_filename']}" if update_available else None,
        "installer_filename": data.get("installer_filename"),
        "sha256":           data.get("sha256"),
    }
