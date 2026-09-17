"""Citirea rovinietei.

Ca si la talon, testul isi genereaza singur documentul: o dovada de plata cu
formularea si asezarea celor emise in Romania. Fara fisiere binare in repo si
fara date reale.

Campurile astea patru - orasul, emitentul, seria si numarul - ieseau gresite
sau deloc. Fiecare are aici cazul lui.
"""
import asyncio

import pytest
from PIL import Image, ImageDraw, ImageFilter, ImageFont

from app.services import ocr

pytestmark = pytest.mark.skipif(not ocr.OCR_AVAILABLE, reason="Tesseract nu e instalat")

DOCUMENT = [
    "ROVINIETA",
    "Dovada platii tarifului de utilizare",
    "a retelei de drumuri nationale din Romania",
    "",
    "Seria: RO   Nr.: 12345678",
    "Nr. inmatriculare: VL 12 ABC",
    "Tip vehicul: B",
    "",
    "Valabilitate: 01.07.2026 - 01.07.2027",
    "Data emiterii: 01.07.2026",
    "",
    "Emitent: C.N.A.I.R. S.A.",
    "Punct de emitere: OMV Ramnicu Valcea",
    "Tarif: 138,50 RON",
]


def _font(size=30):
    for path in ("C:/Windows/Fonts/arial.ttf",
                 "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
                 "/usr/share/fonts/dejavu/DejaVuSans.ttf"):
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    pytest.skip("niciun font TrueType disponibil")


@pytest.fixture(scope="module")
def vignette_photo(tmp_path_factory):
    font = _font()
    img = Image.new("L", (1200, 900), 240)
    draw = ImageDraw.Draw(img)
    y = 40
    for line in DOCUMENT:
        draw.text((60, y), line, font=font, fill=25)
        y += 55
    img = img.resize((2400, 1800), Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.7))
    out = tmp_path_factory.mktemp("vig") / "rovinieta.jpg"
    img.save(out, quality=88)
    return out


@pytest.fixture(scope="module")
def extracted(vignette_photo):
    return asyncio.run(ocr.extract_vignette_data(vignette_photo))


def test_the_expiry_date_is_not_the_start_date(extracted):
    """Cazul care strica totul: "Valabilitate: 01.07.2026 - 01.07.2027" are o
    singura eticheta pentru doua date. Cautarea pe eticheta gasea amandoua
    datele in acelasi loc si punea inceputul si la expirare - rovinieta parea
    expirata chiar in ziua cumpararii, iar mementoul n-ar fi venit niciodata."""
    assert extracted["valid_from"] == "2026-07-01"
    assert extracted["valid_until"] == "2027-07-01"


def test_period_is_deduced_from_the_two_dates(extracted):
    """Documentul nu scrie "1 an" nicaieri; distanta dintre date o spune."""
    assert extracted["validity_period"] == "1_an"


def test_series_and_number_are_separate_fields(extracted):
    """Erau amandoua intr-unul singur: regexul prindea "RO 12345678" intreg si
    il punea la numar, iar seria ramanea goala."""
    assert extracted["invoice_series"] == "RO"
    assert extracted["invoice_number"] == "12345678"


def test_the_issuer_is_normalised(extracted):
    """Pe document scrie "C.N.A.I.R. S.A."; in formular vrem o singura forma."""
    assert extracted["issuer_company"] == "CNAIR"


def test_the_city_comes_from_the_issuing_point(extracted):
    """Orasul apare in adresa punctului de emitere, fara eticheta inaintea lui -
    de asta cautarea dupa "oras/localitatea" nu-l gasea niciodata."""
    assert extracted["city"] == "Ramnicu Valcea"


def test_the_price_is_the_amount_not_a_date(extracted):
    """Regexul de pret prindea "01.07" din "01.07.2026" si punea 1,07 lei."""
    assert extracted["price"] == 138.50


def test_the_plate_number_does_not_become_the_invoice_number(extracted):
    assert extracted["invoice_number"] != "12"


# ── Variante de formulare, fara OCR ──────────────────────────────────

@pytest.mark.parametrize("text,series,number", [
    ("Seria RO nr 7654321", "RO", "7654321"),
    ("SERIA: AB1 NR: 99887766", "AB1", "99887766"),
    ("Seria RO Nr. 5556667", "RO", "5556667"),
    ("Seria RO 4443332", "RO", "4443332"),
])
def test_series_and_number_across_formats(text, series, number):
    assert ocr._find_series_and_number(text) == (series, number)


def test_plate_written_with_digits_is_not_taken_as_the_number():
    text = "Nr. inmatriculare 123456  Seria RO Nr. 7654321"
    assert ocr._find_series_and_number(text)[1] == "7654321"


@pytest.mark.parametrize("text,expected", [
    ("Total: 1.234,50 lei", 1234.50),
    ("Pret 96,00 RON", 96.0),
    ("Tarif: 138,50", 138.50),
    ("Emis la 01.07.2026", None),
    ("Valabil 12.01.2026 - 12.01.2027", None),
])
def test_price_needs_a_currency_or_a_label(text, expected):
    assert ocr._find_price(text) == expected


@pytest.mark.parametrize("text,expected", [
    ("Posta Romana Cluj-Napoca", "Cluj-Napoca"),
    ("punct de emitere Bucuresti sector 3", "Bucuresti"),
    ("OMV Râmnicu Vâlcea", "Ramnicu Valcea"),
    ("fara nicio localitate aici", None),
])
def test_city_is_found_without_a_label(text, expected):
    assert ocr._find_city(text) == expected


