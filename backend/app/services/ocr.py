import re
from pathlib import Path
from typing import Optional
from PIL import Image, ImageEnhance, ImageFilter

try:
    import pytesseract
    from app.core.config import settings
    pytesseract.pytesseract.tesseract_cmd = settings.TESSERACT_PATH
    _available = pytesseract.get_languages(config='')
    OCR_LANG = 'ron+eng' if 'ron' in _available else 'eng'
    OCR_AVAILABLE = True
except Exception:
    OCR_AVAILABLE = False
    OCR_LANG = 'eng'


def _preprocess_image(image_path: Path) -> Image.Image:
    img = Image.open(image_path).convert("L")
    # Mareste imaginea pentru OCR mai bun
    w, h = img.size
    if w < 1000:
        img = img.resize((w * 2, h * 2), Image.LANCZOS)
    img = ImageEnhance.Contrast(img).enhance(2.5)
    img = ImageEnhance.Sharpness(img).enhance(2.0)
    img = img.filter(ImageFilter.SHARPEN)
    return img


def _extract_text(image_path: Path) -> str:
    if not OCR_AVAILABLE:
        return ""
    try:
        img = _preprocess_image(image_path)
        # Incercam cu configurare optimizata pentru documente
        config = '--oem 3 --psm 6'
        return pytesseract.image_to_string(img, lang=OCR_LANG, config=config)
    except Exception as e:
        return ""


def _find_date(text: str, patterns: list[str]) -> Optional[str]:
    """Cauta o data in contextul unui pattern, sau prima data din text."""
    date_re = r"\b(\d{1,2})[.\-/\s](\d{1,2})[.\-/\s](\d{4})\b"
    for pattern in patterns:
        block = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
        if block:
            found = re.search(date_re, block.group(0))
            if found:
                d, m, y = found.group(1).zfill(2), found.group(2).zfill(2), found.group(3)
                return f"{y}-{m}-{d}"
    # Fallback: prima data gasita in text
    all_dates = re.findall(date_re, text)
    if all_dates:
        d, m, y = all_dates[0]
        return f"{y}-{m.zfill(2)}-{d.zfill(2)}"
    return None


def _find_price(text: str) -> Optional[float]:
    # Cauta sume de bani: 28,50 RON / 28.50 / 1.250,00
    match = re.search(r"(\d{1,4}[.,]\d{2})\s*(RON|LEI|EUR|lei)?", text, re.IGNORECASE)
    if match:
        try:
            return float(match.group(1).replace(",", "."))
        except ValueError:
            pass
    return None


def _find_invoice_number(text: str) -> Optional[str]:
    match = re.search(
        r"(?:factur[aă]|nr\.?\s*factur[aă]|invoice|seria?|nr\.?)\s*[:\s]*([A-Z]{1,4}\s*\d{4,10})",
        text, re.IGNORECASE
    )
    return match.group(1).strip() if match else None


async def extract_vignette_data(image_path: Path) -> dict:
    text = _extract_text(image_path)

    # Firmă emitentă
    ROMANIAN_COMPANIES = ["CNAIR", "DRPCIV", "Roviniete", "roviniete.ro", "e-rovinieta"]
    company = next((c for c in ROMANIAN_COMPANIES if c.lower() in text.lower()), None)

    # Oras - pattern mai flexibil
    city_match = re.search(
        r"(?:ora[sș]|municipiul|localitatea|loc\.?|jude[tț]ul)\s*[:\s]*([A-ZĂÎȘȚ][a-zA-ZăîșțÂ\-]+)",
        text, re.IGNORECASE
    )

    # Perioada de valabilitate
    period = None
    if re.search(r"7\s*zile|7\s*days|saptam", text, re.IGNORECASE):
        period = "7_zile"
    elif re.search(r"30\s*zile|30\s*days|lunar|o\s*lun[aă]", text, re.IGNORECASE):
        period = "30_zile"
    elif re.search(r"90\s*zile|90\s*days|trimestri", text, re.IGNORECASE):
        period = "90_zile"
    elif re.search(r"1\s*an|12\s*luni|anual|1\s*year", text, re.IGNORECASE):
        period = "1_an"

    # Date cu pattern-uri mai largi
    purchase_date = _find_date(text, [
        r"(?:data|dat[aă])\s*(?:emiterii?|achiziti|cump[aă]r)",
        r"(?:emis[aă]?|issued)\s*(?:la|on|:)",
    ])
    valid_from = _find_date(text, [
        r"valabil[aă]?\s*(?:de la|din|from|start)",
        r"(?:start|inceput|de la)\s*(?:dat[aă]|date)?",
    ])
    valid_until = _find_date(text, [
        r"(?:expir[aă]|valid[aă]?\s*p[aâ]n[aă]|until|end|sfar[sș]it)",
        r"(?:p[aâ]n[aă]\s*la|valabil[aă]?\s*p[aâ]n[aă])",
    ])

    return {
        "purchase_date": purchase_date,
        "valid_from": valid_from,
        "valid_until": valid_until,
        "validity_period": period,
        "issuer_company": company,
        "city": city_match.group(1) if city_match else None,
        "price": _find_price(text),
        "invoice_number": _find_invoice_number(text),
        "ocr_raw_text": text[:500] if text else "",  # primele 500 caractere pentru debug
    }


