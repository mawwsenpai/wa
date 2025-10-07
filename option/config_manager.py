# --- config_manager.py ---
import os, sys, json, getpass

CONFIG_DIR = os.path.expanduser("~/MawwScript/wa")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")

def setup_awal():
    print("🚀 Selamat Datang! Mari kita setup Asisten AI-mu.")
    api_key = getpass.getpass("[?] Masukkan Kunci API Gemini-mu (input tersembunyi): ")
    nomor_wa_default = input("[?] Masukkan nomor WA-mu sebagai default pengirim (+628...): ")
    konfigurasi = {"gemini_api_key": api_key, "user_whatsapp_number": nomor_wa_default}
    try:
        os.makedirs(CONFIG_DIR, exist_ok=True)
        with open(CONFIG_FILE, 'w') as f:
            json.dump(konfigurasi, f, indent=4)
        print(f"\n✅ Setup Selesai! Konfigurasi disimpan di: {CONFIG_FILE}")
        print("\n   Jalankan script ini lagi untuk mulai menggunakan asisten.")
    except Exception as e:
        print(f"\n❌ Gagal menyimpan konfigurasi. Error: {e}")
    sys.exit()

def muat_konfigurasi():
    if not os.path.exists(CONFIG_FILE):
        setup_awal()
    
    print(f"✅ Konfigurasi ditemukan di '{CONFIG_FILE}'. Memuat...")
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except Exception:
        print("❌ Gagal membaca file konfigurasi.")
        return None
