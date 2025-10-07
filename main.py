# --- main.py ---
# VERSI 7.0 - Edisi "Semua Jadi Satu" (All-in-One & Super Stabil)

import sys
import os
import subprocess
import time

# --- BAGIAN 1: INSTALLER TERINTEGRASI ---

# Daftar belanja dengan versi yang "dikunci" untuk menghindari error kompilasi
REQUIRED_PACKAGES = {
    "setuptools": None, # Selalu upgrade
    "google-generativeai": "0.5.4", # Versi ini tidak butuh Rust
    "pywhatkit": "5.4" # Versi stabil
}

def print_header(title):
    """Fungsi untuk menampilkan header yang keren."""
    print("==============================================")
    print(f"      {title}      ")
    print("==============================================")

def handle_dependencies():
    """Mengecek dan menginstal dependensi langsung dari main.py."""
    print_header("🚀 Pengecekan Sistem & Dependensi")
    
    all_success = True
    try:
        # Upgrade pip dulu biar sehat
        sys.stdout.write("⚙️  Memeriksa 'pip'...")
        sys.stdout.flush()
        subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", "pip"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        sys.stdout.write(" -> ✅ OK!\n")

        for package, version in REQUIRED_PACKAGES.items():
            install_string = f"{package}{f'=={version}' if version else ''}"
            sys.stdout.write(f"⚙️  Memastikan '{install_string}'...")
            sys.stdout.flush()
            
            subprocess.check_call(
                [sys.executable, "-m", "pip", "install", install_string],
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

# --- BAGIAN 2: PROGRAM UTAMA ---

def main():
    """Fungsi utama untuk menjalankan seluruh alur aplikasi."""
    
    # Langkah 1: Jalankan Installer dulu
    if not handle_dependencies():
        sys.exit(1) # Keluar jika instalasi gagal

    # Langkah 2: Impor modul-modul SETELAH instalasi berhasil
    # Ini trik penting! Jangan import di atas sebelum diinstal.
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

    # Langkah 3: Muat Konfigurasi
    print("\n--- Memuat Konfigurasi ---")
    config = muat_konfigurasi()
    if not config:
        print("❌ Gagal memuat konfigurasi. Program berhenti.")
        sys.exit(1)
    
    # Langkah 4: Hubungkan ke Gemini AI
    print("\n--- Menghubungkan ke Gemini AI ---")
    api_key = config.get("gemini_api_key")
    gemini_model = initialize_gemini(api_key)
    if not gemini_model:
        print("❌ Gagal terhubung ke Gemini. Program berhenti.")
        sys.exit(1)
        
    # Langkah 5: Jalankan Menu Utama
    time.sleep(1) 
    start_menu(gemini_model)

if __name__ == "__main__":
    main()
