# --- main.py ---
# VERSI 5.2 - Arsitektur Final & Super Stabil

import sys
import subprocess
import os

# --- Langkah #1: Jalankan Installer dengan Penanganan Error yang Kuat ---
installer_path = "installer.py"
print("--- Memulai Program Asisten AI ---")

try:
    if not os.path.exists(installer_path):
        print(f"❌ FATAL: File '{installer_path}' tidak ditemukan!")
        print("   Pastikan file installer sejajar dengan main.py.")
        sys.exit() # Berhenti total jika installer tidak ada
        
    # Menjalankan installer dan menangkap status outputnya
    # shell=False adalah praktik yang lebih aman
    result = subprocess.run([sys.executable, installer_path])
    
    # Jika installer keluar dengan status error (return code bukan 0), hentikan program
    if result.returncode != 0:
        print("\n❌ Proses instalasi dependensi gagal. Program tidak bisa dilanjutkan.")
        sys.exit()
    
except Exception as e:
    print(f"\n❌ Terjadi error tak terduga saat menjalankan installer: {e}")
    sys.exit()

# --- Langkah #2: Impor Modul-modul dengan Pesan Error Jelas ---
try:
    print("\n--- Mengimpor Modul Aplikasi ---")
    from option.config_manager import muat_konfigurasi
    from option.gemini_assistant import initialize_gemini
    from option.ui_handler import start_menu
    print("✅ Semua modul berhasil diimpor.")
except ImportError as e:
    print(f"❌ FATAL: Gagal mengimpor modul aplikasi. Error: {e}")
    print("   Pastikan semua file .py ada di dalam folder 'option' dan `__init__.py` ada.")
    sys.exit()

def main():
    """Fungsi utama untuk menjalankan aplikasi."""
    print("\n--- Memuat Konfigurasi ---")
    config = muat_konfigurasi()
    if not config:
        print("❌ Gagal memuat konfigurasi. Program berhenti.")
        sys.exit()
    
    print("\n--- Menghubungkan ke Gemini AI ---")
    api_key = config.get("gemini_api_key")
    if not api_key:
        print("❌ Kunci API tidak ditemukan di file konfigurasi. Jalankan ulang setup.")
        sys.exit()
        
    gemini_model = initialize_gemini(api_key)
    if not gemini_model:
        print("❌ Gagal terhubung ke Gemini. Program berhenti.")
        sys.exit()
        
    # Jika semua berhasil, jalankan menu utama
    start_menu(gemini_model)

if __name__ == "__main__":
    main()
