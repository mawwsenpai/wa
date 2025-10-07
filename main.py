# --- main.py ---
# VERSI 5.0 - Arsitektur Modular Profesional

import sys
import subprocess
import os

# --- Langkah #1: Jalankan Installer & Pengecekan ---
# Kita tambahkan path ke installer.py
installer_path = os.path.join('option', 'installer.py')
try:
    if os.path.exists(installer_path):
        print("--- Menjalankan Pengecekan Dependensi ---")
        subprocess.check_call([sys.executable, installer_path])
    else:
        # Jika installer.py juga dipindah, kita bisa cari di sana.
        # Untuk sekarang, kita asumsikan installer.py tetap di folder option.
        print(f"Peringatan: {installer_path} tidak ditemukan.")
except (subprocess.CalledProcessError, FileNotFoundError):
    print("\n❌ Gagal menjalankan installer.")
    sys.exit()

# --- Langkah #2: Impor Modul-modul dari Paket 'option' ---
try:
    from option.config_manager import muat_konfigurasi
    from option.gemini_assistant import initialize_gemini
    from option.ui_handler import start_menu
except ImportError as e:
    print(f"❌ Gagal mengimpor modul dari folder 'option'. Pastikan file __init__.py ada. Error: {e}")
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
