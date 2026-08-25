# CarManager - Gestionare Auto

Aplicatie cross-platform (Windows + Android) pentru gestionarea documentelor si datelor auto.

## Structura Proiect

```
CarManager/
├── backend/          ← FastAPI + SQLite/PostgreSQL
└── frontend/         ← Flutter (Windows + Android)
```

## Backend - Pornire Rapida

### 1. Instalare dependente
```bash
cd backend
pip install -r requirements.txt
pip install "pydantic[email]"
```

### 2. Configurare
```bash
copy .env.example .env
# Editeaza .env dupa necesitati
```

### 3. Creare cont admin
```bash
python create_admin.py
```

### 4. Pornire server
```bash
python run.py
# Serverul porneste pe http://localhost:8000
# Documentatie API: http://localhost:8000/docs
```

## API Endpoints

| Modul | Prefix |
|-------|--------|
| Autentificare | `/api/v1/auth` |
| Masini | `/api/v1/cars` |
| Roviniete | `/api/v1/cars/{id}/vignettes` |
| Asigurari | `/api/v1/cars/{id}/insurance` |
| Talon | `/api/v1/cars/{id}/registration` |
| Mentenanta | `/api/v1/cars/{id}/maintenance` |
| Modificari | `/api/v1/cars/{id}/modifications` |
| Notificari | `/api/v1/notifications` |
| Admin | `/api/v1/admin` |

## Emailuri (resetare parola, confirmarea adresei)

Fara `SMTP_HOST` in `backend/.env`, mesajele nu se trimit: se scriu in
`backend/sent_emails.log` si in consola. Linkurile din ele sunt valide, deci
fluxul complet se poate testa local, fara cont de mail.

Pentru trimitere reala:
```env
PUBLIC_URL=http://192.168.1.10:8000   # adresa la care ajung telefoanele
SMTP_HOST=smtp.exemplu.ro
SMTP_PORT=587
SMTP_USER=noreply@carrecords.ro
SMTP_PASSWORD=parola
```

`PUBLIC_URL` trebuie sa fie adresa la care serverul e vizibil pentru cel care
deschide emailul — din ea se construiesc linkurile.

## OCR - Scanare Documente

Pentru functia de scanare automata a documentelor este necesar **Tesseract OCR**:

1. Descarca de la: https://github.com/UB-Mannheim/tesseract/wiki
2. Instaleaza in `C:\Program Files\Tesseract-OCR\`
3. Descarca pachetul de limba romana: `ron.traineddata`
4. Copiaza in `C:\Program Files\Tesseract-OCR\tessdata\`

## Frontend Flutter - Instalare

1. Descarca Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Adauga in PATH: `C:\flutter\bin`
3. Ruleaza: `flutter doctor`
4. Creeaza proiectul: `cd frontend && flutter create car_manager`

## Baza de Date

Implicit: **SQLite** (fisier `backend/carmanager.db`) - ideal pentru development.

Pentru productie cu **PostgreSQL**:
```
DATABASE_URL=postgresql://user:password@localhost:5432/carmanager
```
