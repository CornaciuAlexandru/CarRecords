"""Citirea talonului dintr-o poza de telefon.

Testul isi genereaza singur poza: un talon sintetic cu codurile UE, rotit cu
90 de grade ca in pozele reale, marit la dimensiune de telefon, cu putin zgomot.
Nu exista fisier binar in repo si nici date personale.

De ce exista: inainte, pipeline-ul alegea rotatia dupa numarul de "cuvinte" din
fiecare orientare, iar textul cu capul in jos are tot atatea. Poza ajungea la
parser inversata si nu iesea niciun camp - in 10 secunde. Testul asta ar fi
prins-o.
"""
import asyncio
import random
import time

import pytest
from PIL import Image, ImageDraw, ImageFilter, ImageFont

from app.services import ocr

pytestmark = pytest.mark.skipif(not ocr.OCR_AVAILABLE, reason="Tesseract nu e instalat")

TALON = [
    ("A", "VL 12 ABC"), ("B", "03.01.2013"), ("C.2.1", "POPESCU"), ("C.2.2", "ION"),
    ("C.2.3", "Str. Carpinis Nr. 12 Ocnele Mari Jud. Valcea"),
    ("D.1", "RENAULT"), ("D.2", "BT"), ("D.3", "LAGUNA"), ("E", "VF1BT1RG648222399"),
    ("F.1", "1936"), ("G", "1385"), ("I", "10.10.2024"), ("I.1", "10.10.2024"),
    ("P.1", "1461"), ("P.2", "81"), ("P.3", "MOTORINA"), ("R", "ALB"), ("X", "07.10.2026"),
]

EXPECTED = {
    "owner_name": "POPESCU ION",
    "owner_address": "Str. Carpinis Nr. 12 Ocnele Mari Jud. Valcea",
    "itp_expiry_date": "2026-10-07",
    "registration_date": "2024-10-10",
    "registration_number": "VL12ABC",
    "car_series": "VF1BT1RG648222399",
    "brand": "RENAULT",
    "model": "LAGUNA",
    "manufacturing_year": "2013",
}


def _font():
    for path in ("C:/Windows/Fonts/arial.ttf",
                 "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
                 "/usr/share/fonts/dejavu/DejaVuSans.ttf"):
        try:
            return ImageFont.truetype(path, 34)
        except OSError:
            continue
    pytest.skip("niciun font TrueType disponibil")


def _talon_photo(tmp_path, rotation=90, size=(3000, 4000), noise=60000):
    font = _font()
    img = Image.new("L", (1400, 1000), 235)
    draw = ImageDraw.Draw(img)
    y = 40
    for code, value in TALON:
        draw.text((40, y), code, font=font, fill=20)
        draw.text((220, y), value, font=font, fill=20)
        y += 52
    if rotation:
        img = img.rotate(rotation, expand=True)
    if img.size[0] > img.size[1] and size[0] < size[1]:
        size = (size[1], size[0])
    img = img.resize(size, Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.8))
    px = img.load()
    rnd = random.Random(1)
    for _ in range(noise):
        x, yy = rnd.randrange(size[0]), rnd.randrange(size[1])
        px[x, yy] = max(0, min(255, px[x, yy] + rnd.randint(-25, 25)))
    out = tmp_path / f"talon_{rotation}.jpg"
    img.save(out, quality=88)
    return out


def _extract(path):
    result = asyncio.run(ocr.extract_registration_data(path))
    result.pop("ocr_raw_text", None)
    return result


@pytest.mark.parametrize("rotation", [90, 0, 270, 180])
def test_every_field_is_read_whatever_the_orientation(tmp_path, rotation):
    """Poza de pe telefon vine cum a fost tinut telefonul. Toate cele patru
    orientari trebuie sa dea acelasi rezultat."""
    result = _extract(_talon_photo(tmp_path, rotation=rotation))
    assert result == EXPECTED, f"rotatie {rotation}: {result}"


def test_a_phone_sized_photo_is_read_in_reasonable_time(tmp_path):
    """Aplicatia asteapta maximum doua minute. Un talon de 12 megapixeli
    trebuie sa iasa mult sub - inainte de plafonarea rezolutiei si de trecerile
    in paralel dura de patru ori mai mult decat acum."""
    path = _talon_photo(tmp_path)
    started = time.perf_counter()
    _extract(path)
    assert time.perf_counter() - started < 30