async def extract_insurance_data(image_path: Path) -> dict:
    text = _extract_text(image_path)

    INSURERS = [
        "Allianz", "ASIROM", "Generali", "Omniasig", "Groupama",
        "UNIQA", "Gothaer", "Grawe", "Signal Iduna", "AXA", "Ergo", "Euroins"
    ]
    insurer = next((c for c in INSURERS if c.lower() in text.lower()), None)

    # Numar polita
    policy_match = re.search(
        r"(?:poli[tț][aă]|contract|nr\.?\s*poli[tț][aă]|polita nr|nr\.?)\s*[:\s]*([A-Z0-9]{3,}[\-/]?[A-Z0-9]+)",
        text, re.IGNORECASE
    )

    # Tip asigurare
    ins_type = None
    if re.search(r"\bRCA\b", text, re.IGNORECASE):
        ins_type = "RCA"
    elif re.search(r"\bCASCO\b", text, re.IGNORECASE):
        ins_type = "CASCO"

    valid_from = _find_date(text, [
        r"(?:valabil[aă]?\s*(?:de la|din|from)|inceput\s*(?:valabilitate|asigurare))",
        r"(?:start|de la|from)\s*(?:dat[aă]|date)?",
    ])
    valid_until = _find_date(text, [
        r"(?:expir[aă]|valabil[aă]?\s*p[aâ]n[aă]|sfar[sș]it\s*valabilitate|until|end)",
        r"(?:p[aâ]n[aă]\s*la|data\s*expir)",
    ])

    return {
        "type": ins_type,
        "policy_number": policy_match.group(1).strip() if policy_match else None,
        "insurer_company": insurer,
        "valid_from": valid_from,
        "valid_until": valid_until,
        "premium_amount": _find_price(text),
        "ocr_raw_text": text[:500] if text else "",
    }


def _parse_date_str(s: str) -> Optional[str]:
    """Converteste un string de tip dd.mm.yyyy sau dd/mm/yyyy in yyyy-mm-dd."""
    m = re.search(r"(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{4})", s)
    if m:
        return f"{m.group(3)}-{m.group(2).zfill(2)}-{m.group(1).zfill(2)}"
    return None


def _field(text: str, *codes: str, max_len: int = 60) -> Optional[str]:
    """
    Extrage valoarea campului de dupa un cod de talon (ex: 'D.1', 'C.2.2').
    Tolereaza OCR-ul care omite punctele sau adauga spatii: D1, D 1, D.1, D .1 etc.
    Returneaza primul rand non-gol de dupa cod, trunchiat la max_len.
    """
    for code in codes:
        # Construieste pattern flexibil: D.1 => D\.?\s*1, C.2.2 => C\.?\s*2\.?\s*2
        parts = re.split(r'\.', code)
        pat_code = r'\.?\s*'.join(re.escape(p) for p in parts)
        pattern = rf"(?:^|\n)\s*{pat_code}\s*[:\-\s]{{0,3}}(.{{1,{max_len}}})"
        m = re.search(pattern, text, re.IGNORECASE | re.MULTILINE)
        if m:
            val = m.group(1).strip().split('\n')[0].strip()
            val = re.sub(r'\s+', ' ', val)
            if val:
                return val
    return None


