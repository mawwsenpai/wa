# --- installer.py ---
# VERSI 6.0 - Edisi Langsung Eksekusi (Install First, Analyze Later)

import sys
import subprocess

# --- DAFTAR WAJIB INSTALL ---
REQUIRED_PACKAGES = [
    "pip",
    "setuptools",
    "google-generativeai",
    "pywhatkit"
]

def run_direct_installer():
    """
    Fungsi ini langsung mengeksekusi instalasi untuk setiap paket
    dan memberikan laporan real-time, sesuai permintaan.
    """
    print("==============================================")
    print("      🚀 Asisten AI - Mode Eksekusi          ")
    print("==============================================")
    
    all_success = True
    
    # Langsung loop dan eksekusi
    for package in REQUIRED_PACKAGES:
        # sys.stdout.write & .flush() untuk efek real-time
        sys.stdout.write(f"⚙️  Memastikan '{package}' dalam kondisi prima...")
        sys.stdout.flush()
        
        try:
            # Jalankan perintah pip install dalam mode senyap
            subprocess.check_call(
                [sys.executable, "-m", "pip", "install", "--upgrade", package],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            # Jika berhasil, cetak status OK
            sys.stdout.write(" -> ✅ OK!\n")
            
        except subprocess.CalledProcessError:
            # Jika gagal, cetak status GAGAL
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
    if not run_direct_installer():
        sys.exit(1) # Keluar dengan status error jika ada yang gagal
