from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core import billing, entitlements
from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.purchase import Purchase
from app.models.user import User
from app.schemas.user import UserOut

router = APIRouter(prefix="/billing", tags=["Plati"])


class VerifyRequest(BaseModel):
    product_id: str = Field(max_length=100)
    # Chitanta primita de la magazin, in aplicatie. Serverul nu are incredere
    # in nimic altceva din aceasta cerere.
    purchase_token: str = Field(max_length=2048)


@router.get("/catalog", response_model=list)
def catalog():
    """Planurile si pachetele, pentru ecranul de cumparare.

    Public: preturile nu sunt un secret, iar ecranul trebuie sa se poata afisa
    si inainte de autentificare.
    """
    return billing.catalog_for_client()


@router.post("/verify", response_model=UserOut)
def verify(
    data: VerifyRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Verifica o chitanta la Google si acorda ce s-a cumparat.

    Singura cale prin care un cont urca pe alt plan sau primeste scanari.
    Aplicatia nu poate cere direct "fa-ma PRO": trimite chitanta, iar serverul
    intreaba magazinul.
    """
    product = billing.CATALOG.get(data.product_id)
    if not product:
        raise HTTPException(status_code=400, detail="Produs necunoscut")

    # Chitanta folosita deja. Verificarea inainte de a intreba Google scuteste
    # o cerere, dar apararea reala e indexul unic de mai jos - intre citire si
    # scriere incap doua cereri trimise in acelasi moment.
    if db.query(Purchase).filter(Purchase.store_token == data.purchase_token).first():
        raise HTTPException(status_code=409, detail="Chitanta a fost deja folosita")

    try:
        valid = billing.verify_purchase(product, data.purchase_token)
    except billing.BillingUnavailable as e:
        # Nu acordam nimic cand nu putem verifica. Un abonament dat din greseala
        # nu se mai ia inapoi, iar utilizatorul poate reincerca peste un minut.
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Verificarea platii nu e disponibila acum: {e}",
        )
    if not valid:
        raise HTTPException(status_code=400, detail="Chitanta nu e valabila")

    purchase = Purchase(
        user_id=current_user.id,
        product_id=product.product_id,
        kind=product.kind,
        store_token=data.purchase_token,
        granted_tier=product.tier,
        granted_scans=product.scans,
    )
    db.add(purchase)

    if product.kind == billing.SUBSCRIPTION:
        current_user.subscription_tier = product.tier
        current_user.max_cars = entitlements.max_cars_for_tier(product.tier)
    else:
        current_user.scan_credits = entitlements.scan_credits(current_user) + product.scans

    try:
        db.commit()
    except IntegrityError:
        # Doua cereri cu aceeasi chitanta, in acelasi moment. Indexul unic pe
        # store_token o opreste pe a doua, si nimic nu se acorda de doua ori.
        db.rollback()
        raise HTTPException(status_code=409, detail="Chitanta a fost deja folosita")

    db.refresh(current_user)
    return current_user
