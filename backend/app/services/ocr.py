"""
Serviciu OCR pentru documente auto romanesti (talon, rovinieta, asigurare).

Pipeline:
  1. Corectie orientare EXIF + detectie rotatie (testeaza 0/90/180/270 pe o
     versiune mica a imaginii si alege rotatia cu cele mai multe cuvinte lizibile)
  2. Preprocesare: upscale, autocontrast, sharpen + varianta binarizata (Otsu)
  3. OCR multi-pass (PSM 4 si 6, gri si binarizat)
  4. Pentru talon: parsare pe linii dupa codurile UE (A, B, D.1, C.2.2, ...)
     si alegerea trecerii care extrage cele mai multe campuri; campurile lipsa
     se completeaza din celelalte treceri.
"""
import re
from pathlib import Path
from typing import Optional
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

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


# ═══════════════════════════════════════════════════════════════════
#  Incarcarea si preprocesarea imaginii
# ═══════════════════════════════════════════════════════════════════

def _load_image(image_path: Path) -> Image.Image:
    """Deschide imaginea, aplica orientarea EXIF (pozele de pe telefon) si
    converteste la grayscale."""
    img = Image.open(image_path)
    img = ImageOps.exif_transpose(img)
    return img.convert("L")


def _enhance(img: Image.Image) -> Image.Image:
    """Upscale + contrast + sharpen — versiunea 'gri' pentru OCR."""
    w, h = img.size
    if max(w, h) < 1800:
        scale = 1800 / max(w, h)
        img = img.resize((int(w * scale), int(h * scale)), Image.LANCZOS)
    img = ImageOps.autocontrast(img, cutoff=1)
    img = ImageEnhance.Sharpness(img).enhance(1.8)
    img = img.filter(ImageFilter.MedianFilter(size=3))
    return img


def _otsu_binarize(img: Image.Image) -> Image.Image:
    """Binarizare cu prag Otsu (calculat din histograma, fara numpy)."""
    hist = img.histogram()
    total = sum(hist)
    if total == 0:
        return img
    sum_all = sum(i * hist[i] for i in range(256))
    sum_bg, w_bg, max_var, threshold = 0.0, 0, 0.0, 127
    for t in range(256):
        w_bg += hist[t]
        if w_bg == 0:
            continue
        w_fg = total - w_bg
        if w_fg == 0:
            break
        sum_bg += t * hist[t]
        mean_bg = sum_bg / w_bg
        mean_fg = (sum_all - sum_bg) / w_fg
        var = w_bg * w_fg * (mean_bg - mean_fg) ** 2
        if var > max_var:
            max_var, threshold = var, t
    return img.point(lambda p: 255 if p > threshold else 0)


def _ocr(img: Image.Image, psm: int) -> str:
    try:
        return pytesseract.image_to_string(
            img, lang=OCR_LANG, config=f'--oem 3 --psm {psm}'
        )
    except Exception:
        return ""


def _detect_rotation(img: Image.Image) -> int:
    """Detecteaza rotatia corecta testand toate cele 4 orientari pe o versiune
    mica a imaginii. Scor = numarul de cuvinte lizibile (text rotit produce
    gibberish scurt)."""
    small = img.copy()
    small.thumbnail((1000, 1000), Image.LANCZOS)
    small = ImageOps.autocontrast(small, cutoff=1)

    best_rot, best_score = 0, -1
    for rot in (0, 90, 180, 270):
        rotated = small.rotate(rot, expand=True) if rot else small
        text = _ocr(rotated, psm=6)
        # cuvinte de minim 3 caractere alfanumerice = semnal de text real
        score = len(re.findall(r'[A-Za-z0-9ĂÎȘȚÂăîșțâ]{3,}', text))
        if score > best_score:
            best_rot, best_score = rot, score
    return best_rot


