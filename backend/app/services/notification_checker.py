import uuid
from datetime import date, timedelta
from sqlalchemy.orm import Session
from app.models.car import Car
from app.models.vignette import Vignette
from app.models.insurance import InsurancePolicy
from app.models.registration import VehicleRegistration
from app.models.maintenance import MaintenanceRecord
from app.models.notification import Notification

VIGNETTE_THRESHOLDS = [30, 7, 1]
INSURANCE_THRESHOLDS = [45, 14, 3]
ITP_THRESHOLDS = [60, 30, 7]
OIL_KM_THRESHOLDS = [1000, 500, 0]

# Cat de departe in viitor programam notificari pe telefon. Peste un an nu are
# rost: pana atunci utilizatorul si-a reinnoit documentul, iar telefonul
# resincronizeaza la fiecare pornire oricum.
PLAN_HORIZON_DAYS = 400


def _expiry_texts(kind: str, label: str, days_left: int, when: date) -> tuple:
    """Titlul si mesajul pentru un document care expira.

    Traieste intr-un singur loc pentru ca lista din aplicatie si notificarea
    programata pe telefon sa spuna exact acelasi lucru.
    """
    if kind == "rovinieta_expira":
        return (f"Rovinieta expira curand - {label}",
                f"Rovinieta pentru {label} expira in {days_left} zile ({when}).")
    if kind == "itp_expira":
        return (f"ITP expira curand - {label}",
                f"ITP pentru {label} expira in {days_left} zile ({when}).")
    raise ValueError(kind)


def _insurance_texts(label: str, kind_label: str, days_left: int, when: date) -> tuple:
    return (f"Asigurare {kind_label} expira - {label}",
            f"Asigurarea {kind_label} pentru {label} expira in {days_left} zile ({when}).")


def _already_notified(db: Session, user_id: str, car_id: str, notif_type: str, days: int) -> bool:
    cutoff = date.today() - timedelta(days=1)
    return db.query(Notification).filter(
        Notification.user_id == user_id,
        Notification.car_id == car_id,
        Notification.type == notif_type,
        Notification.days_before_alert == days,
        Notification.triggered_at >= cutoff,
    ).first() is not None


def _create(db: Session, user_id: str, car_id: str, notif_type: str,
            title: str, message: str, days: int):
    if _already_notified(db, user_id, car_id, notif_type, days):
        return False
    db.add(Notification(
        id=str(uuid.uuid4()),
        user_id=user_id,
        car_id=car_id,
        type=notif_type,
        title=title,
        message=message,
        days_before_alert=days,
    ))
    return True


def check_and_create_notifications(user_id: str, db: Session) -> int:
    created = 0
    today = date.today()
    cars = db.query(Car).filter(Car.user_id == user_id).all()

    for car in cars:
        label = f"{car.brand} {car.model} ({car.license_plate})"

        for v in db.query(Vignette).filter(Vignette.car_id == car.id).all():
            days_left = (v.valid_until - today).days
            for threshold in VIGNETTE_THRESHOLDS:
                if 0 <= days_left <= threshold:
                    title, message = _expiry_texts(
                        "rovinieta_expira", label, days_left, v.valid_until)
                    if _create(db, user_id, car.id, "rovinieta_expira",
                               title, message, threshold):
                        created += 1

        for p in db.query(InsurancePolicy).filter(InsurancePolicy.car_id == car.id).all():
            days_left = (p.valid_until - today).days
            for threshold in INSURANCE_THRESHOLDS:
                if 0 <= days_left <= threshold:
                    title, message = _insurance_texts(
                        label, p.type, days_left, p.valid_until)
                    if _create(db, user_id, car.id, "asigurare_expira",
                               title, message, threshold):
                        created += 1

        for r in db.query(VehicleRegistration).filter(
            VehicleRegistration.car_id == car.id,
            VehicleRegistration.is_active == True,
            VehicleRegistration.itp_expiry_date.isnot(None)
        ).all():
            days_left = (r.itp_expiry_date - today).days
            for threshold in ITP_THRESHOLDS:
                if 0 <= days_left <= threshold:
                    title, message = _expiry_texts(
                        "itp_expira", label, days_left, r.itp_expiry_date)
                    if _create(db, user_id, car.id, "itp_expira",
                               title, message, threshold):
                        created += 1

        if car.mileage:
            for m in db.query(MaintenanceRecord).filter(
                MaintenanceRecord.car_id == car.id,
                MaintenanceRecord.next_service_mileage.isnot(None)
            ).all():
                km_left = m.next_service_mileage - car.mileage
                for threshold in OIL_KM_THRESHOLDS:
                    if 0 <= km_left <= threshold:
                        if _create(db, user_id, car.id, "revizie_km",
                                   f"Revizie apropiata - {label}",
                                   f"Revizia ({m.type}) pentru {label} se apropie. Mai sunt {km_left} km.",
                                   threshold):
                            created += 1

    db.commit()
    return created