def test_low_resolution_photo_still_reads_the_essentials(tmp_path):
    """O poza mica (galerie comprimata, ecran fotografiat) pierde detalii, dar
    placuta, VIN-ul si marca trebuie sa iasa oricum."""
    result = _extract(_talon_photo(tmp_path, size=(1200, 1600), noise=10000))
    for key in ("registration_number", "car_series", "brand", "manufacturing_year"):
        assert result[key] == EXPECTED[key], f"{key}: {result}"


def test_rotation_detector_agrees_with_the_photo(tmp_path):
    """Detectorul de orientare, direct: o poza rotita cu 90 de grade in PIL se
    indreapta cu 270."""
    img = ocr._load_image(_talon_photo(tmp_path, rotation=90))
    assert ocr._detect_rotation(img) == 270


def test_lone_i_lines_are_the_registration_date():
    """Tesseract citeste un I izolat ca '|', '1' sau 'l'. Fiecare trebuie
    recunoscut ca I / I.1 cand e urmat de o data."""
    for line in ("| 10.10.2024", "1 10.10.2024", "l 10.10.2024"):
        assert ocr._parse_talon_fields(line).get("I") == "10.10.2024", line
    for line in ("l.1 10.10.2024", "|.1 10.10.2024", "1.1 10.10.2024"):
        assert ocr._parse_talon_fields(line).get("I1") == "10.10.2024", line
    # Un B cu o data ramane B, nu devine I.
    assert "I" not in ocr._parse_talon_fields("B 03.01.2013")


# ── Seria de sasiu (VIN) ─────────────────────────────────────────────

def test_manufacturer_code_is_corrected_towards_the_brand():
    """Cazul real raportat: OCR-ul a citit E in loc de F. Cele doua litere
    difera printr-o bara orizontala, iar pe un talon scanat se confunda des."""
    assert ocr._fix_vin_wmi("VE1BT1RG648222399", "RENAULT") == "VF1BT1RG648222399"
    assert ocr._fix_vin_wmi("UV1KSDCEF12345678", "DACIA") == "UU1KSDCEF12345678"


def test_a_correct_vin_is_left_alone():
    for vin, brand in (("VF1BT1RG648222399", "RENAULT"),
                       ("WBA3B1C51DF123456", "BMW"),
                       ("TMBJF25L6E6012345", "SKODA")):
        assert ocr._fix_vin_wmi(vin, brand) == vin


def test_correction_works_without_a_known_brand():
    """Marca nu se citeste intotdeauna. Cand codul rezultat e neambiguu la
    nivelul tuturor producatorilor, corectia se aplica oricum."""
    assert ocr._fix_vin_wmi("VE1BT1RG648222399", None) == "VF1BT1RG648222399"


def test_an_unrecognisable_code_is_not_invented():
    """Un cod de producator la mai mult de o litera distanta de orice cod
    cunoscut se lasa asa cum e: mai bine o valoare pe care omul o corecteaza
    decat una inventata de noi, care pare corecta."""
    assert ocr._fix_vin_wmi("XYZ12345678901234", "RENAULT") == "XYZ12345678901234"


def test_a_brand_that_does_not_match_the_code_is_not_forced():
    """Marca citita gresit nu trebuie sa strice un VIN corect: BMW-ul ramane
    BMW chiar daca marca detectata spune altceva."""
    assert ocr._fix_vin_wmi("WBA3B1C51DF123456", "DACIA") == "WBA3B1C51DF123456"


def test_character_voting_beats_a_single_bad_pass():
    """Trei treceri citesc corect, una greseste o litera. Votul pe siruri
    intregi ar fi dat patru rezultate diferite daca greselile nu coincid;
    votul pe pozitii repara fiecare caracter separat."""
    good, bad = "VF1BT1RG648222399", "VE1BT1RG648222399"
    assert ocr._vote_vin([good, good, good, bad]) == good
    assert ocr._vote_vin([good, bad, good, "VF1BT1RG648222398"]) == good
    assert ocr._vote_vin([good] * 4) == good
    assert ocr._vote_vin([]) is None