def _text_variants(image_path: Path, psms=(4, 6)) -> list[str]:
    """Returneaza mai multe variante de text OCR (orientare corectata,
    gri + binarizat, mai multe moduri PSM)."""
    if not OCR_AVAILABLE:
        return []
    try:
        img = _load_image(image_path)
    except Exception:
        return []

    rot = _detect_rotation(img)
    if rot:
        img = img.rotate(rot, expand=True)

    enhanced = _enhance(img)
    binary = _otsu_binarize(enhanced)

    variants = []
    for variant in (enhanced, binary):
        for psm in psms:
            text = _ocr(variant, psm)
            if text.strip():
                variants.append(text)
    return variants


def _extract_text(image_path: Path) -> str:
    """Text combinat din toate variantele — pentru cautari regex simple
    (rovinieta, asigurare)."""
    return "\n".join(_text_variants(image_path))


# ═══════════════════════════════════════════════════════════════════
#  Helpers comune
# ═══════════════════════════════════════════════════════════════════

def _parse_date_str(s: str) -> Optional[str]:
    """dd.mm.yyyy / dd-mm-yyyy / dd/mm/yyyy → yyyy-mm-dd (cu validare)."""
    m = re.search(r"(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{4})", s)
    if not m:
        return None
    d, mo, y = int(m.group(1)), int(m.group(2)), int(m.group(3))
    if not (1 <= d <= 31 and 1 <= mo <= 12 and 1950 <= y <= 2050):
        return None
    return f"{y}-{mo:02d}-{d:02d}"


def _find_date(text: str, patterns: list[str]) -> Optional[str]:
    date_re = r"\b(\d{1,2})[.\-/\s](\d{1,2})[.\-/\s](\d{4})\b"
    for pattern in patterns:
        block = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
        if block:
            found = re.search(date_re, block.group(0))
            if found:
                d, m, y = found.group(1).zfill(2), found.group(2).zfill(2), found.group(3)
                return f"{y}-{m}-{d}"
    all_dates = re.findall(date_re, text)
    if all_dates:
        d, m, y = all_dates[0]
        return f"{y}-{m.zfill(2)}-{d.zfill(2)}"
    return None


def _find_price(text: str) -> Optional[float]:
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


# ═══════════════════════════════════════════════════════════════════
#  Rovinieta
# ═══════════════════════════════════════════════════════════════════

async def extract_vignette_data(image_path: Path) -> dict:
    text = _extract_text(image_path)

    ROMANIAN_COMPANIES = ["CNAIR", "DRPCIV", "Roviniete", "roviniete.ro", "e-rovinieta"]
    company = next((c for c in ROMANIAN_COMPANIES if c.lower() in text.lower()), None)

    city_match = re.search(
        r"(?:ora[sș]|municipiul|localitatea|loc\.?|jude[tț]ul)\s*[:\s]*([A-ZĂÎȘȚ][a-zA-ZăîșțÂ\-]+)",
        text, re.IGNORECASE
    )

    period = None
    if re.search(r"7\s*zile|7\s*days|saptam", text, re.IGNORECASE):
        period = "7_zile"
    elif re.search(r"30\s*zile|30\s*days|lunar|o\s*lun[aă]", text, re.IGNORECASE):
        period = "30_zile"
    elif re.search(r"90\s*zile|90\s*days|trimestri", text, re.IGNORECASE):
        period = "90_zile"
    elif re.search(r"1\s*an|12\s*luni|anual|1\s*year", text, re.IGNORECASE):
        period = "1_an"

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
        "ocr_raw_text": text[:500] if text else "",
    }


# ═══════════════════════════════════════════════════════════════════
#  Asigurare
# ═══════════════════════════════════════════════════════════════════