def plan_notifications(user_id: str, db: Session) -> list:
    """Momentele viitoare in care telefonul trebuie sa sune, pentru un utilizator.

    Datele de expirare sunt cunoscute dinainte, deci nu e nevoie de un server
    care sa trimita push la momentul potrivit: telefonul isi programeaza singur
    alarmele si le declanseaza chiar si fara internet. Serverul ramane sursa
    unica pentru praguri si texte, ca sa nu ajunga cele doua sa spuna altceva.

    Reviziile pe kilometraj lipsesc deliberat: depind de kilometrajul introdus
    de utilizator, deci nu au o data care sa poata fi calculata in avans. Ele
    raman in lista din aplicatie.
    """
    today = date.today()
    horizon = today + timedelta(days=PLAN_HORIZON_DAYS)
    planned = []

    def add(kind: str, car_id: str, threshold: int, expires_on: date,
            title: str, body: str):
        fire_on = expires_on - timedelta(days=threshold)
        # Ce a trecut deja a fost livrat (sau ratat) - nu-l reprogramam.
        if fire_on < today or fire_on > horizon:
            return
        planned.append({
            # Cheia identifica alarma stabil intre sincronizari. Contine data
            # de expirare: daca utilizatorul o schimba, alarma veche devine
            # alta cheie si nu ramane agatata de o data invalida.
            "key": f"{kind}:{car_id}:{threshold}:{expires_on.isoformat()}",
            "type": kind,
            "car_id": car_id,
            "title": title,
            "body": body,
            "fire_on": fire_on,
        })

    for car in db.query(Car).filter(Car.user_id == user_id).all():
        label = f"{car.brand} {car.model} ({car.license_plate})"

        for v in db.query(Vignette).filter(Vignette.car_id == car.id).all():
            for threshold in VIGNETTE_THRESHOLDS:
                title, body = _expiry_texts(
                    "rovinieta_expira", label, threshold, v.valid_until)
                add("rovinieta_expira", car.id, threshold, v.valid_until, title, body)

        for p in db.query(InsurancePolicy).filter(InsurancePolicy.car_id == car.id).all():
            for threshold in INSURANCE_THRESHOLDS:
                title, body = _insurance_texts(label, p.type, threshold, p.valid_until)
                add("asigurare_expira", car.id, threshold, p.valid_until, title, body)

        for r in db.query(VehicleRegistration).filter(
            VehicleRegistration.car_id == car.id,
            VehicleRegistration.is_active == True,
            VehicleRegistration.itp_expiry_date.isnot(None),
        ).all():
            for threshold in ITP_THRESHOLDS:
                title, body = _expiry_texts(
                    "itp_expira", label, threshold, r.itp_expiry_date)
                add("itp_expira", car.id, threshold, r.itp_expiry_date, title, body)

    planned.sort(key=lambda n: n["fire_on"])
    return planned
