# --- install.py ---
# Tukang Cek & Pasang Dependensi Otomatis

import subprocess
import sys
import pkg_resources # Library untuk mengecek package yang terinstall

# --- DAFTAR BELANJA / DEPENDENSI YANG DIBUTUHKAN ---
REQUIRED_PACKAGES = [
    "google-generativeai",
    "pywhatkit"
]

def check_and_install_packages():
    """
    Fungsi untuk mengecek apakah package yang dibutuhkan sudah terinstall.
    Jika belum, akan otomatis menginstalnya menggunakan pip.
    """
    print("==============================================")
    print("🔍 Menganalisis dan Memeriksa Dependensi...")
    print("==============================================")
    
    # Dapatkan daftar package yang sudah terinstall
    installed_packages = {pkg.key for pkg in pkg_resources.working_set}
    missing_packages = []

    for package in REQUIRED_PACKAGES:
        # Cek apakah package ada di daftar yang sudah terinstall
        if package not in installed_packages:
            missing_packages.append(package)

    if not missing_packages:
        print("✅ Semua dependensi yang dibutuhkan sudah terpasang!")
        print("----------------------------------------------")
        return True

    print(f"❗ Ditemukan {len(missing_packages)} dependensi yang belum terpasang.")
    
    for package in missing_packages:
        print(f"📦 Menginstal '{package}'...")
        try:
            # Menjalankan perintah 'pip install' dari dalam script
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])
            print(f"   -> '{package}' berhasil diinstal.")
        except subprocess.CalledProcessError as e:
            print(f"❌ GAGAL menginstal '{package}'. Error: {e}")
            print("   Silakan coba instal manual dengan 'pip install <nama_package>'")
            return False
    
    print("\n✅ Semua dependensi berhasil diinstal!")
    print("----------------------------------------------")
    return True

if __name__ == "__main__":
    # Bagian ini akan berjalan jika install.py dieksekusi langsung
    check_and_install_packages()

