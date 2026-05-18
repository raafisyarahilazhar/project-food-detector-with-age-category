Sistem deteksi makanan berbasis Artificial Intelligence menggunakan model YOLO dan aplikasi mobile Flutter untuk membantu identifikasi makanan serta analisis kandungan gizi.

---

# Features

- Deteksi makanan menggunakan model AI (YOLO)
- Backend API menggunakan FastAPI
- Aplikasi mobile multiplatform menggunakan Flutter
- Analisis kandungan nutrisi makanan
- Dataset nutrisi dan aturan kebutuhan gizi
- Support Android, iOS, Windows, Linux, dan Web

---

# Project Structure

```txt
MBG-FOOD-DETECTOR/
│
├── backend/
│   ├── app/
│   │   ├── services/
│   │   └── main.py
│   │
│   ├── data/
│   │   ├── nutrition.json
│   │   ├── age_rules.json
│   │   └── *.csv
│   │
│   ├── models/
│   │   └── food_v1.pt
│   │
│   ├── requirements.txt
│   └── .gitignore
│
├── frontend/
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   ├── linux/
│   ├── macos/
│   ├── pubspec.yaml
│   └── .gitignore
│
└── README.md
```

---

# Tech Stack

## Backend
- Python
- FastAPI
- YOLO
- Uvicorn
- Pandas
- OpenCV

## Frontend
- Flutter
- Dart

---

# Installation

## 1. Clone Repository

```bash
git clone https://github.com/USERNAME/MBG-FOOD-DETECTOR.git
```

```bash
cd MBG-FOOD-DETECTOR
```

---

# Backend Setup

## 1. Masuk ke Folder Backend

```bash
cd backend
```

---

## 2. Buat Virtual Environment

### Windows

```bash
python -m venv venv
```

### Linux / MacOS

```bash
python3 -m venv venv
```

---

## 3. Aktifkan Virtual Environment

### Windows

```bash
venv\Scripts\activate
```

### Linux / MacOS

```bash
source venv/bin/activate
```

---

## 4. Install Dependency

```bash
pip install -r requirements.txt
```

---

## 5. Run Backend Server

```bash
uvicorn app.main:app --reload
```

Backend akan berjalan di:

```txt
http://127.0.0.1:8000
```

---

# Frontend Setup

## 1. Masuk ke Folder Frontend

```bash
cd frontend
```

---

## 2. Install Dependency Flutter

```bash
flutter pub get
```

---

## 3. Jalankan Aplikasi

```bash
flutter run
```

---

# API Documentation

Setelah backend berjalan, dokumentasi API tersedia di:

```txt
http://127.0.0.1:8000/docs
```

---

# Model AI

Model AI menggunakan file:

```txt
backend/models/food_v1.pt
```

Model digunakan untuk melakukan deteksi objek makanan menggunakan YOLO.

---

# Dataset

Dataset nutrisi tersedia pada folder:

```txt
backend/data/
```

Berisi:
- dataset nutrisi makanan
- aturan kebutuhan gizi berdasarkan usia
- dataset vitamin dan mineral

---

# Supported Platforms

Frontend Flutter mendukung:

- Android
- iOS
- Windows
- Linux
- macOS
- Web

---

# Development Notes

Folder berikut tidak di-push ke GitHub karena merupakan generated files.

## Backend
- `venv/`
- `temp/`
- `uploads/`

## Frontend
- `.dart_tool/`
- `build/`

---