def _field_date(text: str, *codes: str) -> Optional[str]:
    """Extrage si parseaza o data de dupa un cod de talon."""
    raw = _field(text, *codes, max_len=20)
    if raw:
        return _parse_date_str(raw)
    return None


async def extract_registration_data(image_path: Path) -> dict:
    """
    Extrage date din talonul de inmatriculare romanesc (Certificat de Inmatriculare).
    Coduri campuri conform standardului UE (Directiva 1999/37/CE):
      A     = Numarul de inmatriculare
      B     = Data primei inmatriculari (ziua, luna, anul)
      C.2.2 = Numele proprietarului
      C.2.3 = Adresa proprietarului
      D.1   = Marca vehiculului
      D.3   = Variantă / Versiune (model comercial)
      E     = Numarul de identificare al vehiculului (VIN / serie sasiu)
      I     = Data inmatricularii care face obiectul certificatului
      X     = Data expirare ITP
    """
    # Incercam doua moduri PSM pentru maxim acuratete
    if not OCR_AVAILABLE:
        return {"ocr_raw_text": ""}

    text = ""
    try:
        img = _preprocess_image(image_path)
        # PSM 6 = bloc uniform de text; PSM 4 = coloana variabila — talonul are layout in coloane
        for psm in (6, 4):
            t = pytesseract.image_to_string(
                img, lang=OCR_LANG,
                config=f'--oem 3 --psm {psm}'
            )
            if len(t) > len(text):
                text = t
    except Exception:
        return {"ocr_raw_text": ""}

    # ── A: Numar de inmatriculare ─────────────────────────────────────────
    registration_number = None
    # Prioritate: valoarea de dupa eticheta "A"
    raw_a = _field(text, 'A', max_len=15)
    if raw_a:
        m_plate = re.search(r"([A-Z]{1,2}[\s\-]?\d{2,3}[\s\-]?[A-Z]{3})", raw_a)
        if m_plate:
            registration_number = m_plate.group(1).replace(" ", "").replace("-", "")
    # Fallback: format pluta româneasca oriunde in text
    if not registration_number:
        m_plate = re.search(r"\b([A-Z]{1,2}[\-\s]?\d{2,3}[\-\s]?[A-Z]{3})\b", text)
        if m_plate:
            registration_number = m_plate.group(1).replace(" ", "").replace("-", "")

    # ── B: Data primei inmatriculari → extragem ANUL ca an de fabricatie ──
    manufacturing_year = None
    raw_b = _field(text, 'B', max_len=15)
    if raw_b:
        m_yr = re.search(r"\b(19[5-9]\d|20[0-3]\d)\b", raw_b)
        if m_yr:
            manufacturing_year = m_yr.group(1)
    # Fallback: pattern explicit in text
    if not manufacturing_year:
        m_yr = re.search(
            r"(?:prima\s+[iî]nmatriculare|first\s+reg(?:istration)?)[^\d]*(\d{1,2}[./]\d{1,2}[./])(\d{4})",
            text, re.IGNORECASE)
        if m_yr:
            manufacturing_year = m_yr.group(2)

    # ── C.2.2: Numele proprietarului ──────────────────────────────────────
    owner_name = None
    raw_c22 = _field(text, 'C.2.2', 'C22', 'C 2 2', max_len=60)
    if raw_c22:
        # Filtram cifre si caractere care nu apartin unui nume
        candidate = re.sub(r'[^A-ZĂÎȘȚA-Za-zăîșț\s\-]', '', raw_c22).strip()
        if len(candidate) > 3:
            owner_name = candidate
    # Fallback: cauta "proprietar / titular" in text
    if not owner_name:
        for pat in [
            r"(?:proprietar|titular|detinator)\s*[:\s]+([A-ZĂÎȘȚ][A-ZĂÎȘȚ\s\-]{4,50})",
            r"C\.?\s*1\s*[:\-\s]+([A-ZĂÎȘȚ][A-ZĂÎȘȚ\s\-]{4,50})",
        ]:
            m = re.search(pat, text, re.IGNORECASE)
            if m:
                candidate = m.group(1).strip()
                skip = {"ROMANIA", "CERTIFICAT", "INMATRICULARE", "MINISTERUL",
                        "TRANSPORTURI", "DRPCIV", "POLITIA", "CATEGORIA", "MARCA"}
                if candidate.split()[0].upper() not in skip:
                    owner_name = candidate
                    break

    # ── C.2.3: Adresa proprietarului ──────────────────────────────────────
    owner_address = None
    raw_c23 = _field(text, 'C.2.3', 'C23', 'C 2 3', max_len=120)
    if raw_c23:
        owner_address = raw_c23.strip()

    # ── D.1: Marca ────────────────────────────────────────────────────────
    brand = None
    raw_d1 = _field(text, 'D.1', 'D1', 'D 1', max_len=30)
    if raw_d1:
        brand = raw_d1.strip().split()[0]  # primul cuvant = marca
    # Fallback: marci cunoscute
    if not brand:
        known_brands = [
            "DACIA", "VOLKSWAGEN", "RENAULT", "FORD", "TOYOTA", "BMW", "MERCEDES-BENZ",
            "MERCEDES", "AUDI", "OPEL", "SKODA", "HYUNDAI", "KIA", "FIAT", "PEUGEOT",
            "CITROEN", "SEAT", "HONDA", "MAZDA", "VOLVO", "NISSAN", "SUZUKI",
            "MITSUBISHI", "JEEP", "LAND ROVER", "PORSCHE", "TESLA", "ALFA ROMEO",
        ]
        text_upper = text.upper()
        for b in known_brands:
            if b in text_upper:
                brand = b
                break

    # ── D.3: Varianta / Model comercial ───────────────────────────────────
    model = None
    raw_d3 = _field(text, 'D.3', 'D3', 'D 3', max_len=40)
    if raw_d3:
        model = raw_d3.strip().split('\n')[0].strip()
    # Fallback: D.2 sau câmpul "type/typ/tipo"
    if not model:
        raw_d2 = _field(text, 'D.2', 'D2', 'D 2', max_len=40)
        if raw_d2:
            model = raw_d2.strip()

    # ── E: VIN / Serie de sasiu (17 caractere alfanumerice) ───────────────
    car_series = None
    raw_e = _field(text, 'E', max_len=25)
    if raw_e:
        m_vin = re.search(r"[A-HJ-NPR-Z0-9]{17}", raw_e.upper())
        if m_vin:
            car_series = m_vin.group(0)
    # Fallback: VIN oriunde in text
    if not car_series:
        m_vin = re.search(r"\b([A-HJ-NPR-Z0-9]{17})\b", text.upper())
        if m_vin:
            car_series = m_vin.group(1)

    # ── I: Data inmatricularii in Romania ─────────────────────────────────
    registration_date = _field_date(text, 'I')
    if not registration_date:
        registration_date = _find_date(text, [
            r"(?:data\s*[iî]nmatricul[aă]rii?|inregistr[aă]rii?)",
        ])

    # ── X: Data expirare ITP ──────────────────────────────────────────────
    itp_expiry_date = _field_date(text, 'X')
    if not itp_expiry_date:
        # Fallback: cauta "ITP" urmat de o data
        m_itp = re.search(
            r"(?:ITP|inspec[tț]ie\s*tehnic[aă])\s*[:\s]*(\d{1,2}[.\-/]\d{1,2}[.\-/]\d{4})",
            text, re.IGNORECASE
        )
        if m_itp:
            itp_expiry_date = _parse_date_str(m_itp.group(1))

    return {
        "owner_name": owner_name,
        "owner_address": owner_address,
        "itp_expiry_date": itp_expiry_date,
        "registration_date": registration_date,
        "registration_number": registration_number,
        "car_series": car_series,
        "brand": brand,
        "model": model,
        "manufacturing_year": manufacturing_year,
        "ocr_raw_text": text[:800] if text else "",
    }
