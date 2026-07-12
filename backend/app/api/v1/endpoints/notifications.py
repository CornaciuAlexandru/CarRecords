from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.models.notification import Notification
from app.schemas.notification import NotificationOut
from app.services.notification_checker import check_and_create_notifications

router = APIRouter(prefix="/notifications", tags=["Notificari"])


@router.get("", response_model=List[NotificationOut])
def list_notifications(
    unread_only: bool = False,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = db.query(Notification).filter(Notification.user_id == current_user.id)
    if unread_only:
        query = query.filter(Notification.is_read == False)
    return query.order_by(Notification.triggered_at.desc()).limit(100).all()


@router.post("/check", response_model=dict)
def trigger_notification_check(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    created = check_and_create_notifications(current_user.id, db)
    return {"created": created}


@router.put("/{notif_id}/read", response_model=NotificationOut)
def mark_read(notif_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    n = db.query(Notification).filter(Notification.id == notif_id, Notification.user_id == current_user.id).first()
    if not n:
        raise HTTPException(status_code=404, detail="Notificare negasita")
    n.is_read = True
    db.commit()
    db.refresh(n)
    return n


@router.put("/read-all", status_code=status.HTTP_204_NO_CONTENT)
def mark_all_read(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).update({"is_read": True})
    db.commit()


@router.delete("/{notif_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_notification(notif_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    n = db.query(Notification).filter(Notification.id == notif_id, Notification.user_id == current_user.id).first()
    if not n:
        raise HTTPException(status_code=404, detail="Notificare negasita")
    db.delete(n)
    db.commit()
