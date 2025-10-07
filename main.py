# --- main.py ---
# VERSI 7.1 - Edisi FINAL (Patuh Aturan Termux)

import sys
import os
import subprocess
import time
import json
import getpass

# --- BAGIAN 1: INSTALLER TERINTEGRASI ---

# "pip" sudah DIHAPUS dari daftar ini untuk menuruti aturan Termux
REQUIRED_PACKAGES = {
    "setuptools": None,
    "google-generativeai": "0.5.4",
    "pywhatkit": "5.4"
}

def print_header(title):
    """Fungsi untuk menampilkan header yang keren."""
    print("==============================================")
    print(f"      {title}      ")
    print("==============================================")

def handle_dependencies():
    """Mengecek dan menginstal dependensi (tanpa menyentuh pip)."""
    print_header("🚀 Pengecekan Sistem & Dependensi")
    
    all_success = True
    try:
        for package, version in REQUIRED_PACKAGES.items():
            install_string = f"{package}{f'=={version}' if version else ''}"
            sys.stdout.write(f"⚙️  Memastikan '{install_string}'...")
            sys.stdout.flush()
            
            subprocess.check_call(
                [sys.executable, "-m", "pip", "install", "--upgrade", install_string],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
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
        print("❌ Instalasi gagal. Coba periksa koneksi internet.")
        return False

# --- BAGIAN 2: PROGRAM UTAMA (Tidak ada perubahan di sini) ---

def main():
    if not handle_dependencies():
        sys.exit(1)

    print("\n--- Mengimpor Modul Aplikasi ---")
    sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'option'))
    try:
        from config_manager import muat_konfigurasi
        from gemini_assistant import initialize_gemini
        from ui_handler import start_menu
        print("✅ Semua modul berhasil diimpor.")
    except ImportError as e:
        print(f"\n❌ FATAL: Gagal mengimpor modul. Error: {e}")
        sys.exit(1)

    print("\n--- Memuat Konfigurasi ---")
    config = muat_konfigurasi()
    if not config:
        print("❌ Gagal memuat konfigurasi. Program berhenti.")
        sys.exit(1)
    
    print("\n--- Menghubungkan ke Gemini AI ---")
    api_key = config.get("gemini_api_key")
    gemini_model = initialize_gemini(api_key)
    if not gemini_model:
        print("❌ Gagal terhubung ke Gemini. Program berhenti.")
        sys.exit(1)
        
    time.sleep(1) 
    start_menu(gemini_model)

if __name__ == "__main__":
    main()
