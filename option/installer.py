# --- installer.py ---
# VERSI FINAL - Edisi "Kunci Versi" Anti Kompilasi Gagal

import sys
import subprocess

# --- DAFTAR BELANJA DENGAN VERSI TERKUNCI ---
# Ini adalah inti dari solusi kita. Kita pakai versi yang tidak butuh Rust.
REQUIRED_PACKAGES = {
    "pip": None, # Selalu coba upgrade pip
    "setuptools": None, # Selalu coba upgrade setuptools
    "google-generativeai": "0.5.4", # VERSI AMAN!
    "pywhatkit": "5.4" # Versi stabil
}

def run_locked_version_installer():
    """
    Installer cerdas yang menginstal versi spesifik untuk menghindari
    masalah kompilasi di Termux.
    """
    print("==============================================")
    print("    🚀 Asisten AI - Mode Instalasi Aman      ")
    print("==============================================")
    
    all_success = True
    
    for package, version in REQUIRED_PACKAGES.items():
        # Buat string instalasi, contoh: "google-generativeai==0.5.4"
        install_string = f"{package}{f'=={version}' if version else ''}"
        
        sys.stdout.write(f"⚙️  Memasang '{install_string}'...")
        sys.stdout.flush()
        
        try:
            # Jalankan perintah pip install
            subprocess.check_call(
                [sys.executable, "-m", "pip", "install", "--upgrade", install_string],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            sys.stdout.write(" -> ✅ OK!\n")
            
        except subprocess.CalledProcessError:
            sys.stdout.write(" -> ❌ GAGAL!\n")
            all_success = False
            
    print("----------------------------------------------")
    
    if all_success:
        print("✨ Semua sistem siap tempur!")
        return True
    else:
        print("❌ Beberapa instalasi gagal. Coba periksa koneksi internet.")
        return False

if __name__ == "__main__":
    if not run_locked_version_installer():
        sys.exit(1)
