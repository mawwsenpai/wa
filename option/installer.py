# --- installer.py ---
# VERSI FINAL - Patuh Aturan Termux

import sys
import subprocess

# --- DAFTAR WAJIB INSTALL ---
# "pip" sudah kita hapus dari daftar ini!
REQUIRED_PACKAGES = [
    "setuptools",
    "google-generativeai",
    "pywhatkit"
]

def run_final_installer():
    """
    Installer yang patuh aturan Termux:
    Tidak akan mencoba meng-upgrade pip.
    """
    print("==============================================")
    print("      🚀 Asisten AI - Pemasangan Final       ")
    print("==============================================")
    
    all_success = True
    
    # Langsung loop dan eksekusi
    for package in REQUIRED_PACKAGES:
        sys.stdout.write(f"⚙️  Memastikan '{package}' dalam kondisi prima...")
        sys.stdout.flush()
        
        try:
            # Jalankan perintah pip install
            subprocess.check_call(
                [sys.executable, "-m", "pip", "install", "--upgrade", package],
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
    if not run_final_installer():
        sys.exit(1)
