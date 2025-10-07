# --- config_manager.py ---
# Versi baru yang bisa menerima perintah dari Shell

import os, sys, json, argparse

CONFIG_DIR = os.path.expanduser("~/MawwScript/wa")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")

def simpan_konfigurasi(api_key):
    """Menyimpan API Key yang diberikan ke file config."""
    konfigurasi = {"gemini_api_key": api_key}
    try:
        os.makedirs(CONFIG_DIR, exist_ok=True)
        with open(CONFIG_FILE, 'w') as f:
            json.dump(konfigurasi, f, indent=4)
        print(f"\n   [✅] Konfigurasi berhasil disimpan di: {CONFIG_FILE}")
        return True
    except Exception as e:
        print(f"\n   [❌] Gagal menyimpan konfigurasi. Error: {e}")
        return False

def muat_konfigurasi():
    """Membaca konfigurasi dari file."""
    if not os.path.exists(CONFIG_FILE):
        return None
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except Exception:
        return None

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Manajer Konfigurasi Asisten AI")
    parser.add_argument('--setup', action='store_true', help="Menjalankan mode setup.")
    parser.add_argument('--apikey', type=str, help="API Key Gemini yang akan disimpan.")
    
    args = parser.parse_args()
    
    if args.setup:
        if args.apikey:
            simpan_konfigurasi(args.apikey)
        else:
            print("Error: Butuh argumen --apikey untuk setup.")
