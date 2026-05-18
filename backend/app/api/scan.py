from fastapi import APIRouter, UploadFile, File, Depends
from sqlalchemy.orm import Session
import shutil
import os
import uuid

from app.core.database import SessionLocal
from app.models.scan_history import ScanHistory
from app.services.yolo_service import detect
from app.services.nutrition_service import get_nutrition
from app.services.analysis_service import analyze

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/scan")
async def scan(file: UploadFile = File(...), db: Session = Depends(get_db)):
    os.makedirs("uploads", exist_ok=True)
    filename = f"{uuid.uuid4()}_{file.filename}"
    path = f"uploads/{filename}"

    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    detections = detect(path)
    results = []

    for d in detections:
        nutrition = get_nutrition(d["label"])
        
        # Jika data nutrisi ditemukan di dataset
        if nutrition:
            analysis = analyze(nutrition)
            status = analysis["status_keseluruhan"]
            
            # Format output sesuai dengan struktur JSON yang diinginkan
            result_data = {
                "makanan": d["label"],
                "confidence": round(d["confidence"], 2),
                "informasi_gizi": nutrition,
                "ringkasan_gizi": analysis["ringkasan_gizi"],
                "status_keseluruhan": status,
                "ringkasan_analisis": analysis["ringkasan_analisis"],
                "rekomendasi": analysis["rekomendasi"],
                "kesimpulan_ai": analysis["kesimpulan_ai"],
                "analisis_detail": analysis["analisis_detail"]
            }
            
        # Jika makanan terdeteksi tapi tidak ada di database nutrisi
        else:
            status = "data_tidak_ditemukan"
            result_data = {
                "makanan": d["label"],
                "confidence": round(d["confidence"], 2),
                "informasi_gizi": None,
                "ringkasan_gizi": None,
                "status_keseluruhan": status,
                "ringkasan_analisis": None,
                "rekomendasi": ["Data nutrisi makanan tidak tersedia"],
                "kesimpulan_ai": "Tidak ada data yang cukup untuk dianalisis.",
                "analisis_detail": []
            }

        # Simpan ke Database
        new_history = ScanHistory(
            image=path,
            food_name=d["label"],
            confidence=float(d["confidence"]),
            overall_status=status,
            result=result_data  # Menyimpan seluruh result_data ke kolom JSON
        )
        db.add(new_history)
        db.commit()
        db.refresh(new_history)

        results.append(result_data)

    return {
        "success": True,
        "total_detection": len(results),
        "data": results
    }