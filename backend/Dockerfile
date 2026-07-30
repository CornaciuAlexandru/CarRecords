# ── Imagine pentru backend-ul CarRecords ──────────────────────────
FROM python:3.12-slim

# Tesseract cu limba romana (necesar pentru OCR pe taloane/asigurari)
# + libpq pentru PostgreSQL
RUN apt-get update && apt-get install -y --no-install-recommends \
        tesseract-ocr \
        tesseract-ocr-ron \
        tesseract-ocr-eng \
        libpq5 \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Dependentele se instaleaza separat de cod, ca sa se refoloseasca
# stratul din cache cand se schimba doar codul.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY version.json ./version.json

# Rulam ca utilizator neprivilegiat
RUN useradd -m -u 1000 carrecords \
    && mkdir -p /app/uploads /app/downloads \
    && chown -R carrecords:carrecords /app
USER carrecords

ENV ENVIRONMENT=production \
    TESSERACT_PATH=/usr/bin/tesseract \
    UPLOAD_DIR=/app/uploads \
    PYTHONUNBUFFERED=1

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -fsS http://localhost:8000/health || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
