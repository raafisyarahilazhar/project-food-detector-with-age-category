from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import engine, Base
from app.models import scan_history # Import model agar dikenali
Base.metadata.create_all(bind=engine) # Perintah untuk membuat tabel
# =============================

from app.api import scan, dashboard, history 

app = FastAPI()

# ==========================================
# TAMBAHKAN KONFIGURASI CORS INI
# ==========================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Mengizinkan request dari semua origin (browser/port apapun)
    allow_credentials=True,
    allow_methods=["*"],  # Mengizinkan semua method (GET, POST, OPTIONS, PUT, DELETE)
    allow_headers=["*"],  # Mengizinkan semua header
)
# ==========================================

# Daftarkan router kamu (sesuaikan dengan kodemu)
app.include_router(scan.router)
app.include_router(dashboard.router)
app.include_router(history.router)

@app.get("/")
def root():
    return {"message": "API MBG Food Detector Berjalan Lanjay"}