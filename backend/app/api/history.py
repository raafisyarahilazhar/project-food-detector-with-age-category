from fastapi import APIRouter

from app.core.database import SessionLocal
from app.models.scan_history import ScanHistory

router = APIRouter(prefix="/history")


@router.get("")
def get_history():

    db = SessionLocal()

    histories = db.query(ScanHistory).order_by(
        ScanHistory.id.desc()
    ).all()

    data = []

    for h in histories:

        data.append({
            "id": h.id,
            "image": h.image,
            "food_name": h.food_name,
            "confidence": h.confidence,
            "overall_status": h.overall_status,
            "created_at": h.created_at
        })

    db.close()

    return {
        "success": True,
        "data": data
    }


@router.get("/{history_id}")
def detail_history(history_id: int):

    db = SessionLocal()

    history = db.query(ScanHistory).filter(
        ScanHistory.id == history_id
    ).first()

    db.close()

    if not history:

        return {
            "success": False,
            "message": "Riwayat tidak ditemukan"
        }

    return {
        "success": True,
        "data": history.result
    }