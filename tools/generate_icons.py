"""
Genereaza toate iconitele aplicatiei dintr-un singur fisier sursa.

Sursa:  logo_source.png (patrat, cu marca CR + lupa deasupra textului)
Rezultat:
  - Windows : windows/runner/resources/app_icon.ico (6 dimensiuni)
  - Android : mipmap-*/ic_launcher.png + ic_launcher_round.png
              + iconita adaptiva (Android 8+)
  - Flutter : assets/images/logo.png, logo_192.png
  - Installer: logo_512.png, wizard images pentru Inno Setup

Rulare:  python tools/generate_icons.py [cale_catre_logo.png]
"""
import struct
import sys
from io import BytesIO
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
FLUTTER = ROOT / "frontend" / "car_manager"
ANDROID_RES = FLUTTER / "android" / "app" / "src" / "main" / "res"

# Fundalul logo-ului (bleumarin)
BG = (0, 51, 119)


# ── Analiza imaginii sursa ────────────────────────────────────────

def content_bbox(img: Image.Image, bg=BG, tol=40, step=2):
    """Dreptunghiul care contine tot ce nu e fundal."""
    px = img.load()
    w, h = img.size
    xs, ys = [], []
    for y in range(0, h, step):
        for x in range(0, w, step):
            if sum(abs(a - b) for a, b in zip(px[x, y][:3], bg)) > tol:
                xs.append(x)
                ys.append(y)
    if not xs:
        return (0, 0, w, h)
    return (min(xs), min(ys), max(xs) + step, max(ys) + step)


def split_mark_and_text(img: Image.Image, bg=BG, tol=40):
    """Imparte logo-ul in marca (CR + lupa) si textul de dedesubt,
    cautand banda goala dintre ele."""
    px = img.load()
    w, h = img.size
    filled_rows = []
    for y in range(0, h, 2):
        if any(sum(abs(a - b) for a, b in zip(px[x, y][:3], bg)) > tol
               for x in range(0, w, 4)):
            filled_rows.append(y)
    if not filled_rows:
        return None, None

    # cea mai mare pauza verticala dintre randuri cu continut
    best_gap, best_at = 0, None
    for prev, cur in zip(filled_rows, filled_rows[1:]):
        if cur - prev > best_gap:
            best_gap, best_at = cur - prev, (prev, cur)

    if best_gap < 30 or best_at is None:
        return img.crop(content_bbox(img)), None

    split_y = (best_at[0] + best_at[1]) // 2
    top, bottom = img.crop((0, 0, w, split_y)), img.crop((0, split_y, w, h))
    return top.crop(content_bbox(top)), bottom.crop(content_bbox(bottom))


