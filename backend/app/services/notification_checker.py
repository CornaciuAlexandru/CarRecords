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
                    if _create(db, user_id, car.id, "rovinieta_expira",
                               f"Rovinieta expira curand - {label}",
                               f"Rovinieta pentru {label} expira in {days_left} zile ({v.valid_until}).",
                               threshold):
                        created += 1

        for p in db.query(InsurancePolicy).filter(InsurancePolicy.car_id == car.id).all():
            days_left = (p.valid_until - today).days
            for threshold in INSURANCE_THRESHOLDS:
                if 0 <= days_left <= threshold:
                    if _create(db, user_id, car.id, "asigurare_expira",
                               f"Asigurare {p.type} expira - {label}",
                               f"Asigurarea {p.type} pentru {label} expira in {days_left} zile ({p.valid_until}).",
                               threshold):
                        created += 1

        for r in db.query(VehicleRegistration).filter(
            VehicleRegistration.car_id == car.id,
            VehicleRegistration.is_active == True,
            VehicleRegistration.itp_expiry_date.isnot(None)
        ).all():
            days_left = (r.itp_expiry_date - today).days
            for threshold in ITP_THRESHOLDS:
                if 0 <= days_left <= threshold:
                    if _create(db, user_id, car.id, "itp_expira",
                               f"ITP expira curand - {label}",
                               f"ITP pentru {label} expira in {days_left} zile ({r.itp_expiry_date}).",
                               threshold):
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