async def extract_insurance_data(image_path: Path) -> dict:
    text = _extract_text(image_path)

    INSURERS = [
        "Allianz", "ASIROM", "Generali", "Omniasig", "Groupama",
        "UNIQA", "Gothaer", "Grawe", "Signal Iduna", "AXA", "Ergo", "Euroins"
    ]
    insurer = next((c for c in INSURERS if c.lower() in text.lower()), None)

    policy_match = re.search(
        r"(?:poli[tț][aă]|contract|nr\.?\s*poli[tț][aă]|polita nr|nr\.?)\s*[:\s]*([A-Z0-9]{3,}[\-/]?[A-Z0-9]+)",
        text, re.IGNORECASE
    )

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


# ═══════════════════════════════════════════════════════════════════
#  Talon (Certificat de Inmatriculare) — parsare pe coduri UE
# ═══════════════════════════════════════════════════════════════════
#  A     = Numar de inmatriculare        I / I.1 = Data inmatricularii
#  B     = Data primei inmatriculari     X       = Data expirare ITP
#  C.2.1 = Nume proprietar               D.1     = Marca
#  C.2.2 = Prenume proprietar            D.3     = Model (varianta comerciala)
#  C.2.3 = Adresa proprietar             E       = VIN / serie sasiu
# ═══════════════════════════════════════════════════════════════════

# Codurile de camp, cele compuse primele (matching longest-first)
_TALON_CODES = [
    "C21", "C22", "C23", "C31", "C32", "C33", "C2", "C3",
    "D1", "D2", "D3", "F1", "F2", "F3", "I1", "P1", "P2", "P3",
    "S1", "S2", "L1",
    "A", "B", "E", "G", "H", "I", "J", "K", "Q", "R", "X", "Y", "Z",
]

def _code_regex(code: str) -> str:
    """'C21' → regex tolerant la puncte/virgule/spatii: C[.,]?\\s?2[.,]?\\s?1"""
    parts = list(code)
    return r"[.,]?\s?".join(re.escape(p) for p in parts)

_CODE_ALT = "|".join(_code_regex(c) for c in _TALON_CODES)

# Cod la inceput de linie, precedat optional de gunoi OCR (=|, ©., etc.)
_LINE_RE = re.compile(
    r"^\s*(?:[^A-Za-z0-9\s]\s*){0,3}(" + _CODE_ALT + r")"
    r"(?![A-Za-z0-9])[\s:.\-–,)\]]*(.*)$"
)

# Cod incorporat in mijlocul unei linii: " F1 1936", " G 1385" etc.
_EMBED_RE = re.compile(
    r"\s[(\[{]?(" + _CODE_ALT + r")(?![A-Za-z0-9])[\s:.\-–,)\]]"
)

_DATE_RE = re.compile(r"\b\d{1,2}[.\-/]\d{1,2}[.\-/]\d{4}\b")

_KNOWN_BRANDS = [
    "DACIA", "VOLKSWAGEN", "RENAULT", "FORD", "TOYOTA", "BMW", "MERCEDES-BENZ",
    "MERCEDES", "AUDI", "OPEL", "SKODA", "HYUNDAI", "KIA", "FIAT", "PEUGEOT",
    "CITROEN", "SEAT", "HONDA", "MAZDA", "VOLVO", "NISSAN", "SUZUKI",
    "MITSUBISHI", "JEEP", "LAND ROVER", "PORSCHE", "TESLA", "ALFA ROMEO",
    "CHEVROLET", "MINI", "SMART", "LEXUS", "SUBARU", "DAEWOO", "LADA",
]


def _canon_code(raw: str) -> str:
    """'C.2.2' / 'C,2 2' → 'C22'"""
    return re.sub(r"[^A-Z0-9]", "", raw.upper())


def _clean_value(v: str) -> str:
    """Curata valoarea de gunoi de tabel: taie la separatori de coloana,
    normalizeaza spatiile."""
    v = re.split(r"[|{}\[\]]", v)[0]          # separatori de tabel/coloana
    v = re.split(r"\s{3,}", v)[0]             # gap mare = coloana vecina
    v = re.sub(r"\s+", " ", v).strip(" .,:;-_'\"")
    return v


