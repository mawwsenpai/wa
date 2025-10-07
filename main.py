# --- main.py ---
# VERSI 5.1 - Arsitektur Final & Anti Gagal

import sys
import subprocess
import os

# --- Langkah #1: Jalankan Installer (Sekarang di lokasi yang benar) ---
installer_path = "installer.py"
try:
    if not os.path.exists(installer_path):
        print(f"❌ FATAL: File '{installer_path}' tidak ditemukan!")
        print("   Pastikan file installer sejajar dengan main.py.")
        sys.exit() # Berhenti total jika installer tidak ada
        
    print("--- Menjalankan Pengecekan Dependensi ---")
    # Jalankan installer dan tunggu sampai selesai
    subprocess.check_call([sys.executable, installer_path])
    
except subprocess.CalledProcessError:
    print("\n❌ Gagal saat proses instalasi dependensi. Coba jalankan ulang.")
    sys.exit()

# --- Langkah #2: Impor Modul-modul Kita ---
# Blok try-except ini sekarang jadi sangat penting
try:
    from option.config_manager import muat_konfigurasi
    from option.gemini_assistant import initialize_gemini
    from option.ui_handler import start_menu
except ImportError as e:
    # Error ini HANYA akan muncul jika instalasi gagal atau file .py hilang
    print(f"❌ Gagal mengimpor modul. Kemungkinan instalasi dependensi gagal. Error: {e}")
    print("   Pastikan semua file .py ada di dalam folder 'option' dan __init__.py ada.")
    sys.exit()

def main():
    """Fungsi utama untuk menjalankan aplikasi."""
    config = muat_konfigurasi()
    if not config:
        sys.exit()
    
    api_key = config.get("gemini_api_key")
    if not api_key:
        print("❌ Kunci API tidak ditemukan di file konfigurasi.")
        sys.exit()
        
    gemini_model = initialize_gemini(api_key)
    if not gemini_model:
        sys.exit()
        
    start_menu(gemini_model)

if __name__ == "__main__":
    main()
