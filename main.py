# --- main.py ---
# VERSI 6.0 - Arsitektur Final, UI Konsisten & Anti Gagal

import sys
import os
import subprocess

# --- Langkah #0: Menentukan Lokasi Diri Sendiri (Sangat Penting!) ---
# Ini membuat script tahu di mana dia berada, jadi nggak akan bingung cari file lain
# BASE_DIR adalah lokasi folder 'wa/'
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def run_installer():
    """Mencari dan menjalankan installer.py dengan aman."""
    installer_path = os.path.join(BASE_DIR, "installer.py")
    try:
        if not os.path.exists(installer_path):
            print(f"❌ FATAL: File '{installer_path}' tidak ditemukan!")
            return False
        
        # Menjalankan installer dan menangkap status outputnya
        result = subprocess.run([sys.executable, installer_path], check=True)
        return result.returncode == 0
        
    except subprocess.CalledProcessError:
        print("\n❌ Proses instalasi dependensi gagal. Program tidak bisa dilanjutkan.")
        return False
    except Exception as e:
        print(f"\n❌ Terjadi error tak terduga saat menjalankan installer: {e}")
        return False

def main():
    """Fungsi utama untuk menjalankan seluruh alur aplikasi."""
    
    # --- Tampilan Pembuka ---
    print("==============================================")
    print("      🚀 Memulai Asisten AI Termux...         ")
    print("==============================================")

    # --- Langkah #1: Jalankan Installer ---
    if not run_installer():
        sys.exit(1) # Keluar jika instalasi gagal

    # --- Langkah #2: Impor Modul-modul Kita ---
    # Kita tambahkan path folder 'option' ke path sistem Python
    # Ini adalah cara paling anti-gagal untuk memastikan modul ditemukan
    sys.path.append(os.path.join(BASE_DIR, 'option'))
    
    try:
        from config_manager import muat_konfigurasi
        from gemini_assistant import initialize_gemini
        from ui_handler import start_menu
    except ImportError as e:
        print(f"\n❌ FATAL: Gagal mengimpor modul dari 'option'. Error: {e}")
        print("   Pastikan semua file .py dan `__init__.py` ada di dalam folder 'option'.")
        sys.exit(1)

    # --- Langkah #3: Muat Konfigurasi ---
    print("\n--- Memuat Konfigurasi ---")
    config = muat_konfigurasi()
    if not config:
        print("❌ Gagal memuat konfigurasi. Program berhenti.")
        sys.exit(1)
    
    # --- Langkah #4: Hubungkan ke Gemini AI ---
    print("\n--- Menghubungkan ke Gemini AI ---")
    api_key = config.get("gemini_api_key")
    if not api_key:
        print("❌ Kunci API tidak ditemukan di config. Jalankan ulang setup.")
        sys.exit(1)
        
    gemini_model = initialize_gemini(api_key)
    if not gemini_model:
        print("❌ Gagal terhubung ke Gemini. Program berhenti.")
        sys.exit(1)
        
    # --- Langkah #5: Jalankan Menu Utama ---
    # Kita kasih jeda sedikit biar keliatan lebih profesional
    import time
    time.sleep(1) 
    start_menu(gemini_model)

if __name__ == "__main__":
    main()
