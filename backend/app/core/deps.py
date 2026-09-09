from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.core import entitlements
from app.core.database import get_db
from app.core.security import decode_token
from app.models.user import User

bearer_scheme = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> User:
    token = credentials.credentials
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token invalid")

    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id, User.is_active == True).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Utilizator negasit")
    # Tokenurile emise inainte de ultima schimbare de parola sunt refuzate.
    # Tokenurile vechi, fara "tv", si conturile nemigrate au versiunea 0.
    if (payload.get("tv") or 0) != (user.token_version or 0):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Sesiune incheiata. Autentifica-te din nou.")
    return user


def get_current_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Acces interzis")
    return current_user


# ── Scanari OCR ──────────────────────────────────────────────────────

def ensure_can_scan(user: User, car) -> None:
    """Opreste scanarea daca s-au terminat scanarile disponibile.

    Se cheama INAINTE de OCR: acolo se consuma procesorul, si n-are rost sa fie
    ars pentru o cerere care oricum s-ar respinge la final.

    402 (Payment Required) e ales intentionat: aplicatia il deosebeste de un 403
    si poate arata oferta de cumparare in loc de un mesaj de eroare.
    """
    if entitlements.can_scan(user, car):
        return
    raise HTTPException(
        status_code=status.HTTP_402_PAYMENT_REQUIRED,
        detail=(
            f"Ai folosit cele {entitlements.SCANS_PER_CAR} scanari incluse cu "
            "aceasta masina. Poti cumpara scanari separat."
        ),
    )


def charge_scan(user: User, car, db: Session) -> None:
    """Scade o scanare si salveaza.

    Se cheama DUPA ce scanarea a intors ceva. O poza din care nu s-a putut citi
    nimic nu se plateste: esecul e al nostru, nu al utilizatorului.
    """
    if entitlements.consume_scan(user, car):
        db.commit()
