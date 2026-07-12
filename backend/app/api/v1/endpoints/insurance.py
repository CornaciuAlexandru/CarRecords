from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.car import Car
from app.models.insurance import InsurancePolicy
from app.schemas.insurance import InsuranceCreate, InsuranceUpdate, InsuranceOut
from app.services.ocr import extract_insurance_data
from app.utils.file_handler import save_document

router = APIRouter(prefix="/cars/{car_id}/insurance", tags=["Asigurari"])


def get_owned_car(car_id: str, user: User, db: Session) -> Car:
    car = db.query(Car).filter(Car.id == car_id, Car.user_id == user.id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Masina negasita")
    return car


@router.get("", response_model=List[InsuranceOut])
def list_insurance(car_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    return db.query(InsurancePolicy).filter(InsurancePolicy.car_id == car_id).order_by(InsurancePolicy.valid_until.desc()).all()


@router.post("", response_model=InsuranceOut, status_code=status.HTTP_201_CREATED)
def create_insurance(car_id: str, data: InsuranceCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    policy = InsurancePolicy(car_id=car_id, **data.model_dump())
    db.add(policy)
    db.commit()
    db.refresh(policy)
    return policy


@router.post("/scan", response_model=dict)
async def scan_insurance(
    car_id: str,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    get_owned_car(car_id, current_user, db)
    file_path = await save_document(file, current_user.id)
    extracted = await extract_insurance_data(file_path)
    return {"file_path": str(file_path), "extracted_data": extracted}


@router.get("/{policy_id}", response_model=InsuranceOut)
def get_insurance(car_id: str, policy_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    p = db.query(InsurancePolicy).filter(InsurancePolicy.id == policy_id, InsurancePolicy.car_id == car_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Asigurare negasita")
    return p


@router.put("/{policy_id}", response_model=InsuranceOut)
def update_insurance(car_id: str, policy_id: str, data: InsuranceUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    p = db.query(InsurancePolicy).filter(InsurancePolicy.id == policy_id, InsurancePolicy.car_id == car_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Asigurare negasita")
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(p, field, value)
    db.commit()
    db.refresh(p)
    return p


@router.delete("/{policy_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_insurance(car_id: str, policy_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    get_owned_car(car_id, current_user, db)
    p = db.query(InsurancePolicy).filter(InsurancePolicy.id == policy_id, InsurancePolicy.car_id == car_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Asigurare negasita")
    db.delete(p)
    db.commit()
