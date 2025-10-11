#!/usr/bin/env python3
# =======================================================
# main.py (Python Remake of V10 - Final Diagnostic)
# Rombakan oleh: Gemini
# Original By: MawwSenpai_
# =======================================================

import os
import sys
import subprocess
import shutil
from pathlib import Path

# --- KONFIGURASI WARNA & SIMBOL (dikelola dalam kelas) ---
class Style:
    """Kelas untuk menyimpan konstanta gaya teks terminal."""
    YELLOW = '\033[0;33m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    NC = '\033[0m'  # No Color
    BOLD = '\033[1m'
    SUCCESS_ICON = "✓"
    WARN_ICON = "⚠️"

# --- NAMA FILE & VERSI (menggunakan pathlib untuk path) ---
ENV_FILE = Path(".env")
INSTALL_SCRIPT = "install.js"
AUTH_SCRIPT = "auth.js"
MAIN_SCRIPT = "main.js"
GEMINI_SCRIPT = "gemini.js"
AUTH_DIR = Path("auth_info_baileys")
MODULES_DIR = Path("node_modules")
VERSION = "V10 - Final - By MawwSenpai_ (Python Remake)"

# --- FUNGSI BANTUAN ---
def clear_screen():
    """Membersihkan layar terminal, kompatibel untuk Windows dan Unix/Linux."""
    os.system('cls' if os.name == 'nt' else 'clear')

def pause():
    """Menjeda eksekusi hingga pengguna menekan Enter."""
    print("")
    input("Tekan [Enter] untuk kembali...")

def get_env_vars():
    """Membaca file .env dengan aman dan mengembalikannya sebagai dictionary."""
    if not ENV_FILE.is_file():
        return {}
    env_vars = {}
    with open(ENV_FILE, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                env_vars[key.strip()] = value.strip()
    return env_vars

# --- FUNGSI PRASYARAT ---
def check_dependencies():
    """Memeriksa dependensi sistem yang diperlukan seperti node, npm, dan figlet."""
    print("Mengecek dependensi sistem...")
    missing_deps = []
    # Nama paket di 'pkg' mungkin berbeda (e.g., 'node' adalah 'nodejs')
    dependencies_map = {"node": "nodejs", "npm": "npm", "figlet": "figlet"}
    
    for cmd in dependencies_map.keys():
        if not shutil.which(cmd):
            missing_deps.append(dependencies_map[cmd])

    if missing_deps:
        print(f"{Style.YELLOW}{Style.WARN_ICON} Dependensi sistem hilang: {', '.join(missing_deps)}.{Style.NC}")
        confirm = input("Instal dependensi yang hilang? (y/n): ").lower()
        if confirm == 'y':
            try:
                # Asumsi 'pkg' adalah manajer paket (untuk Termux)
                print(f"{Style.CYAN}Menjalankan 'pkg update'...{Style.NC}")
                subprocess.run(["pkg", "update", "-y"], check=True, capture_output=True)
                print(f"{Style.CYAN}Menginstal: {', '.join(missing_deps)}...{Style.NC}")
                subprocess.run(["pkg", "install", "-y"] + missing_deps, check=True)
                print(f"{Style.CYAN}{Style.SUCCESS_ICON} Dependensi berhasil diinstal.{Style.NC}")
            except (subprocess.CalledProcessError, FileNotFoundError) as e:
                print(f"{Style.YELLOW}Gagal menginstal. Pastikan Anda menggunakan Termux dan 'pkg' tersedia. Error: {e}{Style.NC}")
                sys.exit(1)
        else:
            print(f"{Style.YELLOW}Skrip dibatalkan karena dependensi tidak lengkap.{Style.NC}")
            sys.exit(1)

# --- FUNGSI TAMPILAN (UI) ---
def display_header():
    """Menampilkan header skrip yang keren."""
    clear_screen()
    print("")
    print(f"{Style.BOLD}{Style.WHITE}Script-Whatsapp {Style.PURPLE}[{VERSION}]{Style.NC}")

def display_status():
    """Menampilkan dasbor diagnostik yang lengkap dan detail."""
    print("")
    print(f"{Style.WHITE}--- DASBOR DIAGNOSTIK ---{Style.NC}")
    
    format_ok = f"  {Style.CYAN}{Style.SUCCESS_ICON} %-18s{Style.NC}: %s"
    format_warn = f"  {Style.YELLOW}{Style.WARN_ICON} %-18s{Style.NC}: %s"

    # 1. Status Sistem Dasar
    print(f"{Style.PURPLE} Kebutuhan Dasar{Style.NC}")
    try:
        node_version = subprocess.check_output(["node", "-v"], text=True).strip()
        print(format_ok % ("Node.js", f"Terinstal ({node_version})"))
    except FileNotFoundError:
        print(format_warn % ("Node.js", "Belum terinstal"))

    if MODULES_DIR.is_dir():
        print(format_ok % ("Modules", "Terinstal"))
    else:
        print(format_warn % ("Modules", "Belum diinstal (Menu 1)"))
        
    # 2. Status Konfigurasi API
    print(f"{Style.PURPLE} Konfigurasi API (.env){Style.NC}")
    if ENV_FILE.is_file():
        env_vars = get_env_vars()
        api_keys = {
            "Kunci Gemini": "GEMINI_API_KEY", "Kunci Unsplash": "UNSPLASH_API_KEY", "Kunci Weather": "WEATHER_API_KEY",
        }
        for display_name, key_name in api_keys.items():
            print(format_ok % (f"-> {display_name}", "Terisi")) if env_vars.get(key_name) else print(format_warn % (f"-> {display_name}", "KOSONG (Menu 2)"))
    else:
        print(format_warn % ("File .env", "TIDAK DITEMUKAN"))

    # 3. Status Koneksi & File
    print(f"{Style.PURPLE} Status Koneksi & File{Style.NC}")
    if (AUTH_DIR / "creds.json").is_file():
        print(format_ok % ("-> Sesi WhatsApp", "Aktif"))
    else:
        print(format_warn % ("-> Sesi WhatsApp", "Tidak aktif (Menu 3)"))
    
    for file in [INSTALL_SCRIPT, AUTH_SCRIPT, MAIN_SCRIPT, GEMINI_SCRIPT, "script.js"]:
        print(f"  {Style.CYAN}{Style.SUCCESS_ICON} %-18s{Style.NC}: Ditemukan" % f"File '{file}'") if Path(file).is_file() else print(f"  {Style.YELLOW}{Style.WARN_ICON} %-18s{Style.NC}: HILANG!" % f"File '{file}'")

# --- FUNGSI-FUNGSI UTAMA (MENU) ---
def run_clean_installation():
    display_header()
    print(f"\n{Style.CYAN}--- Menu 1: Instalasi Bersih & Verifikasi ---\n{Style.NC}")
    
    print(f"{Style.YELLOW}Langkah 1: Pembersihan Paksa...{Style.NC}")
    if MODULES_DIR.exists():
        shutil.rmtree(MODULES_DIR)
        print(f"  {Style.CYAN}{Style.SUCCESS_ICON} Folder node_modules dihapus.{Style.NC}")
    
    if (lock_file := Path("package-lock.json")).exists():
        lock_file.unlink()
        print(f"  {Style.CYAN}{Style.SUCCESS_ICON} File package-lock.json dihapus.{Style.NC}")
        
    print(f"\n{Style.YELLOW}Langkah 2: Menjalankan Instalasi Bersih...{Style.NC}")
    if subprocess.run(["node", INSTALL_SCRIPT]).returncode != 0:
        print(f"\n{Style.YELLOW}{Style.WARN_ICON} Instalasi modul gagal.{Style.NC}")
        pause()
        return
        
    print(f"\n{Style.YELLOW}Langkah 3: Verifikasi Akurat Hasil Instalasi...{Style.NC}")
    verifications = {
        "@google/genai": "try { require('@google/genai'); console.log('\\x1b[36m✓ @google/genai\\x1b[0m : Ditemukan & bisa diakses.'); } catch (e) { console.error('\\x1b[33m⚠️ @google/genai\\x1b[0m : GAGAL diakses!'); }",
        "@whiskeysockets/baileys": "try { require('@whiskeysockets/baileys'); console.log('\\x1b[36m✓ @whiskeysockets/baileys\\x1b[0m : Ditemukan & bisa diakses.'); } catch (e) { console.error('\\x1b[33m⚠️ @whiskeysockets/baileys\\x1b[0m : GAGAL diakses!'); }",
    }
    for cmd in verifications.values():
        subprocess.run(["node", "-e", cmd])
    pause()

def setup_env_config():
    display_header()
    print(f"\n{Style.CYAN}--- Menu 2: Konfigurasi Bot & Model AI ---\n{Style.NC}")
    
    current_config = get_env_vars()
    print(f"{Style.WHITE}Isi konfigurasi, tekan [Enter] untuk memakai nilai lama.{Style.NC}")
    
    def get_input(prompt_text, current_value, is_secret=True):
        display = f"{current_value[:5]}..." if current_value and is_secret else current_value
        user_input = input(f"{prompt_text} [{display}]: ")
        return user_input or current_value

    new_config = {
        "GEMINI_API_KEY": get_input("Gemini API Key", current_config.get("GEMINI_API_KEY", "")),
        "UNSPLASH_API_KEY": get_input("Unsplash API Key", current_config.get("UNSPLASH_API_KEY", "")),
        "WEATHER_API_KEY": get_input("WeatherAPI.com Key", current_config.get("WEATHER_API_KEY", "")),
        "PHONE_NUMBER": get_input("Nomor WA (awalan 62)", current_config.get("PHONE_NUMBER", ""), is_secret=False)
    }
    
    print(f"\n{Style.BOLD}{Style.WHITE}Pilih Model Gemini:{Style.NC}\n  1. Gemini 1.5 Flash (Cepat, Rekomendasi)\n  2. Gemini 1.5 Pro (Paling Canggih)\n  3. Gemini 1.0 Pro (Klasik, Stabil)")
    model_choice = input("Pilihan Model [1]: ")
    new_config["GEMINI_MODEL"] = {"2": "gemini-1.5-pro-latest", "3": "gemini-1.0-pro"}.get(model_choice, "gemini-1.5-flash-latest")
    
    with open(ENV_FILE, 'w') as f:
        f.write(f"GEMINI_API_KEY={new_config['GEMINI_API_KEY']}\nGEMINI_MODEL={new_config['GEMINI_MODEL']}\nPHONE_NUMBER={new_config['PHONE_NUMBER']}\n\n")
        f.write(f"# Kunci API Fitur Tambahan\nUNSPLASH_API_KEY={new_config['UNSPLASH_API_KEY']}\nWEATHER_API_KEY={new_config['WEATHER_API_KEY']}\n")
        
    print(f"\n{Style.CYAN}{Style.SUCCESS_ICON} Konfigurasi disimpan dengan model: {Style.BOLD}{new_config['GEMINI_MODEL']}{Style.NC}")
    pause()

def run_authentication():
    display_header()
    print(f"\n{Style.CYAN}--- Menu 3: Hubungkan WhatsApp ---\n{Style.NC}")
    if not MODULES_DIR.is_dir():
        print(f"{Style.YELLOW}Jalankan instalasi (Menu 1) dulu.{Style.NC}")
        pause()
        return

    choice = input("1. Scan QR (Stabil)\n2. Kode 8 Digit\nPilihan [1]: ")
    method = "--method=code" if choice == "2" else "--method=qr"
    subprocess.run(["node", AUTH_SCRIPT, method])
    pause()

def run_bot():
    display_header()
    print(f"\n{Style.CYAN}--- Menu 4: Jalankan Bot ---\n{Style.NC}")
    
    env_vars = get_env_vars()
    if not all([MODULES_DIR.is_dir(), ENV_FILE.is_file(), (AUTH_DIR / "creds.json").is_file(), env_vars.get("GEMINI_API_KEY")]):
        print(f"{Style.YELLOW}Semua status harus {Style.CYAN}✓{Style.YELLOW} dulu sebelum menjalankan bot.{Style.NC}")
        pause()
        return
        
    print("Bot online... Tekan CTRL+C untuk berhenti.")
    try:
        subprocess.run(["node", MAIN_SCRIPT], check=True)
    except KeyboardInterrupt:
        print(f"\n{Style.YELLOW}Bot dihentikan oleh pengguna.{Style.NC}")
    except subprocess.CalledProcessError:
        print(f"\n{Style.YELLOW}{Style.WARN_ICON} Skrip bot berhenti karena ada error.{Style.NC}")
    pause()

def reset_session():
    display_header()
    print(f"\n{Style.YELLOW}--- Menu 5: Reset Sesi ---\n{Style.NC}")
    if AUTH_DIR.is_dir():
        if input("Yakin ingin menghapus semua data sesi WhatsApp? (y/n): ").lower() == 'y':
            try:
                shutil.rmtree(AUTH_DIR)
                print(f"{Style.CYAN}Sesi berhasil dihapus.{Style.NC}")
            except OSError as e:
                print(f"{Style.YELLOW}Gagal menghapus sesi: {e}{Style.NC}")
        else:
            print("Penghapusan sesi dibatalkan.")
    else:
        print("Tidak ada sesi yang ditemukan untuk dihapus.")
    pause()

def run_gemini_status_check():
    display_header()
    print(f"\n{Style.CYAN}--- Menu 6: Cek Status API Gemini ---\n{Style.NC}")
    if not Path(GEMINI_SCRIPT).is_file():
        print(f"{Style.YELLOW}{Style.WARN_ICON} File '{GEMINI_SCRIPT}' tidak ditemukan!{Style.NC}")
    else:
        subprocess.run(["node", GEMINI_SCRIPT])
    pause()

def main():
    """Fungsi utama untuk menjalankan loop menu."""
    check_dependencies()
    
    menu_options = {
        '1': run_clean_installation, '2': setup_env_config, '3': run_authentication,
        '4': run_bot, '5': reset_session, '6': run_gemini_status_check,
        '0': lambda: print(f"\n{Style.CYAN}Sampai jumpa!{Style.NC}") or sys.exit(0)
    }

    while True:
        display_header()
        display_status()
        
        print(f"\n{Style.WHITE}--- M E N U ---{Style.NC}")
        print(f"  {Style.PURPLE}[1]{Style.NC} Instalasi Bersih (Perbaikan Total)")
        print(f"  {Style.PURPLE}[2]{Style.NC} Konfigurasi Bot & Model AI")
        print(f"  {Style.PURPLE}[3]{Style.NC} Hubungkan Akun WhatsApp")

        is_ready = all([MODULES_DIR.is_dir(), ENV_FILE.is_file(), (AUTH_DIR / "creds.json").is_file(), get_env_vars().get("GEMINI_API_KEY")])
        run_style = f"{Style.CYAN}{Style.BOLD}" if is_ready else Style.YELLOW
        run_text = "Jalankan Bot WhatsApp" if is_ready else "Jalankan Bot WhatsApp (Belum Siap)"
        print(f"  {Style.PURPLE}[4]{Style.NC} {run_style}{run_text}{Style.NC}")
            
        print(f"  {Style.PURPLE}[5]{Style.NC} Reset Sesi WhatsApp")
        print(f"  {Style.PURPLE}[6]{Style.NC} Cek Status API Gemini")
        print(f"  {Style.PURPLE}[0]{Style.NC} Keluar")
        
        choice = input("\nPilihan Anda: ")
        action = menu_options.get(choice)
        
        if action:
            action()
        else:
            print(f"\n{Style.YELLOW}Pilihan salah!{Style.NC}")
            pause()

if __name__ == "__main__":
    main()