def _match_line_code(line: str):
    """Incearca sa gaseasca un cod la inceputul liniei; daca esueaza,
    arunca primul token scurt (gunoi OCR de tip 'Să', 'SE') si reincearca."""
    m = _LINE_RE.match(line)
    if m:
        return m
    tokens = line.split(None, 1)
    if len(tokens) == 2 and len(tokens[0]) <= 3:
        return _LINE_RE.match(tokens[1])
    return None


def _store_segment(fields: dict, code: str, value: str):
    """Salveaza valoarea unui cod, despartind codurile incorporate in ea:
    'D1 RENAULT F1 1936 G 1385' → D1=RENAULT, F1=1936, G=1385."""
    for _ in range(6):
        # Valoarea incepe direct cu alt cod? (ex: 'C.2) C.2.1 MITROI')
        m_start = _LINE_RE.match(value)
        if m_start and not fields.get(code):
            code, value = _canon_code(m_start.group(1)), m_start.group(2).strip()
            continue
        # Cod incorporat mai tarziu in valoare → despartim
        m_embed = _EMBED_RE.search(" " + value)
        if m_embed:
            head = value[:max(0, m_embed.start())].strip()
            cleaned = _clean_value(head)
            if cleaned and code not in fields:
                fields[code] = cleaned
            rest = (" " + value)[m_embed.start():].strip()
            m_next = _LINE_RE.match(rest)
            if not m_next:
                return
            code, value = _canon_code(m_next.group(1)), m_next.group(2).strip()
            continue
        cleaned = _clean_value(value)
        if cleaned and code not in fields:
            fields[code] = cleaned
        return


def _parse_talon_fields(text: str) -> dict:
    """Parseaza textul OCR linie cu linie si returneaza {cod: valoare}."""
    fields: dict[str, str] = {}
    lines = [ln.strip() for ln in text.splitlines()]

    for idx, line in enumerate(lines):
        if not line:
            continue

        matched_code = None
        m = _match_line_code(line)
        if m:
            matched_code = _canon_code(m.group(1))
            _store_segment(fields, matched_code, m.group(2).strip())

            # Adresa (C.2.3) poate continua pe linia urmatoare:
            # 'C23 Str. CARPINIS Nr. 12 OCNELE' / 'MARI Jud. VÂLCEA'
            if matched_code == "C23" and idx + 1 < len(lines):
                nxt = lines[idx + 1]
                if nxt and not _match_line_code(nxt) and re.match(
                        r"^(?:[A-ZĂÎȘȚÂ]{2,}|mun\.|jud\.|com\.|sat\b|str\.|bl\.|sc\.|ap\.|nr\.)",
                        nxt, re.IGNORECASE):
                    extra = _clean_address(nxt)
                    if extra and "C23" in fields:
                        fields["C23"] = f"{fields['C23']} {extra}"

        # Heuristica pentru I / I.1 cand litera I e citita ca '|', '1', 'l':
        # o linie cu >= 2 date calendaristice = data inmatricularii (I si I.1)
        if matched_code != "B":
            dates = [d for d in _DATE_RE.findall(line) if _parse_date_str(d)]
            if len(dates) >= 2:
                fields.setdefault("I", dates[0])
                fields.setdefault("I1", dates[1])

    return fields


def _clean_address(value: str) -> str:
    """Taie adresa la primul token care contine 3+ cifre consecutive
    (specificatii anvelope '215/55R16' etc. din coloana vecina)."""
    tokens = []
    for tok in value.split():
        if re.search(r"\d{3,}", tok):
            break
        tokens.append(tok)
    return _clean_value(" ".join(tokens))


def _score_fields(fields: dict) -> int:
    """Scor de calitate: cate campuri UTILE a extras aceasta trecere."""
    important = {"A", "B", "E", "I", "I1", "X", "D1", "D3", "C21", "C22", "C23"}
    return sum(3 if c in important else 1 for c in fields)


