# Instalarea CarRecords pe un server în cloud

Rezultat: backend accesibil de oriunde, pe HTTPS, fără să mai fie nevoie ca
PC-ul tău să fie pornit.

---

## Ce îți trebuie înainte

| | Detaliu | Cost |
|---|---|---|
| **VPS** | Contabo **Cloud VPS** (min. 4 GB RAM), Ubuntu 24.04, locație Germania | ~5–7 €/lună |
| **Domeniu** | `carrecords.ro` — API-ul va sta pe `api.carrecords.ro` | 8,99 €/an |

> Instrucțiunile funcționează pe orice VPS cu Ubuntu și acces root
> (Contabo, Hetzner, DigitalOcean, OVH, ROMARG…). Singurele cerințe reale:
> minimum 2 GB RAM (OCR-ul cu Tesseract e partea solicitantă), IP public
> și locație în UE — datele personale rămân astfel sub jurisdicția GDPR
> fără formalități suplimentare.

---

## Pasul 1 — Îndreaptă domeniul spre server

În panoul registrarului de la care ai cumpărat `carrecords.ro`, la secțiunea
**DNS / Zone management**, sunt necesare trei înregistrări A către IP-ul
public al serverului:

```
Tip: A   Nume: @      -> IP-ul serverului     (carrecords.ro, site public)
Tip: A   Nume: www    -> IP-ul serverului     (www.carrecords.ro)
Tip: A   Nume: api    -> IP-ul serverului     (api.carrecords.ro)
```

Verifică propagarea (poate dura până la o oră):
```bash
for h in carrecords.ro www.carrecords.ro api.carrecords.ro; do echo -n "$h "; dig +short $h; done
```

Nu porni proxy-ul până când toate trei nu returnează IP-ul serverului.
Let's Encrypt nu poate emite certificatul altfel, iar Caddy va reîncerca în
buclă până se lovește de limita de cereri.

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
DOMAIN=api.carrecords.ro
POSTGRES_USER=carrecords
POSTGRES_DB=carrecords
POSTGRES_PASSWORD=<rezultatul din: openssl rand -hex 24>
SECRET_KEY=<rezultatul din: openssl rand -hex 32>
CORS_ORIGINS=*
PUBLIC_URL=https://api.carrecords.ro
SMTP_HOST=<serverul de mail>
SMTP_PORT=587
SMTP_USER=<utilizatorul SMTP>
SMTP_PASSWORD=<parola SMTP>
SMTP_FROM=CarRecords <noreply@carrecords.ro>
```

> **Fără `SMTP_HOST`, resetarea parolei nu funcționează.** Backend-ul nu dă
> eroare: scrie mesajele în `sent_emails.log`, în container, unde nu le vede
> nimeni. Orice serviciu SMTP e bun (Brevo, Mailgun, Resend, Zoho, sau
> serverul de mail al domeniului). `PUBLIC_URL` trebuie să fie adresa reală a
> API-ului — din ea se compun linkurile trimise pe email.

Generează cele două valori aleatoare direct pe server:
```bash
echo "POSTGRES_PASSWORD=$(openssl rand -hex 24)"
echo "SECRET_KEY=$(openssl rand -hex 32)"
```

---

## Pasul 5 — Pornește

HTTPS-ul e servit de un proxy comun întregii mașini, nu de stiva asta —
altfel două aplicații pe același server s-ar bate pe porturile 80 și 443.

```bash
# o singură dată pe server: rețeaua pe care proxy-ul găsește aplicațiile
docker network create web

# aplicația
docker compose --env-file .env up -d --build

# proxy-ul, care termină TLS pentru toate aplicațiile de pe mașină
cd proxy
cp .env.example .env && nano .env      # domenii și căile spre fișierele statice
docker compose --env-file .env up -d
```

Prima pornire durează ~5 minute (se compilează imaginea cu Tesseract).
Caddy obține automat certificatele HTTPS de la Let's Encrypt.

Înainte de a porni proxy-ul merită validată configurația — o greșeală de
sintaxă îl lasă în repornire continuă, cu toate aplicațiile căzute:

```bash
docker compose run --rm caddy caddy validate --config /etc/caddy/Caddyfile
```

Verifică:
```bash
curl https://api.carrecords.ro/health
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

flutter build apk --release --dart-define=API_URL=https://api.carrecords.ro
flutter build windows --release --dart-define=API_URL=https://api.carrecords.ro
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
| Nu ajung emailurile de resetare | `SMTP_HOST` nu e completat, sau furnizorul refuză autentificarea — vezi `docker compose logs backend` |
| Linkul din email duce la o adresă greșită | `PUBLIC_URL` nu e setat pe domeniul real |
| OCR nu extrage nimic | Verifică în container: `docker compose exec backend tesseract --list-langs` (trebuie să apară `ron`) |
