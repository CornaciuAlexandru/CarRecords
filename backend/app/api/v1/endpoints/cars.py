from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.car import Car
from app.schemas.car import CarCreate, CarUpdate, CarOut

router = APIRouter(prefix="/cars", tags=["Masini"])


def get_car_or_404(car_id: str, user: User, db: Session) -> Car:
    car = db.query(Car).filter(Car.id == car_id, Car.user_id == user.id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Masina negasita")
    return car


@router.get("", response_model=List[CarOut])
def list_cars(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return db.query(Car).filter(Car.user_id == current_user.id).all()


@router.post("", response_model=CarOut, status_code=status.HTTP_201_CREATED)
def create_car(data: CarCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    car_count = db.query(Car).filter(Car.user_id == current_user.id).count()
    if car_count >= current_user.max_cars:
        raise HTTPException(
            status_code=400,
            detail=f"Limita de {current_user.max_cars} masini atinsa. Upgradeaza abonamentul."
        )

    car = Car(user_id=current_user.id, **data.model_dump())
    db.add(car)
    db.commit()
    db.refresh(car)
    return car


@router.get("/{car_id}", response_model=CarOut)
def get_car(car_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return get_car_or_404(car_id, current_user, db)


@router.put("/{car_id}", response_model=CarOut)
def update_car(car_id: str, data: CarUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    car = get_car_or_404(car_id, current_user, db)
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(car, field, value)
    db.commit()
    db.refresh(car)
    return car


@router.delete("/{car_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_car(car_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    car = get_car_or_404(car_id, current_user, db)
    db.delete(car)
    db.commit()
