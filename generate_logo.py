"""
Generare logo CarRecords — produce:
  logo_512.png   (sursa master)
  app_icon.ico   (16/32/48/64/128/256 px — pentru Windows EXE)
  logo_192.png   (Flutter assets)
  logo_48.png    (Flutter assets)
"""
from PIL import Image, ImageDraw, ImageFilter
import math, os

# ─── Culori ───────────────────────────────────────────────────────────────────
NAVY      = (30,  58,  95)       # #1E3A5F  — primary
BLUE      = (46,  80, 144)       # #2E5090  — primaryLight
ACCENT    = (0,  180, 216)       # #00B4D8  — accent
WHITE     = (255, 255, 255)
WHITE90   = (255, 255, 255, 230)
DARK      = (20,  35,  60)

SIZE = 512

def rounded_rect(draw, xy, radius, fill):
    x0, y0, x1, y1 = xy
    r = radius
    draw.rectangle([x0+r, y0, x1-r, y1], fill=fill)
    draw.rectangle([x0, y0+r, x1, y1-r], fill=fill)
    draw.ellipse([x0, y0, x0+2*r, y0+2*r], fill=fill)
    draw.ellipse([x1-2*r, y0, x1, y0+2*r], fill=fill)
    draw.ellipse([x0, y1-2*r, x0+2*r, y1], fill=fill)
    draw.ellipse([x1-2*r, y1-2*r, x1, y1], fill=fill)

def draw_car(draw, cx, cy, w, h):
    """Deseneaza o masina stilizata, centrata la (cx,cy), dimensiune w x h."""
    # ── Caroserie (corp principal) ────────────────────────────────────────────
    body_y1 = cy + h * 0.10
    body_y2 = cy + h * 0.55
    body_x0 = cx - w * 0.50
    body_x1 = cx + w * 0.50
    r_body = h * 0.07

    rounded_rect(draw,
        (body_x0, body_y1, body_x1, body_y2),
        int(r_body), WHITE)

    # ── Cabina (acoperis) ─────────────────────────────────────────────────────
    roof_pts = [
        (cx - w*0.24, body_y1),           # stanga jos cabina
        (cx - w*0.15, cy - h*0.22),       # colt stanga sus
        (cx + w*0.15, cy - h*0.22),       # colt dreapta sus
        (cx + w*0.28, body_y1),           # dreapta jos cabina
    ]
    draw.polygon(roof_pts, fill=WHITE)
    # rotunjire capac cu ellipse pe laturi
    draw.ellipse([cx-w*0.24-6, body_y1-12, cx-w*0.24+6, body_y1+12], fill=WHITE)
    draw.ellipse([cx+w*0.28-6, body_y1-12, cx+w*0.28+6, body_y1+12], fill=WHITE)

    # ── Geamuri (decupaj în nuante mai inchise) ───────────────────────────────
    win_color = (160, 210, 240, 200)
    win_pts_l = [
        (cx - w*0.22, body_y1 - 4),
        (cx - w*0.13, cy - h*0.18),
        (cx - w*0.01, cy - h*0.18),
        (cx - w*0.01, body_y1 - 4),
    ]
    win_pts_r = [
        (cx + w*0.03, body_y1 - 4),
        (cx + w*0.03, cy - h*0.18),
        (cx + w*0.16, cy - h*0.18),
        (cx + w*0.26, body_y1 - 4),
    ]
    # Draw on a separate RGBA layer for transparency
    glass_layer = Image.new('RGBA', (SIZE, SIZE), (0,0,0,0))
    gd = ImageDraw.Draw(glass_layer)
    gd.polygon(win_pts_l, fill=win_color)
    gd.polygon(win_pts_r, fill=win_color)
    return glass_layer

    # ── Roti ──────────────────────────────────────────────────────────────────
    # (desenate separat mai jos)

