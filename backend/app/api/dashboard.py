from fastapi import APIRouter

from app.core.database import SessionLocal
from app.models.scan_history import ScanHistory

router = APIRouter(prefix="/dashboard")


@router.get("")
def dashboard_summary():

    db = SessionLocal()

    total_scan = db.query(ScanHistory).count()

    makanan_aman = db.query(ScanHistory).filter(
        ScanHistory.overall_status == "relatif_aman"
    ).count()

    # dashboard.py
    makanan_berisiko = db.query(ScanHistory).filter(
        ScanHistory.overall_status.in_(["berisiko_tinggi", "cukup_berisiko"])
    ).count()

    makanan_tidak_diketahui = db.query(ScanHistory).filter(
        ScanHistory.overall_status == "data_tidak_ditemukan"
    ).count()

    return {
        "success": True,
        "data": {
            "total_scan": total_scan,
            "makanan_aman": makanan_aman,
            "makanan_berisiko": makanan_berisiko,
            "makanan_tidak_diketahui": makanan_tidak_diketahui
        }
    }