@pytest.mark.parametrize("text,expected", [
    ("Emitent: C.N.A.I.R. S.A.", "CNAIR"),
    ("CNADNR", "CNAIR"),
    ("platit pe e-rovinieta.ro", "e-rovinieta.ro"),
    ("Posta Romana", "Posta Romana"),
    ("statie OMV", "OMV Petrom"),
])
def test_issuer_is_recognised_and_normalised(text, expected):
    assert ocr._find_issuer(text) == expected


# ── Bon de benzinarie ────────────────────────────────────────────────
#
# Formatul in care se cumpara cele mai multe roviniete: bon de casa, etichete
# bilingve, iar valoarea tiparita pe randul de sub eticheta fiindca nu incape
# langa ea. Numarul de inmatriculare si VIN-ul sunt inventate.

RECEIPT = """MOL ROMANIA PETROLEUM PRODUCTS SRL
SELIMBAR, STR. SIBIULUI, NR.1, JUD.SIBIU
COD FISCAL: RO7745470
NUMAR BON NEFISCAL: 318
COD CASIER: 2
POS: 2

ROVINIETA
DOVADA / COUNTERFOIL
COPIE CLIENT/CUSTOMERS COPY

NR AUTO/REGISTRATION NUMBER:        AB99TST
SERIE SASIU/V.I.N.:          VF1BT1RG600000000
TARA/COUNTRY:                       ROMANIA(RO)
TIP/TYPE:                      AUTOTURISME 12 LUNI
PET/PRICE:                 253.92 LEI (50.00 EUR)
CURS:               1 EUR=5.0783 LEI/30.09.2025
VALABIL DE LA/START OF VALIDITY:
                             12.10.2025 00:00:00
PANA LA/END OF VALIDITY:
                             11.10.2026 23:59:59
ID TRANZACTIE/TRANSACTION ID:
                                 CNADNR0300000000
SERIE/SERIAL NUMBER:
                                     7160000000

A SE PASTRA UN AN LA DATA EXPIRATI!
KEEP IT FOR 1 YEAR AFTER EXPIRATION!

NUMAR UNIC: 1000000000
DATA: 10/10/2025            ORA: 14:02:28
BON NEFISCAL"""


def test_receipt_validity_dates_come_from_the_line_below_the_label():
    """Eticheta e bilingva si lunga, asa ca valoarea se tipareste dedesubt.

    Cautarea de dinainte se uita dupa data INAUNTRUL etichetei, nu o gasea, si
    cadea inapoi pe prima data din document - care aici e cursul valutar de pe
    randul CURS. Si inceputul, si sfarsitul ieseau 30.09.2025.
    """
    assert ocr._find_date(RECEIPT, [r"valabil[aă]?\s*de\s*la",
                                    r"start\s*of\s*validity"]) == "2025-10-12"
    assert ocr._find_date(RECEIPT, [r"p[aâ]n[aă]\s*la",
                                    r"end\s*of\s*validity"]) == "2026-10-11"


def test_receipt_purchase_date_is_the_bare_data_label():
    """Bonul scrie doar "DATA: 10/10/2025", jos de tot, cu bare oblice."""
    assert ocr._find_date(RECEIPT, [r"\bdata\s*:"]) == "2025-10-10"


def test_receipt_issuer_is_the_station_not_a_transaction_id():
    """"CNADNR0300000000" e ID-ul tranzactiei. Lipit de cifre, nu e nume de
    firma - emitentul e benzinaria din antetul bonului."""
    assert ocr._find_issuer(RECEIPT) == "MOL"


def test_receipt_serial_number_is_read_from_below_its_label():
    """Bonul are numar de serie, dar nu si serie alfanumerica. Numarul nu
    trebuie confundat cu ID-ul tranzactiei sau cu numarul bonului."""
    series, number = ocr._find_series_and_number(RECEIPT)
    assert number == "7160000000"
    assert series is None


def test_receipt_price_is_the_amount_not_the_exchange_rate():
    """Pe bon sunt trei numere cu zecimale: pretul, echivalentul in euro si
    cursul. Cel cu eticheta de pret castiga."""
    assert ocr._find_price(RECEIPT) == 253.92


def test_receipt_city_comes_from_the_county_in_the_header():
    assert ocr._find_city(RECEIPT) == "Sibiu"


def test_receipt_period_is_read_from_the_vehicle_type_line():
    """"AUTOTURISME 12 LUNI" - perioada nu e scrisa ca atare nicaieri."""
    import re
    assert re.search(r"12\s*luni", RECEIPT, re.IGNORECASE)


def test_value_after_label_handles_both_layouts():
    assert ocr._value_after_label("Serie/Serial number:\n   ABC123", 
                                  r"seri[ae]\s*/\s*serial\s*number") == "ABC123"
    assert ocr._value_after_label("Serie/Serial number: ABC123",
                                  r"seri[ae]\s*/\s*serial\s*number") == "ABC123"
    assert ocr._value_after_label("nimic aici", r"seri[ae]") is None


def test_the_earliest_company_name_in_the_document_wins():
    """Bonul incepe cu antetul vanzatorului, iar CNAIR apare mai jos doar ca
    parte din codul tranzactiei. Daca ordinea din lista ar decide, orice bon de
    benzinarie ar fi atribuit CNAIR - ceea ce si se intampla."""
    assert ocr._find_issuer(RECEIPT) == "MOL"
    # Un document emis chiar de CNAIR il are in antet, deci tot el iese.
    assert ocr._find_issuer("C.N.A.I.R. S.A.\nvandut prin OMV") == "CNAIR"