def make_logo(size=512):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    pad = int(size * 0.06)
    radius = int(size * 0.18)

    # ── Fundal gradient simulat ────────────────────────────────────────────────
    bg = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)
    for i in range(size):
        t = i / size
        r = int(NAVY[0] + (BLUE[0]-NAVY[0])*t*0.6)
        g = int(NAVY[1] + (BLUE[1]-NAVY[1])*t*0.6)
        b = int(NAVY[2] + (BLUE[2]-NAVY[2])*t*0.6)
        bg_draw.line([(0,i),(size,i)], fill=(r,g,b,255))
    # Masca rotunjita
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    rounded_rect(mask_draw, (pad, pad, size-pad, size-pad), radius, 255)
    bg.putalpha(mask)
    img.paste(bg, (0,0), bg)

    draw = ImageDraw.Draw(img)

    # ── Accent line (dungă albastru deschis jos) ───────────────────────────────
    stripe_y = int(size * 0.72)
    stripe_h = int(size * 0.06)
    for i in range(stripe_h):
        alpha = int(180 * (1 - i/stripe_h))
        draw.line([(pad, stripe_y+i), (size-pad, stripe_y+i)],
                  fill=(ACCENT[0], ACCENT[1], ACCENT[2], alpha))

    # ── Masina ────────────────────────────────────────────────────────────────
    cx, cy = size//2, int(size * 0.38)
    w, h = int(size*0.78), int(size*0.44)

    # Caroserie
    body_y1 = cy + int(h * 0.10)
    body_y2 = cy + int(h * 0.52)
    body_x0 = cx - w//2
    body_x1 = cx + w//2
    rounded_rect(draw, (body_x0, body_y1, body_x1, body_y2), int(h*0.07), WHITE)

    # Cabina
    roof_pts = [
        (cx - int(w*0.24), body_y1 + 2),
        (cx - int(w*0.14), cy - int(h*0.22)),
        (cx + int(w*0.14), cy - int(h*0.22)),
        (cx + int(w*0.27), body_y1 + 2),
    ]
    draw.polygon(roof_pts, fill=WHITE)

    # Geamuri
    glass = Image.new('RGBA', (size, size), (0,0,0,0))
    gd = ImageDraw.Draw(glass)
    gc = (140, 200, 235, 200)
    gd.polygon([
        (cx - int(w*0.22), body_y1 - 2),
        (cx - int(w*0.12), cy - int(h*0.19)),
        (cx - int(w*0.01), cy - int(h*0.19)),
        (cx - int(w*0.01), body_y1 - 2),
    ], fill=gc)
    gd.polygon([
        (cx + int(w*0.02), body_y1 - 2),
        (cx + int(w*0.02), cy - int(h*0.19)),
        (cx + int(w*0.15), cy - int(h*0.19)),
        (cx + int(w*0.25), body_y1 - 2),
    ], fill=gc)
    img = Image.alpha_composite(img, glass)
    draw = ImageDraw.Draw(img)

    # Roti
    wheel_y = body_y2 - int(h * 0.04)
    wheel_r = int(h * 0.22)
    for wx in [cx - int(w*0.30), cx + int(w*0.30)]:
        # Anvelopa
        draw.ellipse([wx-wheel_r, wheel_y-wheel_r,
                      wx+wheel_r, wheel_y+wheel_r], fill=DARK)
        # Janta
        rim_r = int(wheel_r * 0.62)
        draw.ellipse([wx-rim_r, wheel_y-rim_r,
                      wx+rim_r, wheel_y+rim_r], fill=(200,210,220))
        # Centru janta
        hub_r = int(wheel_r * 0.22)
        draw.ellipse([wx-hub_r, wheel_y-hub_r,
                      wx+hub_r, wheel_y+hub_r], fill=DARK)
        # Spite (5)
        for angle in range(0, 360, 72):
            rad = math.radians(angle)
            ex = wx + int(rim_r * 0.82 * math.cos(rad))
            ey = wheel_y + int(rim_r * 0.82 * math.sin(rad))
            draw.line([wx, wheel_y, ex, ey], fill=DARK, width=max(2, size//100))

    # Faruri față
    light_y = (body_y1 + body_y2) // 2
    draw.ellipse([body_x1-int(w*0.06), light_y-int(h*0.07),
                  body_x1-int(w*0.01), light_y+int(h*0.07)],
                 fill=(ACCENT[0], ACCENT[1], ACCENT[2], 220))
    # Stop spate
    draw.ellipse([body_x0+int(w*0.01), light_y-int(h*0.06),
                  body_x0+int(w*0.05), light_y+int(h*0.06)],
                 fill=(220, 60, 60, 220))

    # ── Text "CarRecords" ──────────────────────────────────────────────────────
    # Desenăm literele manual cu dreptunghiuri (fara font extern)
    text_y = int(size * 0.76)
    text_h = int(size * 0.09)

    # Scriem "CR" mare și "arRecords" mai mic pentru logo compact
    # Folosim PIL cu font default
    try:
        from PIL import ImageFont
        # Incearca sa incarce un font de sistem
        font_paths = [
            "C:/Windows/Fonts/calibrib.ttf",
            "C:/Windows/Fonts/arialbd.ttf",
            "C:/Windows/Fonts/arial.ttf",
            "C:/Windows/Fonts/segoeui.ttf",
        ]
        big_font = small_font = None
        for fp in font_paths:
            if os.path.exists(fp):
                big_font   = ImageFont.truetype(fp, int(size * 0.115))
                small_font = ImageFont.truetype(fp, int(size * 0.072))
                break
        if big_font is None:
            big_font = small_font = ImageFont.load_default()
    except Exception:
        from PIL import ImageFont
        big_font = small_font = ImageFont.load_default()

    # "Car" parte colorata cu accent, "Records" alb
    label = "CarRecords"
    # Calculeaza latime totala
    bb = draw.textbbox((0,0), label, font=big_font)
    tw = bb[2] - bb[0]
    tx = (size - tw) // 2
    ty = text_y

    draw.text((tx, ty), "Car",     font=big_font, fill=ACCENT)
    bb_car = draw.textbbox((tx, ty), "Car", font=big_font)
    draw.text((bb_car[2], ty), "Records", font=big_font, fill=WHITE)

    # Subtitrare mică
    subtitle = "Gestionează-ți mașinile"
    bb2 = draw.textbbox((0,0), subtitle, font=small_font)
    tw2 = bb2[2] - bb2[0]
    draw.text(((size-tw2)//2, ty + int(size*0.12)), subtitle,
              font=small_font, fill=(180, 205, 230, 200))

    return img

print("Generare logo 512x512...")
logo = make_logo(512)
logo.save(r"C:\Users\Alex\CarManager\logo_512.png")
print("  -> logo_512.png")

# Variante pentru Flutter assets
logo.resize((192,192), Image.LANCZOS).save(r"C:\Users\Alex\CarManager\logo_192.png")
logo.resize((48,48),   Image.LANCZOS).save(r"C:\Users\Alex\CarManager\logo_48.png")
print("  -> logo_192.png, logo_48.png")

# ── ICO multi-dimensiune ──────────────────────────────────────────────────────
print("Generare app_icon.ico (16/32/48/64/128/256)...")
ico_sizes = [(16,16),(32,32),(48,48),(64,64),(128,128),(256,256)]
ico_images = [logo.resize(s, Image.LANCZOS).convert("RGBA") for s in ico_sizes]

ico_path = r"C:\Users\Alex\CarManager\frontend\car_manager\windows\runner\resources\app_icon.ico"
ico_images[0].save(ico_path, format='ICO',
                   sizes=ico_sizes,
                   append_images=ico_images[1:])
print(f"  -> {ico_path}")

# Copie pentru Inno Setup
import shutil
shutil.copy(ico_path, r"C:\Users\Alex\CarManager\app_icon.ico")
print("  -> app_icon.ico (copie pentru installer)")

print("\nDone!")
