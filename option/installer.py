# --- installer.py ---
# VERSI 5.0 - Edisi PREMAN (Anti Ngeyel, Langsung Hajar!)

import sys
import subprocess

# --- DAFTAR WAJIB INSTALL ---
REQUIRED_PACKAGES = [
    "pip",
    "setuptools",
    "google-generativeai",
    "pywhatkit"
]

def run_brute_force_installer():
    """
    Fungsi ini tidak banyak tanya, langsung instal semua yang dibutuhkan.
    """
    print("==============================================")
    print("      🚀 Menjalankan Installer Mode Preman     ")
    print("         (Anti Ngeyel & Langsung Hajar)         ")
    print("==============================================")
    
    try:
        python_executable = sys.executable
        
        for package in REQUIRED_PACKAGES:
            print(f"💪 Memastikan '{package}' dalam kondisi prima...")
            subprocess.check_call([
                python_executable, "-m", "pip", "install", "--upgrade", package
            ])
        
        print("----------------------------------------------")
        print("✅ Semua dependensi berhasil dihajar! Sistem siap.")
        return True
        
    except Exception as e:
        print(f"\n❌ GAGAL saat memproses package. Error: {e}")
        return False

if __name__ == "__main__":
    if not run_brute_force_installer():
        sys.exit(1)
