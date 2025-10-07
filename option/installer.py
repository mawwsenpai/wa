# --- installer.py ---
# VERSI 2.0 - Super Stabil & Modern

import sys
import subprocess

# --- DAFTAR BELANJA / DEPENDENSI YANG DIBUTUHKAN ---
REQUIRED_PACKAGES = [
    "google-generativeai",
    "pywhatkit",
    "setuptools" # Tetap kita pastikan terinstall untuk jaga-jaga
]

def check_package(package_name):
    """Mengecek satu package menggunakan cara modern."""
    try:
        # Python 3.8+ punya importlib.metadata
        from importlib import metadata
        metadata.version(package_name)
        return True
    except ImportError:
        # Fallback untuk Python versi lama (kurang direkomendasikan)
        try:
            import pkg_resources
            pkg_resources.get_distribution(package_name)
            return True
        except Exception:
            return False
    except Exception:
        return False

def install_package(package_name):
    """Menginstal satu package menggunakan pip."""
    try:
        print(f"📦 Menginstal '{package_name}'...")
        # Menjalankan perintah 'pip install' dari dalam script
        subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", package_name])
        print(f"   -> '{package_name}' berhasil diinstal/di-upgrade.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ GAGAL menginstal '{package_name}'. Error: {e}")
        return False

def run_installer():
    """Fungsi utama untuk menjalankan seluruh proses instalasi."""
    print("==============================================")
    print("🔍 Menganalisis dan Memeriksa Dependensi...")
    print("==============================================")
    
    all_good = True
    for package in REQUIRED_PACKAGES:
        print(f"   -> Mengecek '{package}'...")
        if not check_package(package):
            print(f"   ❗ '{package}' tidak ditemukan atau perlu di-update.")
            if not install_package(package):
                all_good = False
    
    print("----------------------------------------------")
    if all_good:
        print("✅ Semua dependensi siap!")
        return True
    else:
        print("❌ Beberapa dependensi gagal diinstal. Coba instal manual.")
        return False

if __name__ == "__main__":
    if not run_installer():
        sys.exit(1) # Keluar dengan status error jika instalasi gagal
