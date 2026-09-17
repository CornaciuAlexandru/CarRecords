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
