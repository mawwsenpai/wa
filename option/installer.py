# --- installer.py ---
# VERSI 5.0 - Edisi PREMAN (Anti Ngeyel, Langsung Hajar!)

import sys
import subprocess

# --- DAFTAR WAJIB INSTALL ---
# Langsung hajar semua, pip cukup pintar untuk skip/upgrade jika sudah ada
REQUIRED_PACKAGES = [
    "pip",
    "setuptools",
    "google-generativeai",
    "pywhatkit"
]

def run_brute_force_installer():
    """
    Fungsi ini tidak banyak tanya, langsung instal semua yang dibutuhkan.
    Cara paling tangguh untuk melawan error ModuleNotFoundError.
    """
    print("==============================================")
    print("      🚀 Menjalankan Installer Mode ultra     ")
    print("         (Anti Ngeyel & Langsung Hajar)       ")
    print("==============================================")
    
    try:
        python_executable = sys.executable
        
        # Loop dan hajar instalasi semua package
        for package in REQUIRED_PACKAGES:
            print(f"💪 Memastikan '{package}' dalam kondisi prima...")
            # Perintahnya: python -m pip install --upgrade <package_name>
            # Outputnya sengaja ditampilkan biar kita lihat prosesnya
            subprocess.check_call([
                python_executable, "-m", "pip", "install", "--upgrade", package
            ])
        
        print("----------------------------------------------")
        print("✅ Semua dependensi berhasil dihajar! Sistem siap.")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"\n❌ GAGAL saat menghajar package. Error: {e}")
        print("   Pastikan koneksi internet lancar dan coba lagi.")
        return False
    except Exception as e:
        print(f"\n❌ Terjadi error tak terduga: {e}")
        return False

if __name__ == "__main__":
    if not run_brute_force_installer():
        sys.exit(1) # Keluar dengan status error jika instalasi gagal
