# main.py

# ==============================================================================
# Bagian 1: IMPORT SEMUA LIBRARY YANG DIBUTUHKAN
# ==============================================================================
import uvicorn
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import create_engine, Column, Integer, String, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel, EmailStr

# ==============================================================================
# Bagian 2: KONFIGURASI DAN SETUP DATABASE (dari database.py)
# ==============================================================================
# URL untuk koneksi ke database SQLite. File database akan bernama `sql_app.db`.
SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"

# Membuat 'engine' SQLAlchemy
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# Membuat class SessionLocal untuk sesi database
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class untuk model SQLAlchemy. Semua model akan mewarisi class ini.
Base = declarative_base()

# ==============================================================================
# Bagian 3: SQLAlchemy MODELS (Struktur Tabel Database) (dari models.py)
# ==============================================================================
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)

# ==============================================================================
# Bagian 4: Pydantic SCHEMAS (Bentuk Data API) (dari schemas.py)
# ==============================================================================
# Schema dasar untuk User, berisi data yang sama-sama dimiliki
class UserBase(BaseModel):
    email: EmailStr

# Schema untuk membuat user baru, butuh password
class UserCreate(UserBase):
    password: str

# Schema untuk membaca/menampilkan data user, password tidak disertakan demi keamanan
class User(UserBase):
    id: int
    is_active: bool

    class Config:
        orm_mode = True

# ==============================================================================
# Bagian 5: INISIALISASI APLIKASI FASTAPI & PEMBUATAN TABEL
# ==============================================================================
# Membuat instance aplikasi FastAPI
app = FastAPI(
    title="Aplikasi User Lengkap",
    description="Contoh API lengkap dalam satu file main.py",
    version="1.0.0"
)

# Perintah ini akan membuat tabel 'users' di database jika belum ada
Base.metadata.create_all(bind=engine)

# ==============================================================================
# Bagian 6: DEPENDENCY untuk Sesi Database
# ==============================================================================
# Fungsi ini akan 'menyuntikkan' sesi database ke setiap request API
# dan akan otomatis menutup sesi setelah request selesai.
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==============================================================================
# Bagian 7: FUNGSI BANTUAN / LOGIKA BISNIS (CRUD Operations)
# ==============================================================================
def get_user_by_email(db: Session, email: str):
    """Fungsi untuk mencari user berdasarkan email."""
    return db.query(User).filter(User.email == email).first()

def create_user_db(db: Session, user: UserCreate):
    """
    Fungsi untuk membuat user baru di database.
    CATATAN PENTING: Di aplikasi nyata, JANGAN simpan password sebagai plain text.
    Gunakan library seperti passlib untuk hashing. Ini hanya contoh.
    """
    # Contoh hashing password yang sangat sederhana (JANGAN DITIRU DI PRODUKSI)
    fake_hashed_password = user.password + "notreallyhashed"
    
    db_user = User(email=user.email, hashed_password=fake_hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# ==============================================================================
# Bagian 8: API ENDPOINTS (Rute API)
# ==============================================================================
@app.get("/")
def read_root():
    """Endpoint utama untuk menyapa."""
    return {"message": "Selamat datang di API User Lengkap!"}

@app.post("/users/", response_model=User)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    """
    Endpoint untuk membuat user baru.
    - Menerima data user (email & password) sesuai schema UserCreate.
    - Menggunakan dependency get_db untuk mendapatkan sesi database.
    - Mengembalikan data user sesuai schema User (tanpa password).
    """
    db_user = get_user_by_email(db, email=user.email)
    if db_user:
        # Jika email sudah terdaftar, kembalikan error 400
        raise HTTPException(status_code=400, detail="Email sudah terdaftar")
    
    # Jika email belum ada, panggil fungsi untuk membuat user baru
    return create_user_db(db=db, user=user)

# ==============================================================================
# Bagian 9: (Opsional) Menjalankan server dengan Uvicorn jika file ini dieksekusi
# ==============================================================================
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)

