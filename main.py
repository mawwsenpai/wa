#!/usr/bin/env python3
# =======================================================
# main.py (Versi Stabil Final)
# Launcher & Manajer Proyek yang Ditingkatkan
# By: MawwSenpai_ & Gemini
# =======================================================

import os
import sys
import subprocess
import shutil
from pathlib import Path

# --- KONFIGURASI WARNA & SIMBOL ---
class Style:
    """Mengelola semua kode warna dan simbol untuk UI yang konsisten."""
    YELLOW = '\033[0;33m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    GREEN = '\033[0;32m'
    RED = '\033[0;31m'
    NC = '\033[0m'
    BOLD = '\033[1m'
    SUCCESS_ICON = "✓"
    WARN_ICON = "⚠️"

# --- NAMA FILE & VERSI ---
ENV_FILE = Path(".env")
INSTALL_SCRIPT = "install.js"
AUTH_SCRIPT = "auth.js"
MAIN_SCRIPT = "main.js"
GEMINI_SCRIPT = "gemini.js"
AUTH_DIR = Path("auth_info_baileys")
MODULES_DIR = Path("node_modules")
VERSION = "V11 - Stabil - Python Launcher"

# --- FUNGSI BANTUAN & UTILITAS ---
def clear_screen():
    """Membersihkan layar terminal."""
    os.system('cls' if os.name == 'nt' else 'clear')

def pause():
    """Menjeda skrip hingga pengguna menekan Enter."""
    print("")
    input(f"{Style.CYAN}Tekan [Enter] untuk kembali ke menu...{Style.NC}")

def get_env_vars():
    """Membaca file .env dengan aman."""
    if not ENV_FILE.is_file(): return {}
    env_vars = {}
    with open(ENV_FILE, 'r') as f:
        for line in f:
            if line.strip() and not line.strip().startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                env_vars[key.strip()] = value.strip()
    return env_vars

def run_node_script(script_name, args=[]):
    """Fungsi terpusat untuk menjalankan skrip Node.js dengan aman."""
    script_path = Path(script_name)
    if not script_path.is_file():
        print(f"\n{Style.RED}{Style.WARN_ICON} Error: File '{script_name}' tidak ditemukan!{Style.NC}")
        return
    
    command = ["node", script_name] + args
    print(f"\n{Style.CYAN}--- Menjalankan '{' '.join(command)}' ---{Style.NC}")
    try:
        subprocess.run(command)
    except KeyboardInterrupt:
        print(f"\n{Style.YELLOW}Proses dihentikan oleh pengguna.{Style.NC}")
    except Exception as e:
        print(f"\n{Style.RED}Terjadi error saat menjalankan skrip: {e}{Style.NC}")
    print(f"{Style.CYAN}--- Selesai ---{Style.NC}")


# --- FUNGSI PRASYARAT ---
def check_dependencies():
    """Memeriksa apakah Node.js, npm, dll. terinstal."""
    print("Mengecek dependensi sistem...")
    missing = [cmd for cmd in ["node", "npm"] if not shutil.which(cmd)]
    if not missing: return

    print(f"{Style.YELLOW}{Style.WARN_ICON} Dependensi sistem hilang: {', '.join(missing)}.{Style.NC}")
    if input("Instal dependensi (khusus Termux)? (y/n): ").lower() == 'y':
        try:
            subprocess.run(["pkg", "update", "-y"], check=True)
            subprocess.run(["pkg", "install", "-y"] + [m if m != 'node' else 'nodejs' for m in missing], check=True)
        except Exception as e:
            print(f"{Style.RED}Gagal menginstal dependensi. Error: {e}{Style.NC}")
            sys.exit(1)
    else:
        print(f"{Style.YELLOW}Skrip dibatalkan.{Style.NC}"); sys.exit(1)

# --- UI & STATUS ---
def display_header():
    clear_screen()
    print(f"\n{Style.BOLD}{Style.WHITE}Bot Manager {Style.PURPLE}[{VERSION}]{Style.NC}")

def display_status():
    print(f"\n{Style.WHITE}--- DASBOR DIAGNOSTIK ---{Style.NC}")
    status_ok = lambda name, msg: print(f"  {Style.GREEN}{Style.SUCCESS_ICON} {name:<18}{Style.NC}: {msg}")
    status_warn = lambda name, msg: print(f"  {Style.YELLOW}{Style.WARN_ICON} {name:<18}{Style.NC}: {msg}")

    # Kebutuhan Dasar
    try:
        node_v = subprocess.check_output(["node", "-v"], text=True).strip()
        status_ok("Node.js", f"Terinstal ({node_v})")
    except FileNotFoundError:
        status_warn("Node.js", "Belum terinstal")
    status_ok("Modules", "Terinstal") if MODULES_DIR.is_dir() else status_warn("Modules", "Belum diinstal (Menu 1)")
    
    # Konfigurasi & Sesi
    env_vars = get_env_vars()
    status_ok("File .env", "Ditemukan") if ENV_FILE.is_file() else status_warn("File .env", "TIDAK DITEMUKAN (Menu 2)")
    status_ok("Kunci API Gemini", "Terisi") if env_vars.get("GEMINI_API_KEY") else status_warn("Kunci API Gemini", "KOSONG (Menu 2)")
    status_ok("Sesi WhatsApp", "Aktif") if (AUTH_DIR / "creds.json").is_file() else status_warn("Sesi WhatsApp", "Tidak aktif (Menu 3)")

def check_readiness():
    """Memeriksa apakah semua komponen siap untuk menjalankan bot."""
    env_vars = get_env_vars()
    checks = {
        "Folder node_modules belum ada (Jalankan Menu 1)": MODULES_DIR.is_dir(),
        "File .env belum dikonfigurasi (Jalankan Menu 2)": ENV_FILE.is_file(),
        "Kunci API Gemini kosong di .env (Jalankan Menu 2)": bool(env_vars.get("GEMINI_API_KEY")),
        "Sesi WhatsApp belum terhubung (Jalankan Menu 3)": (AUTH_DIR / "creds.json").is_file(),
    }
    missing = [reason for reason, passed in checks.items() if not passed]
    return not missing, missing

# --- FUNGSI-FUNGSI UTAMA (MENU) ---
def run_clean_installation():
    display_header()
    print(f"\n{Style.CYAN}--- Menu 1: Instalasi Bersih & Verifikasi ---\n{Style.NC}")
    if MODULES_DIR.exists(): shutil.rmtree(MODULES_DIR); print(f"{Style.GREEN}Folder node_modules lama dihapus.{Style.NC}")
    if (p_lock := Path("package-lock.json")).exists(): p_lock.unlink(); print(f"{Style.GREEN}File package-lock.json dihapus.{Style.NC}")
    run_node_script(INSTALL_SCRIPT)
    pause()

def setup_env_config():
    display_header(); print(f"\n{Style.CYAN}--- Menu 2: Konfigurasi Bot & Model AI ---\n{Style.NC}")
    # (Kode fungsi ini sudah cukup baik, tidak perlu perubahan signifikan)
    current_cfg = get_env_vars()
    print(f"{Style.WHITE}Isi konfigurasi, tekan [Enter] untuk memakai nilai lama.{Style.NC}")
    get_in = lambda p, c, s=True: input(f"{p} [{(c[:5] + '...' if c and s else c)}]: ") or c
    
    cfg = {
        "GEMINI_API_KEY": get_in("Gemini API Key", current_cfg.get("GEMINI_API_KEY", "")),
        "PHONE_NUMBER": get_in("Nomor WA (awalan 62)", current_cfg.get("PHONE_NUMBER", ""), s=False),
        "UNSPLASH_API_KEY": get_in("Unsplash API Key", current_cfg.get("UNSPLASH_API_KEY", "")),
        "WEATHER_API_KEY": get_in("WeatherAPI.com Key", current_cfg.get("WEATHER_API_KEY", "")),
    }
    
    print(f"\n{Style.BOLD}Pilih Model Gemini:{Style.NC}\n  1. Flash (Cepat)\n  2. Pro (Canggih)")
    cfg["GEMINI_MODEL"] = "gemini-1.5-pro-latest" if input("Pilihan Model [1]: ") == "2" else "gemini-1.5-flash-latest"
    
    with open(ENV_FILE, 'w') as f:
        f.write("\n".join([f"{k}={v}" for k, v in cfg.items()]))
    
    print(f"\n{Style.GREEN}{Style.SUCCESS_ICON} Konfigurasi disimpan ke .env{Style.NC}"); pause()

def run_authentication():
    display_header(); print(f"\n{Style.CYAN}--- Menu 3: Hubungkan WhatsApp ---\n{Style.NC}")
    if not MODULES_DIR.is_dir(): print(f"{Style.YELLOW}Jalankan instalasi (Menu 1) dulu.{Style.NC}"); pause(); return
    choice = input("1. Scan QR (Stabil)\n2. Kode 8 Digit\nPilihan [1]: ")
    method = "code" if choice == "2" else "qr"
    run_node_script(AUTH_SCRIPT, [f"--method={method}"]); pause()

def run_bot():
    display_header(); print(f"\n{Style.CYAN}--- Menu 4: Jalankan Bot ---\n{Style.NC}")
    is_ready, missing = check_readiness()
    if not is_ready:
        print(f"{Style.YELLOW}{Style.WARN_ICON} Bot belum siap dijalankan.{Style.NC}")
        for item in missing: print(f"   - {item}")
        pause(); return
    run_node_script(MAIN_SCRIPT); pause()

def reset_session():
    display_header(); print(f"\n{Style.YELLOW}--- Menu 5: Reset Sesi WhatsApp ---\n{Style.NC}")
    if not AUTH_DIR.is_dir(): print("Tidak ada sesi untuk dihapus."); pause(); return
    if input("Yakin ingin menghapus sesi WhatsApp? (y/n): ").lower() == 'y':
        shutil.rmtree(AUTH_DIR); print(f"{Style.GREEN}Sesi berhasil dihapus.{Style.NC}")
    else: print("Dibatalkan.")
    pause()

def run_gemini_status_check():
    display_header(); print(f"\n{Style.CYAN}--- Menu 6: Cek Status API Gemini ---\n{Style.NC}")
    run_node_script(GEMINI_SCRIPT); pause()

# --- LOOP MENU UTAMA ---
def main():
    """Fungsi utama untuk menjalankan loop menu interaktif."""
    check_dependencies()
    menu = {
        '1': ("Instalasi Bersih (Perbaikan Total)", run_clean_installation),
        '2': ("Konfigurasi Bot & Model AI", setup_env_config),
        '3': ("Hubungkan Akun WhatsApp", run_authentication),
        '4': ("Jalankan Bot WhatsApp", run_bot),
        '5': ("Reset Sesi WhatsApp", reset_session),
        '6': ("Cek Status API Gemini", run_gemini_status_check),
        '0': ("Keluar", lambda: sys.exit(f"\n{Style.CYAN}Sampai jumpa!{Style.NC}\n")),
    }
    while True:
        display_header(); display_status()
        print(f"\n{Style.WHITE}--- M E N U ---{Style.NC}")
        is_ready, _ = check_readiness()
        for key, (desc, _) in menu.items():
            if key == '4':
                style = Style.GREEN + Style.BOLD if is_ready else Style.YELLOW
                desc = desc if is_ready else f"{desc} (Belum Siap)"
                print(f"  {Style.PURPLE}[{key}]{Style.NC} {style}{desc}{Style.NC}")
            elif key != '0':
                print(f"  {Style.PURPLE}[{key}]{Style.NC} {desc}")
        print(f"  {Style.PURPLE}[0]{Style.NC} {menu['0'][0]}")
        
        choice = input("\nPilihan Anda: ")
        action = menu.get(choice)
        
        if action: action[1]()
        else: print(f"\n{Style.RED}Pilihan salah!{Style.NC}"); pause()

if __name__ == "__main__":
    main()
