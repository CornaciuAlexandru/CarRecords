from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.car import Car
from app.models.modification import CarModification
from app.schemas.modification import ModificationCreate, ModificationUpdate, ModificationOut
from app.utils.file_handler import save_photo

router = APIRouter(prefix="/cars/{car_id}/modifications", tags=["Modificari"])


def get_owned_car(car_id: str, user: User, db: Session) -> Car:
    car = db.query(Car).filter(Car.id == car_id, Car.user_id == user.id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Masina negasita")
    return car


@router.get("", response_model=List[ModificationOut])
def list_modifications(car_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    return db.query(CarModification).filter(CarModification.car_id == car_id).order_by(CarModification.created_at.desc()).all()


@router.post("", response_model=ModificationOut, status_code=status.HTTP_201_CREATED)
def create_modification(car_id: str, data: ModificationCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    mod = CarModification(car_id=car_id, **data.model_dump())
    db.add(mod)
    db.commit()
    db.refresh(mod)
    return mod


@router.post("/{mod_id}/photos", response_model=dict)
async def upload_photo(
    car_id: str, mod_id: str,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    get_owned_car(car_id, current_user, db)
    mod = db.query(CarModification).filter(CarModification.id == mod_id, CarModification.car_id == car_id).first()
    if not mod:
        raise HTTPException(status_code=404, detail="Modificare negasita")

    file_path = await save_photo(file, current_user.id)
    # Stocheaza URL relativ in loc de cale absoluta, pentru servire prin /photos
    relative_url = f"/{current_user.id}/{file_path.name}"
    photos = list(mod.photos or [])
    photos.append(relative_url)
    mod.photos = photos
    db.commit()
    return {"photo_url": relative_url}


@router.get("/{mod_id}", response_model=ModificationOut)
def get_modification(car_id: str, mod_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    m = db.query(CarModification).filter(CarModification.id == mod_id, CarModification.car_id == car_id).first()
    if not m:
        raise HTTPException(status_code=404, detail="Modificare negasita")
    return m


@router.put("/{mod_id}", response_model=ModificationOut)
def update_modification(car_id: str, mod_id: str, data: ModificationUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    m = db.query(CarModification).filter(CarModification.id == mod_id, CarModification.car_id == car_id).first()
    if not m:
        raise HTTPException(status_code=404, detail="Modificare negasita")
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(m, field, value)
    db.commit()
    db.refresh(m)
    return m


@router.delete("/{mod_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_modification(car_id: str, mod_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    m = db.query(CarModification).filter(CarModification.id == mod_id, CarModification.car_id == car_id).first()
    if not m:
        raise HTTPException(status_code=404, detail="Modificare negasita")
    db.delete(m)
    db.commit()
