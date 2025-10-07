# --- installer.py ---
# VERSI 4.1 - Edisi UI Cerdas & Rawat Diri

import sys
import subprocess
from importlib import metadata

# --- DAFTAR BELANJA / DEPENDENSI YANG DIBUTUHKAN ---
REQUIRED_PACKAGES = [
    "google-generativeai",
    "pywhatkit",
    "setuptools" 
]

def upgrade_installer_tools():
    """Meng-upgrade pip dan setuptools ke versi terbaru."""
    print("🛠️  Memeriksa dan merawat alat instalasi (pip & setuptools)...")
    try:
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--upgrade", "pip", "setuptools"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        print("   -> Alat instalasi sudah dalam versi terbaru.")
        return True
    except subprocess.CalledProcessError:
        print("   -> Peringatan: Gagal meng-upgrade alat instalasi. Melanjutkan...")
        # Kita tidak menghentikan program di sini, karena mungkin masih bisa jalan
        return False

def check_package(package_name):
    """Mengecek satu package, mengembalikan True jika ada, False jika tidak ada."""
    try:
        metadata.version(package_name)
        return True
    except metadata.PackageNotFoundError:
        return False

def install_package(package_name):
    """Menginstal satu package menggunakan pip dengan output yang bersih."""
    try:
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--upgrade", package_name],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        return True
    except subprocess.CalledProcessError:
        return False

def run_smart_installer():
    """Fungsi utama dengan UI yang bersih dan logika yang cerdas."""
    print("==============================================")
    print("      🚀 Asisten AI - Pengecekan Sistem      ")
    print("==============================================")
    
    # Jalankan fungsi perawatan diri dulu
    upgrade_installer_tools()
    
    to_install = []
    already_installed = []

    # --- TAHAP ANALISIS ---
    print("\n🔍 Menganalisis dependensi yang dibutuhkan...")
    for package in REQUIRED_PACKAGES:
        if check_package(package):
            already_installed.append(package)
        else:
            to_install.append(package)
    
    # --- TAHAP LAPORAN ---
    print("\n--- Laporan Status ---")
    for package in already_installed:
        print(f"  [✅] {package:25} -> OK!")
    
    if not to_install:
        print("\n✨ Semua dependensi sudah lengkap. Sistem siap!")
        print("----------------------------------------------")
        return True
        
    for package in to_install:
        print(f"  [📦] {package:25} -> Perlu diinstal")

    # --- TAHAP EKSEKUSI ---
    print("\n--- Memulai Proses Instalasi ---")
    all_success = True
    for package in to_install:
        sys.stdout.write(f"  -> Menginstal {package}...")
        sys.stdout.flush()
        
        if install_package(package):
            sys.stdout.write(" -> BERHASIL!\n")
        else:
            sys.stdout.write(" -> GAGAL!\n")
            all_success = False

    print("----------------------------------------------")
    if all_success:
        print("✨ Instalasi selesai. Sistem siap!")
        return True
    else:
        print("❌ Beberapa instalasi gagal. Coba cek koneksi internet.")
        return False

if __name__ == "__main__":
    if not run_smart_installer():
        sys.exit(1)
