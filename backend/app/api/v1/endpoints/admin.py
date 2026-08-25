from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from app.core.database import get_db
from app.core.deps import get_current_admin
from app.models.user import User
from app.models.car import Car
from app.models.vignette import Vignette
from app.models.insurance import InsurancePolicy
from app.models.registration import VehicleRegistration
from app.models.maintenance import MaintenanceRecord
from app.models.modification import CarModification
from app.schemas.user import UserOut, AdminUserUpdate
from app.utils.file_handler import delete_user_files


class AdminUserOut(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str]
    role: str
    is_active: bool
    subscription_tier: str
    max_cars: int
    created_at: datetime
    car_count: int
    records_count: int

    model_config = {"from_attributes": True}

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/stats", response_model=dict)
def get_stats(db: Session = Depends(get_db), _: User = Depends(get_current_admin)):
    return {
        "total_users": db.query(func.count(User.id)).scalar(),
        "active_users": db.query(func.count(User.id)).filter(User.is_active == True).scalar(),
        "premium_users": db.query(func.count(User.id)).filter(User.subscription_tier == "premium").scalar(),
        "total_cars": db.query(func.count(Car.id)).scalar(),
        "total_vignettes": db.query(func.count(Vignette.id)).scalar(),
        "total_insurance_policies": db.query(func.count(InsurancePolicy.id)).scalar(),
    }


@router.get("/users", response_model=List[AdminUserOut])
def list_users(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_admin),
):
    users = db.query(User).order_by(User.created_at.desc()).offset(skip).limit(limit).all()
    result = []
    for user in users:
        car_ids = [c.id for c in db.query(Car.id).filter(Car.user_id == user.id).all()]
        car_count = len(car_ids)
        records_count = 0
        if car_ids:
            records_count = (
                db.query(func.count(Vignette.id)).filter(Vignette.car_id.in_(car_ids)).scalar() +
                db.query(func.count(InsurancePolicy.id)).filter(InsurancePolicy.car_id.in_(car_ids)).scalar() +
                db.query(func.count(VehicleRegistration.id)).filter(VehicleRegistration.car_id.in_(car_ids)).scalar() +
                db.query(func.count(MaintenanceRecord.id)).filter(MaintenanceRecord.car_id.in_(car_ids)).scalar() +
                db.query(func.count(CarModification.id)).filter(CarModification.car_id.in_(car_ids)).scalar()
            )
        result.append(AdminUserOut(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            phone=user.phone,
            role=user.role,
            is_active=user.is_active,
            subscription_tier=user.subscription_tier,
            max_cars=user.max_cars,
            created_at=user.created_at,
            car_count=car_count,
            records_count=records_count,
        ))
    return result


@router.get("/users/{user_id}", response_model=UserOut)
def get_user(user_id: str, db: Session = Depends(get_db), _: User = Depends(get_current_admin)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilizator negasit")
    return user


@router.put("/users/{user_id}", response_model=UserOut)
def update_user(
    user_id: str,
    data: AdminUserUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilizator negasit")
    if user.id == admin.id:
        raise HTTPException(status_code=400, detail="Nu te poti modifica pe tine insuti din admin")

    for field, value in data.model_dump(exclude_none=True).items():
        setattr(user, field, value)
    db.commit()
    db.refresh(user)
    return user


@router.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(user_id: str, db: Session = Depends(get_db), admin: User = Depends(get_current_admin)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilizator negasit")
    if user.id == admin.id:
        raise HTTPException(status_code=400, detail="Nu te poti sterge pe tine insuti")
    db.delete(user)
    db.commit()
    delete_user_files(user_id)


@router.get("/users/{user_id}/cars", response_model=List[dict])
def get_user_cars(user_id: str, db: Session = Depends(get_db), _: User = Depends(get_current_admin)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilizator negasit")
    cars = db.query(Car).filter(Car.user_id == user_id).all()
    return [{"id": c.id, "brand": c.brand, "model": c.model, "year": c.year,
             "license_plate": c.license_plate} for c in cars]
