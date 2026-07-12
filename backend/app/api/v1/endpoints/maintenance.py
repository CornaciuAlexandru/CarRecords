from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.car import Car
from app.models.maintenance import MaintenanceRecord
from app.schemas.maintenance import MaintenanceCreate, MaintenanceUpdate, MaintenanceOut

router = APIRouter(prefix="/cars/{car_id}/maintenance", tags=["Mentenanta"])


def get_owned_car(car_id: str, user: User, db: Session) -> Car:
    car = db.query(Car).filter(Car.id == car_id, Car.user_id == user.id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Masina negasita")
    return car


@router.get("", response_model=List[MaintenanceOut])
def list_maintenance(car_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    return db.query(MaintenanceRecord).filter(MaintenanceRecord.car_id == car_id).order_by(MaintenanceRecord.performed_date.desc()).all()


@router.post("", response_model=MaintenanceOut, status_code=status.HTTP_201_CREATED)
def create_maintenance(car_id: str, data: MaintenanceCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    record = MaintenanceRecord(car_id=car_id, **data.model_dump())
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


@router.get("/{record_id}", response_model=MaintenanceOut)
def get_maintenance(car_id: str, record_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    r = db.query(MaintenanceRecord).filter(MaintenanceRecord.id == record_id, MaintenanceRecord.car_id == car_id).first()
    if not r:
        raise HTTPException(status_code=404, detail="Inregistrare negasita")
    return r


@router.put("/{record_id}", response_model=MaintenanceOut)
def update_maintenance(car_id: str, record_id: str, data: MaintenanceUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    r = db.query(MaintenanceRecord).filter(MaintenanceRecord.id == record_id, MaintenanceRecord.car_id == car_id).first()
    if not r:
        raise HTTPException(status_code=404, detail="Inregistrare negasita")
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(r, field, value)
    db.commit()
    db.refresh(r)
    return r


@router.delete("/{record_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_maintenance(car_id: str, record_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    r = db.query(MaintenanceRecord).filter(MaintenanceRecord.id == record_id, MaintenanceRecord.car_id == car_id).first()
    if not r:
        raise HTTPException(status_code=404, detail="Inregistrare negasita")
    db.delete(r)
    db.commit()
