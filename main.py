# main.py

# ==============================================================================
# Bagian 1: IMPORT SEMUA LIBRARY YANG DIBUTUHKAN
# ==============================================================================
# Pastikan semua ini sudah di-install dengan `pip install fastapi "uvicorn[standard]" sqlalchemy pydantic`
import uvicorn
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy import create_engine, Column, Integer, String, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel, EmailStr
from typing import List # Diperlukan untuk response model list

# ==============================================================================
# Bagian 2: KONFIGURASI DAN SETUP DATABASE (Stabil)
# ==============================================================================
# URL database SQLite. File akan otomatis dibuat di folder yang sama.
SQLALCHEMY_DATABASE_URL = "sqlite:///./app_database.db"

# Buat 'engine' SQLAlchemy dengan connect_args untuk SQLite
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# Buat class SessionLocal untuk membuat sesi database
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class untuk semua model SQLAlchemy. Ini wajib ada.
Base = declarative_base()

# ==============================================================================
# Bagian 3: SQLAlchemy MODELS (Struktur Tabel Database)
# ==============================================================================
# Model ini akan menjadi tabel 'users' di database
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)

# ==============================================================================
# Bagian 4: Pydantic SCHEMAS (Validasi Data API)
# ==============================================================================
# Schema dasar untuk User
class UserBase(BaseModel):
    email: EmailStr

# Schema untuk membuat user baru (membutuhkan password)
class UserCreate(UserBase):
    password: str

# Schema untuk menampilkan data user (tanpa password)
# Ini yang akan dikirim sebagai response ke client
class UserSchema(UserBase):
    id: int
    is_active: bool

    class Config:
        orm_mode = True

# ==============================================================================
# Bagian 5: INISIALISASI APLIKASI FASTAPI
# ==============================================================================
# Membuat tabel di database (jika belum ada) saat aplikasi pertama kali jalan
# Ini adalah langkah penting!
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="API Stabil Anti Rewel",
    description="Contoh API lengkap, utuh, dan stabil dalam satu file.",
    version="2.0.0"
)

# ==============================================================================
# Bagian 6: DEPENDENCY UNTUK DATABASE SESSION (Penting!)
# ==============================================================================
# Fungsi ini adalah 'nyawa' dari koneksi database kita.
# Dia akan membuka koneksi saat endpoint dipanggil dan otomatis menutupnya setelah selesai.
# Ini mencegah kebocoran koneksi dan membuat aplikasi lebih stabil.
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==============================================================================
# Bagian 7: FUNGSI BANTUAN / REPOSITORY (Logika Bisnis)
# ==============================================================================
# Memisahkan logika database dari endpoint membuat kode lebih bersih

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_all_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(User).offset(skip).limit(limit).all()

def create_user_db(db: Session, user: UserCreate):
    # Di aplikasi production, JANGAN PERNAH simpan password mentah!
    # Gunakan library seperti passlib. bcrypt.hash(user.password)
    fake_hashed_password = user.password + "hashbuatcontoh"
    
    db_user = User(email=user.email, hashed_password=fake_hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# ==============================================================================
# Bagian 8: API ENDPOINTS (Rute-rute API)
# ==============================================================================
# Endpoint root untuk cek apakah API berjalan
@app.get("/")
def read_root():
    return {"status": "API berjalan dengan lancar, cuy!"}

# Endpoint untuk membuat user baru
@app.post("/users/", response_model=UserSchema, status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email sudah terdaftar, coba email lain."
        )
    return create_user_db(db=db, user=user)

# Endpoint untuk mengambil semua data user
@app.get("/users/", response_model=List[UserSchema])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = get_all_users(db, skip=skip, limit=limit)
    return users