def square_icon(mark: Image.Image, size: int, fill_ratio=0.72,
                bg=BG, alpha_bg=False) -> Image.Image:
    """Aseaza marca centrata pe un fundal patrat."""
    canvas_bg = (0, 0, 0, 0) if alpha_bg else bg + (255,)
    canvas = Image.new("RGBA", (size, size), canvas_bg)

    target = int(size * fill_ratio)
    scale = min(target / mark.width, target / mark.height)
    new = mark.resize((max(1, int(mark.width * scale)),
                       max(1, int(mark.height * scale))), Image.LANCZOS)
    canvas.paste(new, ((size - new.width) // 2, (size - new.height) // 2),
                 new if new.mode == "RGBA" else None)
    return canvas


def rounded(img: Image.Image) -> Image.Image:
    """Varianta rotunda (ic_launcher_round)."""
    size = img.size[0]
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    out = img.copy()
    out.putalpha(mask)
    return out


def write_ico(img: Image.Image, path: Path,
              sizes=(16, 24, 32, 48, 64, 128, 256)):
    """Scrie un .ico multi-dimensiune.

    PIL salveaza uneori o singura dimensiune, asa ca scriem formatul
    manual: antet + director + imaginile PNG concatenate.
    """
    pngs = []
    for s in sizes:
        buf = BytesIO()
        img.resize((s, s), Image.LANCZOS).save(buf, format="PNG")
        pngs.append(buf.getvalue())

    header = struct.pack("<HHH", 0, 1, len(sizes))
    offset = 6 + 16 * len(sizes)
    entries, blobs = b"", b""
    for s, data in zip(sizes, pngs):
        entries += struct.pack("<BBBBHHII",
                               0 if s >= 256 else s, 0 if s >= 256 else s,
                               0, 0, 1, 32, len(data), offset)
        blobs += data
        offset += len(data)
    path.write_bytes(header + entries + blobs)
    return len(sizes)


# ── Program principal ─────────────────────────────────────────────

def main():
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "logo_source.png"
    if not src.exists():
        sys.exit(f"Nu gasesc fisierul sursa: {src}")

    print(f"Sursa: {src.name}")
    logo = Image.open(src).convert("RGBA")

    mark, text = split_mark_and_text(logo.convert("RGB"))
    mark = mark.convert("RGBA")
    print(f"  marca detectata : {mark.size[0]}x{mark.size[1]}")
    if text:
        print(f"  text detectat   : {text.size[0]}x{text.size[1]}")

    made = []

    # ── Windows ──────────────────────────────────────────────
    ico_path = FLUTTER / "windows" / "runner" / "resources" / "app_icon.ico"
    n = write_ico(square_icon(mark, 256).convert("RGB"), ico_path)
    made.append(f"Windows  app_icon.ico ({n} dimensiuni)")

    # ── Android: iconite clasice ─────────────────────────────
    for folder, size in [("mipmap-mdpi", 48), ("mipmap-hdpi", 72),
                         ("mipmap-xhdpi", 96), ("mipmap-xxhdpi", 144),
                         ("mipmap-xxxhdpi", 192)]:
        d = ANDROID_RES / folder
        d.mkdir(parents=True, exist_ok=True)
        icon = square_icon(mark, size)
        icon.convert("RGB").save(d / "ic_launcher.png")
        rounded(icon).save(d / "ic_launcher_round.png")
    made.append("Android  ic_launcher + _round (5 densitati)")

    # ── Android: iconita adaptiva (Android 8+) ───────────────
    # Sistemul decupeaza forma, deci marca ocupa mai putin din suprafata.
    anydpi = ANDROID_RES / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    for name in ("ic_launcher", "ic_launcher_round"):
        (anydpi / f"{name}.xml").write_text(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
            '    <monochrome android:drawable="@mipmap/ic_launcher_foreground"/>\n'
            '</adaptive-icon>\n', encoding="utf-8")

    for folder, size in [("mipmap-mdpi", 108), ("mipmap-hdpi", 162),
                         ("mipmap-xhdpi", 216), ("mipmap-xxhdpi", 324),
                         ("mipmap-xxxhdpi", 432)]:
        # 0.42 pentru ca sistemul taie marginile (safe zone e cercul central)
        square_icon(mark, size, fill_ratio=0.42, alpha_bg=True).save(
            ANDROID_RES / folder / "ic_launcher_foreground.png")

    values = ANDROID_RES / "values"
    values.mkdir(parents=True, exist_ok=True)
    (values / "ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<resources>\n'
        f'    <color name="ic_launcher_background">#{BG[0]:02X}{BG[1]:02X}{BG[2]:02X}</color>\n'
        '</resources>\n', encoding="utf-8")
    made.append("Android  iconita adaptiva (Android 8+)")

    # ── Assets Flutter (folosite in aplicatie) ───────────────
    assets = FLUTTER / "assets" / "images"
    assets.mkdir(parents=True, exist_ok=True)
    full = logo.crop(content_bbox(logo.convert("RGB")))
    # logo.png = logo complet (marca + text), pentru ecrane mari
    square_icon(full, 512, fill_ratio=0.86).convert("RGB").save(assets / "logo.png")
    # logo_192.png = doar marca, pentru spatii mici
    square_icon(mark, 192).convert("RGB").save(assets / "logo_192.png")
    made.append("Flutter  logo.png (complet) + logo_192.png (marca)")

    # ── Installer Inno Setup ─────────────────────────────────
    square_icon(mark, 512).convert("RGB").save(ROOT / "logo_512.png")
    # Imaginile din expertul de instalare au dimensiuni fixe
    wiz = Image.new("RGB", (164, 314), BG)
    m = square_icon(mark, 130).convert("RGB")
    wiz.paste(m, ((164 - 130) // 2, 60))
    wiz.save(ROOT / "wizard_image.bmp")
    small = Image.new("RGB", (55, 58), BG)
    small.paste(square_icon(mark, 50).convert("RGB"), (2, 4))
    small.save(ROOT / "wizard_small.bmp")
    made.append("Installer logo_512.png + imagini expert")

    print()
    for m_ in made:
        print(f"  OK  {m_}")
    print(f"\nGata — {len(made)} seturi de iconite generate.")


if __name__ == "__main__":
    main()
