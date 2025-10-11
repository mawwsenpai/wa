# ==============================================================================
# main.py (Versi Lengkap, Stabil, dan Aman untuk Produksi)
# Oleh: Gemini
# ==============================================================================

# ==============================================================================
# Bagian 1: IMPORT SEMUA LIBRARY YANG DIBUTUHKAN
# ==============================================================================
# Library standar untuk API
import uvicorn
from fastapi import FastAPI, Depends, HTTPException, status
from typing import List

# Library untuk Database (SQLAlchemy ORM)
from sqlalchemy import create_engine, Column, Integer, String, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

# Library untuk Validasi Data (Pydantic)
from pydantic import BaseModel, EmailStr

# --- [BAGIAN PENTING] Library untuk Keamanan Password ---
from passlib.context import CryptContext

# ==============================================================================
# Bagian 2: KONFIGURASI DAN SETUP DATABASE (Stabil)
# ==============================================================================
# URL database SQLite. File akan otomatis dibuat di folder yang sama.
SQLALCHEMY_DATABASE_URL = "sqlite:///./app_database.db"

# Buat 'engine' SQLAlchemy dengan connect_args khusus untuk SQLite
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# Buat class SessionLocal untuk membuat sesi database
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class untuk semua model SQLAlchemy. Ini wajib ada.
Base = declarative_base()

# ==============================================================================
# Bagian 3: SETUP KEAMANAN PASSWORD
# ==============================================================================
# Menggunakan bcrypt sebagai skema hashing, ini standar yang kuat
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ==============================================================================
# Bagian 4: SQLAlchemy MODELS (Struktur Tabel Database)
# ==============================================================================
# Model ini akan menjadi tabel 'users' di database
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False) # Nama kolom jelas
    is_active = Column(Boolean, default=True)

# ==============================================================================
# Bagian 5: Pydantic SCHEMAS (Validasi Data API)
# ==============================================================================
# Schema dasar untuk User
class UserBase(BaseModel):
    email: EmailStr

# Schema untuk membuat user baru (membutuhkan password)
class UserCreate(UserBase):
    password: str

# Schema untuk menampilkan data user (tanpa password)
class UserSchema(UserBase):
    id: int
    is_active: bool

    class Config:
        orm_mode = True # Agar bisa baca data dari objek ORM

# ==============================================================================
# Bagian 6: INISIALISASI APLIKASI FASTAPI
# ==============================================================================
# Membuat tabel di database (jika belum ada) saat aplikasi pertama kali jalan
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="API Stabil Anti Rewel",
    description="Contoh API lengkap, utuh, dan stabil dalam satu file.",
    version="3.0.0" # Versi final
)

# ==============================================================================
# Bagian 7: FUNGSI BANTUAN & LOGIKA BISNIS
# ==============================================================================

# --- Fungsi Keamanan ---
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

# --- Dependency untuk Database Session (PENTING!) ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- Fungsi CRUD (Create, Read, Update, Delete) ---
def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_all_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(User).offset(skip).limit(limit).all()

def create_user_db(db: Session, user: UserCreate):
    # --- [PERBAIKAN KRUSIAL] Password di-hash sebelum disimpan ---
    hashed_password = get_password_hash(user.password)
    db_user = User(email=user.email, hashed_password=hashed_password)
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# ==============================================================================
# Bagian 8: API ENDPOINTS (Rute-rute API)
# ==============================================================================
# Endpoint root untuk cek apakah API berjalan
@app.get("/", tags=["Status"])
def read_root():
    return {"status": "API berjalan dengan lancar dan stabil, cuy!"}

# Endpoint untuk membuat user baru
@app.post("/users/", response_model=UserSchema, status_code=status.HTTP_201_CREATED, tags=["Users"])
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email sudah terdaftar, coba email lain."
        )
    return create_user_db(db=db, user=user)

# Endpoint untuk mengambil semua data user
@app.get("/users/", response_model=List[UserSchema], tags=["Users"])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = get_all_users(db, skip=skip, limit=limit)
    return users

