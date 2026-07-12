from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.car import Car
from app.models.vignette import Vignette
from app.schemas.vignette import VignetteCreate, VignetteUpdate, VignetteOut
from app.services.ocr import extract_vignette_data
from app.utils.file_handler import save_document

router = APIRouter(prefix="/cars/{car_id}/vignettes", tags=["Roviniete"])


def get_owned_car(car_id: str, user: User, db: Session) -> Car:
    car = db.query(Car).filter(Car.id == car_id, Car.user_id == user.id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Masina negasita")
    return car


@router.get("", response_model=List[VignetteOut])
def list_vignettes(car_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    return db.query(Vignette).filter(Vignette.car_id == car_id).order_by(Vignette.valid_until.desc()).all()


@router.post("", response_model=VignetteOut, status_code=status.HTTP_201_CREATED)
def create_vignette(
    car_id: str,
    data: VignetteCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    get_owned_car(car_id, current_user, db)
    vignette = Vignette(car_id=car_id, **data.model_dump())
    db.add(vignette)
    db.commit()
    db.refresh(vignette)
    return vignette


@router.post("/scan", response_model=dict)
async def scan_vignette(
    car_id: str,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    get_owned_car(car_id, current_user, db)
    file_path = await save_document(file, current_user.id)
    extracted = await extract_vignette_data(file_path)
    return {"file_path": str(file_path), "extracted_data": extracted}


@router.get("/{vignette_id}", response_model=VignetteOut)
def get_vignette(car_id: str, vignette_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    v = db.query(Vignette).filter(Vignette.id == vignette_id, Vignette.car_id == car_id).first()
    if not v:
        raise HTTPException(status_code=404, detail="Rovinieta negasita")
    return v


@router.put("/{vignette_id}", response_model=VignetteOut)
def update_vignette(
    car_id: str, vignette_id: str, data: VignetteUpdate,
    current_user: User = Depends(get_current_user), db: Session = Depends(get_db),
):
    get_owned_car(car_id, current_user, db)
    v = db.query(Vignette).filter(Vignette.id == vignette_id, Vignette.car_id == car_id).first()
    if not v:
        raise HTTPException(status_code=404, detail="Rovinieta negasita")
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(v, field, value)
    db.commit()
    db.refresh(v)
    return v


@router.delete("/{vignette_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_vignette(car_id: str, vignette_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    v = db.query(Vignette).filter(Vignette.id == vignette_id, Vignette.car_id == car_id).first()
    if not v:
        raise HTTPException(status_code=404, detail="Rovinieta negasita")
    db.delete(v)
    db.commit()
