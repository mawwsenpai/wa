# --- installer.py ---
# VERSI FINAL - Edisi "Jalur Bawah Tanah"

import sys, subprocess

# google-generativeai DIBUANG! Diganti requests.
REQUIRED_PACKAGES = [ "pip", "setuptools", "requests", "pywhatkit" ]

def run_final_installer():
    print("==============================================")
    print("     🚀 Asisten AI - Mode Instalasi Manual     ")
    print("==============================================")
    all_success = True
    for package in REQUIRED_PACKAGES:
        sys.stdout.write(f"⚙️  Memastikan '{package}'...")
        sys.stdout.flush()
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", package], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            sys.stdout.write(" -> ✅ OK!\n")
        except subprocess.CalledProcessError:
            sys.stdout.write(" -> ❌ GAGAL!\n")
            all_success = False
    print("----------------------------------------------")
    if all_success: print("✨ Semua sistem siap tempur!"); return True
    else: print("❌ Beberapa instalasi gagal."); return False

if __name__ == "__main__":
    if not run_final_installer(): sys.exit(1)
