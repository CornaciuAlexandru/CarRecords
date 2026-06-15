from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.car import Car
from app.models.registration import VehicleRegistration
from app.schemas.registration import RegistrationCreate, RegistrationUpdate, RegistrationOut
from app.services.ocr import extract_registration_data
from app.utils.file_handler import save_document

router = APIRouter(prefix="/cars/{car_id}/registration", tags=["Talon"])


def get_owned_car(car_id: str, user: User, db: Session) -> Car:
    car = db.query(Car).filter(Car.id == car_id, Car.user_id == user.id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Masina negasita")
    return car


@router.get("", response_model=List[RegistrationOut])
def list_registrations(car_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    return db.query(VehicleRegistration).filter(VehicleRegistration.car_id == car_id).all()


@router.post("", response_model=RegistrationOut, status_code=status.HTTP_201_CREATED)
def create_registration(car_id: str, data: RegistrationCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    reg = VehicleRegistration(car_id=car_id, **data.model_dump())
    db.add(reg)
    db.commit()
    db.refresh(reg)
    return reg


@router.post("/scan", response_model=dict)
async def scan_registration(
    car_id: str,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    get_owned_car(car_id, current_user, db)
    file_path = await save_document(file, current_user.id)
    extracted = await extract_registration_data(file_path)
    return {"file_path": str(file_path), "extracted_data": extracted}


@router.get("/{reg_id}", response_model=RegistrationOut)
def get_registration(car_id: str, reg_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    r = db.query(VehicleRegistration).filter(VehicleRegistration.id == reg_id, VehicleRegistration.car_id == car_id).first()
    if not r:
        raise HTTPException(status_code=404, detail="Talon negasit")
    return r


@router.put("/{reg_id}", response_model=RegistrationOut)
def update_registration(car_id: str, reg_id: str, data: RegistrationUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    r = db.query(VehicleRegistration).filter(VehicleRegistration.id == reg_id, VehicleRegistration.car_id == car_id).first()
    if not r:
        raise HTTPException(status_code=404, detail="Talon negasit")
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(r, field, value)
    db.commit()
    db.refresh(r)
    return r


@router.delete("/{reg_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_registration(car_id: str, reg_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    r = db.query(VehicleRegistration).filter(VehicleRegistration.id == reg_id, VehicleRegistration.car_id == car_id).first()
    if not r:
        raise HTTPException(status_code=404, detail="Talon negasit")
    db.delete(r)
    db.commit()
