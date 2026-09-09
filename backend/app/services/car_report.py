"""Raportul PDF cu istoricul unei masini.

La vanzare, un istoric documentat schimba pretul. Datele exista deja in
aplicatie - lipsea doar forma in care pot fi aratate cuiva din afara.

Raportul nu pretinde ca verifica ceva. Spune clar ca e o listare a evidentei
tinute de proprietar: altfel ar fi un document care sugereaza o garantie pe
care nimeni n-a dat-o.
"""
import unicodedata
from datetime import date, datetime
from pathlib import Path
from typing import Optional

from fpdf import FPDF

# Fonturi cu diacritice, cautate in ordine. Prima gasita castiga.
#   - Linux/Docker: pachetul fonts-dejavu-core
#   - Windows: fontul de sistem
FONT_CANDIDATES = (
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/usr/share/fonts/dejavu/DejaVuSans.ttf",
    "C:/Windows/Fonts/DejaVuSans.ttf",
    "C:/Windows/Fonts/arial.ttf",
)

MAINTENANCE_LABELS = {
    "schimb_ulei": "Schimb ulei",
    "filtre": "Filtre",
    "placute_frana": "Placute frana",
    "anvelope": "Anvelope",
    "distributie": "Distributie",
    "curea_alternator": "Curea alternator",
    "baterie": "Baterie",
    "amortizoare": "Amortizoare",
    "bujii": "Bujii",
    "altul": "Altele",
}

MODIFICATION_LABELS = {
    "motor": "Motor",
    "exterior": "Exterior",
    "interior": "Interior",
    "suspensie": "Suspensie",
    "audio": "Audio",
    "electronic": "Electronice",
    "frane": "Frane",
    "altul": "Altele",
}


def _strip_diacritics(text: str) -> str:
    """Ultima solutie, cand nu s-a gasit niciun font cu diacritice.

    Fonturile de baza din PDF acopera doar Latin-1, care n-are s si t cu
    virgula. Fara asta, un raport pentru "Bucuresti" ar arunca o exceptie in loc
    sa iasa pe hartie.
    """
    return unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii")


class _Report(FPDF):
    def __init__(self):
        super().__init__()
        self.unicode_ok = False
        for candidate in FONT_CANDIDATES:
            if Path(candidate).is_file():
                try:
                    self.add_font("body", "", candidate)
                    self.unicode_ok = True
                    self.font_family_name = "body"
                    break
                except Exception:
                    continue
        if not self.unicode_ok:
            self.font_family_name = "Helvetica"
        self.set_auto_page_break(auto=True, margin=18)

    def text_of(self, value) -> str:
        text = "" if value is None else str(value)
        return text if self.unicode_ok else _strip_diacritics(text)

    def use(self, size: int = 10, bold: bool = False):
        # Un font incarcat din fisier are un singur stil, deci ingrosarea se
        # simuleaza; fonturile de baza au stil "B" adevarat.
        style = "B" if (bold and not self.unicode_ok) else ""
        self.set_font(self.font_family_name, style, size)
        if bold and self.unicode_ok:
            self.set_text_color(0, 0, 0)

    def heading(self, text: str):
        if self.get_y() > 240:
            self.add_page()
        self.ln(4)
        self.use(12, bold=True)
        self.set_fill_color(238, 240, 244)
        self.cell(0, 9, "  " + self.text_of(text), new_x="LMARGIN", new_y="NEXT", fill=True)
        self.ln(2)

    def row(self, label: str, value):
        if value in (None, "", []):
            return
        self.use(10, bold=True)
        self.cell(58, 6, self.text_of(label))
        self.use(10)
        self.multi_cell(0, 6, self.text_of(value), new_x="LMARGIN", new_y="NEXT")

    def line_item(self, text: str):
        self.use(10)
        self.multi_cell(0, 6, self.text_of(text), new_x="LMARGIN", new_y="NEXT")


def _fmt_date(value: Optional[date]) -> str:
    return value.strftime("%d.%m.%Y") if value else "-"


def _fmt_money(amount: Optional[float], currency: Optional[str]) -> str:
    if amount is None:
        return ""
    return f"{amount:.2f} {currency or 'RON'}"


