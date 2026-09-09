"""Ce poate face un cont, in functie de planul lui.

Un singur loc pentru toate limitele. Cand se schimba un pret sau un plafon, se
schimba aici - nu prin sase fisiere care trebuie tinute minte.

Regula de baza: limitele se verifica pe server. Aplicatia le afiseaza ca sa nu
duca omul pana la un buton care oricum ar esua, dar nu ea decide.
"""
from typing import Optional

FREE = "free"
PRO = "pro"
MAXI = "maxi"

# Cate masini incape intr-un cont, pe plan.
MAX_CARS = {
    FREE: 2,
    PRO: 10,
    MAXI: 25,
}

# Scanari OCR incluse cu fiecare masina, indiferent de plan. Acopera un talon,
# o polita, o rovinieta si doua incercari ratate - adica exact configurarea
# unei masini. Nu se reinnoiesc: documentele se scaneaza o data.
SCANS_PER_CAR = 5

# Planurile vechi, dinainte sa existe PRO si MAXI. Conturile ramase cu "premium"
# primesc PRO, care e echivalentul lui.
LEGACY_TIERS = {"premium": PRO}

VALID_TIERS = (FREE, PRO, MAXI)
# Planurile platite. Ce e rezervat lor se verifica prin `is_paid`, nu prin
# comparatii cu numele planului imprastiate prin cod.
PAID_TIERS = (PRO, MAXI)


def normalize_tier(tier: Optional[str]) -> str:
    """Planul, adus la una dintre valorile curente.

    Orice necunoscut cade pe FREE. Un cont cu o valoare stricata in baza de date
    trebuie sa piarda accesul platit, nu sa primeasca totul.
    """
    if not tier:
        return FREE
    tier = tier.lower()
    tier = LEGACY_TIERS.get(tier, tier)
    return tier if tier in VALID_TIERS else FREE


def tier_of(user) -> str:
    return normalize_tier(getattr(user, "subscription_tier", None))


def max_cars(user) -> int:
    """Cate masini poate avea contul.

    Valoarea sta pe cont (`users.max_cars`) si e scrisa de aplicatie ori de cate
    ori se schimba planul. Se pastreaza pe cont, si nu se calculeaza de fiecare
    data din plan, ca sa poata un administrator sa acorde mai mult intr-un caz
    de suport fara sa-i schimbe planul. Cand lipseste, decide planul.
    """
    return (getattr(user, "max_cars", 0) or 0) or MAX_CARS[tier_of(user)]


def max_cars_for_tier(tier: Optional[str]) -> int:
    """Limita implicita a unui plan. Se scrie pe cont la schimbarea planului."""
    return MAX_CARS[normalize_tier(tier)]


def is_paid(user) -> bool:
    return tier_of(user) in PAID_TIERS


def can_export_report(user) -> bool:
    """Raportul PDF cu istoricul masinii - o functie de plan platit.

    E cel mai bun motiv de plata pe care il avem: la vanzare, un istoric
    documentat schimba pretul, iar datele exista doar aici.
    """
    return is_paid(user)


def scans_used(car) -> int:
    return getattr(car, "ocr_scans", 0) or 0


def scans_left_on_car(car) -> int:
    """Din cele incluse cu masina. Nu include scanarile cumparate separat."""
    return max(0, SCANS_PER_CAR - scans_used(car))


def scan_credits(user) -> int:
    """Scanari cumparate la bucata, folosibile pe orice masina a contului."""
    return getattr(user, "scan_credits", 0) or 0


def can_scan(user, car) -> bool:
    return scans_left_on_car(car) > 0 or scan_credits(user) > 0


def consume_scan(user, car) -> bool:
    """Scade o scanare, intai din cele incluse cu masina, apoi din cele cumparate.

    Nu face commit: apelantul decide cand se salveaza, ca scaderea si rezultatul
    scanarii sa ajunga in baza de date impreuna.

    Returneaza False daca nu mai era nimic de scazut.
    """
    if scans_left_on_car(car) > 0:
        car.ocr_scans = scans_used(car) + 1
        return True
    if scan_credits(user) > 0:
        user.scan_credits = scan_credits(user) - 1
        return True
    return False
