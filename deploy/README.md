# Instalarea CarRecords pe un server în cloud

Rezultat: backend accesibil de oriunde, pe HTTPS, fără să mai fie nevoie ca
PC-ul tău să fie pornit.

---

## Ce îți trebuie înainte

| | Detaliu | Cost aproximativ |
|---|---|---|
| **VPS** | 2 GB RAM, Ubuntu 24.04 (Hetzner CX22, DigitalOcean, Contabo…) | 4–6 €/lună |
| **Domeniu** | ex. `carrecords.ro` sau un subdomeniu al unuia existent | 10–15 €/an |

> Un VPS de 2 GB e suficient: OCR-ul cu Tesseract e partea cea mai
> solicitantă, dar rulează doar câteva secunde per document scanat.

---

## Pasul 1 — Îndreaptă domeniul spre server

La furnizorul domeniului, adaugă un record DNS:

```
Tip:    A
Nume:   api          (rezultă api.domeniul-tau.ro)
Valoare: <IP-ul VPS-ului>
TTL:    3600
```

Verifică propagarea (poate dura până la o oră):
```bash
nslookup api.domeniul-tau.ro
```

---

## Pasul 2 — Pregătește serverul

Conectat prin SSH la VPS, ca root:

```bash
# Docker
curl -fsSL https://get.docker.com | sh

# Firewall: doar SSH și web
ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp && ufw --force enable
```

---

## Pasul 3 — Adu codul pe server

```bash
git clone https://github.com/CornaciuAlexandru/CarRecords.git
cd CarRecords/deploy
```

---

## Pasul 4 — Configurează secretele

```bash
cp .env.example .env
nano .env
```

Completează:

```env
DOMAIN=api.domeniul-tau.ro
POSTGRES_USER=carrecords
POSTGRES_DB=carrecords
POSTGRES_PASSWORD=<rezultatul din: openssl rand -hex 24>
SECRET_KEY=<rezultatul din: openssl rand -hex 32>
CORS_ORIGINS=*
```

Generează cele două valori aleatoare direct pe server:
```bash
echo "POSTGRES_PASSWORD=$(openssl rand -hex 24)"
echo "SECRET_KEY=$(openssl rand -hex 32)"
```

---

## Pasul 5 — Pornește

```bash
docker compose up -d --build
```

Prima pornire durează ~5 minute (se compilează imaginea cu Tesseract).
Caddy obține automat certificatul HTTPS de la Let's Encrypt.

Verifică:
```bash
curl https://api.domeniul-tau.ro/health
# {"status":"ok","version":"1.0.15"}
```

---

## Pasul 6 — Creează contul de administrator

```bash
docker compose exec backend python -c "
from app.core.database import SessionLocal, engine, Base
import app.models
from app.models.user import User
from app.core.security import hash_password
Base.metadata.create_all(bind=engine)
db = SessionLocal()
db.add(User(email='EMAILUL_TAU', password_hash=hash_password('PAROLA_TA'),
            full_name='Administrator', role='admin', max_cars=999,
            subscription_tier='premium'))
db.commit(); print('Admin creat.')
"
```

---

## Pasul 7 — Compilează aplicațiile pentru cloud

Pe PC-ul tău, indică adresa serverului la compilare:

```bash
cd frontend/car_manager

flutter build apk --release --dart-define=API_URL=https://api.domeniul-tau.ro
flutter build windows --release --dart-define=API_URL=https://api.domeniul-tau.ro
```

Fără `--dart-define`, aplicația se comportă ca înainte: caută backend-ul în
rețeaua locală. Cu el, se conectează direct la cloud, de oriunde.

---

## Operare curentă

```bash
docker compose logs -f backend     # jurnale în timp real
docker compose restart backend     # repornire
docker compose down                # oprire
git pull && docker compose up -d --build   # actualizare
```

### Copie de siguranță a bazei de date

```bash
docker compose exec -T db pg_dump -U carrecords carrecords \
  | gzip > backup_$(date +%F).sql.gz
```

Automatizează zilnic (`crontab -e`):
```
0 3 * * * cd /root/CarRecords/deploy && docker compose exec -T db pg_dump -U carrecords carrecords | gzip > /root/backups/db_$(date +\%F).sql.gz
```

### Restaurare

```bash
gunzip -c backup_2026-07-27.sql.gz | \
  docker compose exec -T db psql -U carrecords -d carrecords
```

---

## Mutarea datelor existente de pe PC

Datele actuale sunt în SQLite (`backend/carmanager.db`), iar serverul
folosește PostgreSQL — formatele nu sunt compatibile direct. Ai două opțiuni:

1. **Începi curat** (recomandat) — creezi conturile din nou pe server.
   Ai 8 utilizatori și 7 mașini, deci e rapid.
2. **Migrare** — se poate face cu `pgloader`, dar merită efortul doar dacă
   ai multe date de păstrat.

---

## Probleme frecvente

| Simptom | Cauză probabilă |
|---|---|
| Certificatul HTTPS nu se emite | DNS-ul încă nu s-a propagat, sau porturile 80/443 sunt blocate |
| `502 Bad Gateway` | Backend-ul nu a pornit — vezi `docker compose logs backend` |
| Aplicația spune „server negăsit" | A fost compilată fără `--dart-define=API_URL` |
| OCR nu extrage nimic | Verifică în container: `docker compose exec backend tesseract --list-langs` (trebuie să apară `ron`) |