# Placuta romaneasca: judet = 2 litere sau doar 'B' (Bucuresti).
# Folosim lookaround manual (nu \b) pentru ca '_' din gunoiul OCR e word-char.
_PLATE_RE = re.compile(
    r"(?<![A-Z0-9])(B|[A-Z]{2})[\s\-_]{0,3}(\d{2,3})[\s\-_]{0,3}([A-Z]{3})(?![A-Z0-9])"
)

def _extract_plate(value: str) -> Optional[str]:
    m = _PLATE_RE.search(value.upper())
    return f"{m.group(1)}{m.group(2)}{m.group(3)}" if m else None


def _majority_plate(texts: list[str]) -> Optional[str]:
    """Voteaza placuta cea mai frecventa din toate variantele OCR —
    aparitiile multiple (talonul o contine de 2 ori) corecteaza erorile."""
    from collections import Counter
    votes = Counter()
    for t in texts:
        for m in _PLATE_RE.finditer(t.upper()):
            votes[f"{m.group(1)}{m.group(2)}{m.group(3)}"] += 1
    return votes.most_common(1)[0][0] if votes else None


def _extract_vin(value: str) -> Optional[str]:
    """Extrage un VIN de 17 caractere. VIN-urile nu contin I, O, Q — deci
    aparitia lor intr-un candidat e artefact OCR si se substituie (I→1, O→0)."""
    compact = re.sub(r"[\s\-]", "", value.upper())
    compact = compact.replace("I", "1").replace("O", "0").replace("Q", "0")
    m = re.search(r"[A-HJ-NPR-Z0-9]{17}", compact)
    return m.group(0) if m else None


def _find_vin_in_text(text: str) -> Optional[str]:
    """Cauta un VIN in text, doar in tokeni individuali sau perechi adiacente
    (nu comprima linii intregi — ar produce false pozitive)."""
    for line in text.splitlines():
        tokens = line.split()
        candidates = [t for t in tokens if 15 <= len(t) <= 19]
        # VIN rupt in doua de OCR: 'VF1BT1RG64822' + '2399'
        for a, b in zip(tokens, tokens[1:]):
            if 15 <= len(a) + len(b) <= 19:
                candidates.append(a + b)
        for cand in candidates:
            vin = _extract_vin(cand)
            if vin:
                return vin
    return None


# Cuvinte care apartin altor sectiuni ale talonului — daca apar intr-un nume,
# inseamna ca OCR-ul a lipit coloana vecina; taiem acolo.
_NAME_STOPWORDS = ("SRPCIV", "OBSERV", "CERTIFICAT", "INMATRICUL", "SPECIMEN",
                   "ANEXA", "DRPCIV", "INSPEC")

def _clean_name(value: str) -> Optional[str]:
    """Pastreaza doar tokeni plauzibili de nume (litere/diacritice, min 2 chr);
    se opreste la primul token cu cifre sau cuvant din alta sectiune."""
    tokens = []
    for t in re.split(r"\s+", value):
        up = t.upper()
        if any(sw in up for sw in _NAME_STOPWORDS) or re.search(r"\d", t):
            break
        if len(t) >= 2 and re.fullmatch(r"[A-Za-zĂÎȘȚÂăîșțâ\-]+", t):
            tokens.append(t)
    return " ".join(tokens).upper() if tokens else None