def build_car_report(car, owner) -> bytes:
    """Raportul complet al unei masini, gata de trimis.

    Primeste obiectele ORM: relatiile incarcate leneș sunt citite aici, intr-o
    sesiune inca deschisa.
    """
    pdf = _Report()
    pdf.add_page()

    pdf.use(18, bold=True)
    title = car.nickname or f"{car.brand} {car.model}"
    pdf.cell(0, 10, pdf.text_of(title), new_x="LMARGIN", new_y="NEXT")
    pdf.use(11)
    pdf.set_text_color(90, 90, 90)
    pdf.cell(0, 6, pdf.text_of(f"{car.license_plate} - istoric complet"),
             new_x="LMARGIN", new_y="NEXT")
    pdf.set_text_color(0, 0, 0)

    pdf.heading("Masina")
    pdf.row("Marca si model", f"{car.brand} {car.model}")
    pdf.row("An fabricatie", car.year)
    pdf.row("Numar inmatriculare", car.license_plate)
    pdf.row("Serie sasiu (VIN)", car.vin_number)
    pdf.row("Combustibil", car.fuel_type)
    pdf.row("Capacitate cilindrica", f"{car.engine_capacity} cmc" if car.engine_capacity else None)
    pdf.row("Putere", f"{car.engine_power} CP" if car.engine_power else None)
    pdf.row("Culoare", car.color)
    pdf.row("Kilometraj", f"{car.mileage} km" if car.mileage else None)

    active = [r for r in car.registrations if r.is_active] or list(car.registrations)
    if active:
        pdf.heading("Talon si ITP")
        for reg in active:
            pdf.row("Numar talon", reg.registration_number)
            pdf.row("Proprietar", reg.owner_name)
            pdf.row("Data inmatricularii", _fmt_date(reg.registration_date))
            pdf.row("ITP valabil pana la", _fmt_date(reg.itp_expiry_date))

    if car.insurance_policies:
        pdf.heading("Asigurari")
        for p in sorted(car.insurance_policies, key=lambda x: x.valid_until, reverse=True):
            cost = _fmt_money(p.premium_amount, "RON")
            pdf.line_item(
                f"{p.type} - {p.insurer_company or 'necunoscut'} - "
                f"{_fmt_date(p.valid_from)} - {_fmt_date(p.valid_until)}"
                + (f" - {cost}" if cost else "")
            )

    if car.vignettes:
        pdf.heading("Roviniete")
        for v in sorted(car.vignettes, key=lambda x: x.valid_until, reverse=True):
            cost = _fmt_money(v.price, "RON")
            pdf.line_item(
                f"{_fmt_date(v.valid_from)} - {_fmt_date(v.valid_until)}"
                + (f" - {cost}" if cost else "")
            )

    if car.maintenance_records:
        pdf.heading("Istoric service")
        total = 0.0
        for m in sorted(car.maintenance_records, key=lambda x: x.performed_date, reverse=True):
            label = MAINTENANCE_LABELS.get(m.type, m.type)
            parts = [_fmt_date(m.performed_date), label]
            if m.mileage_at_service:
                parts.append(f"{m.mileage_at_service} km")
            if m.service_shop_name:
                parts.append(m.service_shop_name)
            cost = _fmt_money(m.cost, m.currency)
            if cost:
                parts.append(cost)
                total += m.cost or 0
            pdf.line_item(" - ".join(str(p) for p in parts))
            if m.description:
                pdf.use(9)
                pdf.set_text_color(110, 110, 110)
                pdf.multi_cell(0, 5, pdf.text_of("    " + m.description),
                               new_x="LMARGIN", new_y="NEXT")
                pdf.set_text_color(0, 0, 0)
        if total:
            pdf.ln(1)
            pdf.use(10, bold=True)
            pdf.cell(0, 6, pdf.text_of(f"Total investit in service: {total:.2f} RON"),
                     new_x="LMARGIN", new_y="NEXT")

    if car.modifications:
        pdf.heading("Modificari")
        for mod in car.modifications:
            label = MODIFICATION_LABELS.get(mod.category, mod.category)
            extra = " (omologata)" if mod.is_homologated else ""
            pdf.line_item(f"{label}: {mod.description}{extra}")

    pdf.ln(6)
    pdf.use(8)
    pdf.set_text_color(120, 120, 120)
    generated = datetime.now().strftime("%d.%m.%Y %H:%M")
    pdf.multi_cell(0, 4, pdf.text_of(
        f"Generat de CarRecords la {generated} pentru {owner.full_name}. "
        "Documentul listeaza evidenta tinuta de proprietar in aplicatie si nu "
        "constituie o verificare independenta a masinii."
    ), new_x="LMARGIN", new_y="NEXT")

    return bytes(pdf.output())