async def extract_registration_data(image_path: Path) -> dict:
    variants = _text_variants(image_path, psms=(4, 6))
    if not variants:
        return {"ocr_raw_text": ""}

    # Parsam fiecare varianta si le ordonam dupa scor
    parsed = sorted(
        ((_parse_talon_fields(t), t) for t in variants),
        key=lambda pt: _score_fields(pt[0]),
        reverse=True,
    )
    # Varianta cu cel mai bun scor e baza; completam lipsurile din celelalte
    fields = dict(parsed[0][0])
    for extra, _ in parsed[1:]:
        for code, val in extra.items():
            fields.setdefault(code, val)
    full_text = "\n".join(t for _, t in parsed)

    # ── A: numar de inmatriculare (vot majoritar intre variante) ──
    registration_number = _majority_plate([t for _, t in parsed])
    if not registration_number and "A" in fields:
        registration_number = _extract_plate(fields["A"])

    # ── B: prima inmatriculare → anul fabricatiei ────────────────
    manufacturing_year = None
    if "B" in fields:
        d = _parse_date_str(fields["B"])
        if d:
            manufacturing_year = d[:4]
        else:
            m = re.search(r"\b(19[5-9]\d|20[0-4]\d)\b", fields["B"])
            if m:
                manufacturing_year = m.group(1)
    if not manufacturing_year:
        # Fallback: cea mai veche data valida din document
        # (prima inmatriculare precede orice alta data de pe talon)
        years = [int(_parse_date_str(d)[:4]) for d in _DATE_RE.findall(full_text)
                 if _parse_date_str(d)]
        if years:
            manufacturing_year = str(min(years))

    # ── I / I.1: data inmatricularii ─────────────────────────────
    registration_date = None
    for code in ("I", "I1"):
        if code in fields:
            registration_date = _parse_date_str(fields[code])
            if registration_date:
                break

    # ── X: data expirare ITP ─────────────────────────────────────
    itp_expiry_date = _parse_date_str(fields.get("X", ""))
    if not itp_expiry_date:
        m = re.search(
            r"(?:ITP|inspec[tț]ie\s*tehnic[aă])[\s:]*(\d{1,2}[.\-/]\d{1,2}[.\-/]\d{4})",
            full_text, re.IGNORECASE)
        if m:
            itp_expiry_date = _parse_date_str(m.group(1))

    # ── D.1: marca ────────────────────────────────────────────────
    brand = None
    if "D1" in fields:
        candidate = fields["D1"].upper()
        brand = next((b for b in _KNOWN_BRANDS if b in candidate), None)
        if not brand:
            first = candidate.split()[0] if candidate.split() else ""
            if re.fullmatch(r"[A-Z\-]{3,}", first):
                brand = first
    if not brand:
        upper_text = full_text.upper()
        brand = next((b for b in _KNOWN_BRANDS if b in upper_text), None)

    # ── D.3: model — pastram doar sirul initial de tokeni MAJUSCULE
    # ('LAGUNA ps MOTORINA _} Q' → 'LAGUNA'; 'LAND CRUISER' ramane intreg)
    model = None
    if "D3" in fields:
        tokens = []
        for tok in _clean_value(fields["D3"]).split():
            if re.fullmatch(r"[A-Z0-9ĂÎȘȚÂ\-]{2,}", tok):
                tokens.append(tok)
            else:
                break
        if tokens and not "".join(tokens).isdigit():
            model = " ".join(tokens)

    # ── E: VIN / serie sasiu (vot majoritar intre variante) ──────
    from collections import Counter
    vin_votes = Counter()
    for var_fields, var_text in parsed:
        vin = _extract_vin(var_fields["E"]) if "E" in var_fields else None
        if not vin:
            vin = _find_vin_in_text(var_text)
        if vin:
            vin_votes[vin] += 1
    car_series = vin_votes.most_common(1)[0][0] if vin_votes else None

    # ── C.2.1 + C.2.2: nume + prenume proprietar ─────────────────
    surname = _clean_name(fields.get("C21", "")) if "C21" in fields else None
    firstname = _clean_name(fields.get("C22", "")) if "C22" in fields else None
    owner_name = " ".join(p for p in (surname, firstname) if p) or None

    # ── C.2.3: adresa proprietar (curatata de specificatii anvelope) ─
    owner_address = _clean_address(fields["C23"]) if "C23" in fields else None
    if owner_address and len(owner_address) < 4:
        owner_address = None

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
        "ocr_raw_text": full_text[:800],
    }
