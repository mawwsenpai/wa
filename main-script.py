# =======================================================================
#               WhatsApp Store Bot with Gemini AI
#                   V2 By MawwSenpai_
#
#   Script tunggal untuk setup, instalasi, dan menjalankan bot.
#   DIBUAT UNTUK TUJUAN EDUKASI. RISIKO BANNED DITANGGUNG PENGGUNA.
# =======================================================================

import os
import sys
import subprocess
import time
import random
import pkgutil
from datetime import datetime

# --- Bagian Pengecekan dan Instalasi Otomatis ---

# Daftar library yang dibutuhkan
REQUIRED_PACKAGES = ['google-generativeai', 'pywhatkit', 'Pillow']

def check_and_install_packages():
    """Mengecek dan menginstall library Python yang dibutuhkan."""
    print(" Cek Kebutuhan Library ".center(70, "="))
    for package in REQUIRED_PACKAGES:
        if not pkgutil.find_loader(package.replace('-', '_')):
            print(f"⚠️  Library '{package}' tidak ditemukan. Menginstall...")
            try:
                subprocess.check_call([sys.executable, "-m", "pip", "install", package, "--quiet"])
                print(f"✅  Berhasil menginstall '{package}'.")
            except subprocess.CalledProcessError:
                print(f"❌ GAGAL menginstall '{package}'. Coba install manual: pip install {package}")
                sys.exit(1)
        else:
            print(f"👍  Library '{package}' sudah terinstall.")
    print("=" * 70)
    # Sedikit jeda agar user bisa baca
    time.sleep(2)

# Panggil fungsi pengecekan di awal
check_and_install_packages()

# Lanjutkan import setelah instalasi dipastikan selesai
try:
    import google.generativeai as genai
    import pywhatkit as kit
except ImportError:
    print("❌ Gagal mengimpor library setelah instalasi. Silakan coba jalankan script lagi.")
    sys.exit(1)


# --- Konfigurasi dan Tampilan ---

# Kode warna untuk terminal
C_RESET = '\033[0m'
C_RED = '\033[0;31m'
C_GREEN = '\033[0;32m'
C_YELLOW = '\033[0;33m'
C_CYAN = '\033[0;36m'

# Lokasi file aman untuk menyimpan API Key
API_KEY_FILE = os.path.join(os.path.expanduser("~"), ".gemini_api_key")

# --- KONFIGURASI TOKO (PENTING BANGET!) ---
# Edit ini sesuai info tokomu. Makin detail, bot makin pinter.
CONTEXT_TOKO = """
Anda adalah asisten virtual dari toko 'Maww Store'.
Tugas Anda adalah menjawab pertanyaan pelanggan dengan ramah, informatif, dan sopan menggunakan bahasa Indonesia gaul tapi profesional.

Informasi tentang toko:
- Nama Toko: Maww Store
- Produk: Menjual akun game premium, voucher, dan item-item langka.
- Jam Buka Layanan: Setiap hari, pukul 10:00 - 22:00 WIB. Diluar jam itu, bilang akan dibalas besok.
- Lokasi: Kami adalah toko online, tidak ada toko fisik. Semua transaksi via online.
- Pembayaran: Menerima transfer bank (BCA, Mandiri), QRIS, dan e-wallet (Dana, OVO).
- Proses Pesanan: Pesanan diproses setelah pembayaran dikonfirmasi. Proses biasanya 5-15 menit.
- Kontak Admin: Jika ada masalah mendesak, bisa hubungi admin di @mawwsenpai_ di Telegram.

Aturan Jawaban:
1.  Selalu sapa pelanggan dengan "Halo kak," atau "Hai kak,".
2.  Jika pertanyaan di luar konteks toko (misal nanya cuaca), jawab dengan sopan: "Maaf kak, saya hanya bisa bantu soal produk dan layanan di Maww Store ya."
3.  Jaga jawaban agar singkat, jelas, dan to-the-point.
4.  Jika tidak tahu, jawab jujur: "Waduh, untuk info itu saya mesti tanya ke admin dulu kak. Mungkin bisa ditanyakan langsung ke admin kami di Telegram @mawwsenpai_ ya."
5.  AKHIRI setiap jawaban dengan ucapan "Ada lagi yang bisa dibantu, kak?".
"""

def display_banner():
    """Menampilkan banner keren saat script dimulai."""
    clear_screen()
    print(f"{C_CYAN}")
    print("=" * 70)
    print(" ███▄ ▄███▓ ▄▄▄       ██▀███   ▒█████   ██▓     ██▓    ")
    print("▓██▒▀█▀ ██▒▒████▄    ▓██ ▒ ██▒▒██▒  ██▒▓██▒    ▓██▒    ")
    print("▓██    ▓██░▒██  ▀█▄  ▓██ ░▄█ ▒▒██░  ██▒▒██░    ▒██░    ")
    print("▒██    ▒██ ░██▄▄▄▄██ ▒██▀▀█▄  ▒██   ██░▒██░    ▒██░    ")
    print("▒██▒   ░██▒ ▓█   ▓██▒░██▓ ▒██▒░ ████▓▒░░██████▒░██████▒")
    print("░ ▒░   ░  ░ ▒▒   ▓▒█░░ ▒▓ ░▒▓░░ ▒░▒░▒░ ░ ▒░▓  ░░ ▒░▓  ░")
    print("░  ░      ░  ▒   ▒▒ ░  ░▒ ░ ▒░  ░ ▒ ▒░ ░ ░ ▒  ░░ ░ ▒  ░")
    print("░      ░     ░   ▒     ░░   ░ ░ ░ ░ ▒    ░ ░     ░ ░   ")
    print("       ░         ░  ░   ░         ░ ░      ░  ░    ░  ░")
    print(f"\n                   {C_GREEN}V2 By MawwSenpai_{C_CYAN}")
    print("=" * 70)
    print(f"{C_RESET}")

def clear_screen():
    """Membersihkan layar terminal."""
    os.system('cls' if os.name == 'nt' else 'clear')

def setup_api_key():
    """Meminta, menyimpan, dan memuat API Key Gemini."""
    if os.path.exists(API_KEY_FILE) and os.path.getsize(API_KEY_FILE) > 0:
        print(f"{C_GREEN}✔  API Key ditemukan di file cache.{C_RESET}")
        with open(API_KEY_FILE, "r") as f:
            return f.read().strip()
    else:
        print(f"{C_YELLOW}🔑 API Key Gemini kamu belum tersimpan.{C_RESET}")
        api_key = input("   Masukkan API Key Gemini kamu di sini: ")
        with open(API_KEY_FILE, "w") as f:
            f.write(api_key)
        print(f"{C_GREEN}✔  API Key berhasil disimpan di {API_KEY_FILE}{C_RESET}")
        return api_key

def validate_api_key(api_key):
    """Memvalidasi API Key dengan membuat request percobaan."""
    print("\n Menganalisa API Key ".center(70, "="))
    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-pro')
        # Request ringan untuk tes
        model.generate_content("test", generation_config=genai.types.GenerationConfig(max_output_tokens=2))
        print(f"{C_GREEN}🎉 API Key VALID! Koneksi ke Google AI berhasil.{C_RESET}")
        print("=" * 70)
        time.sleep(2)
        return True
    except Exception as e:
        print(f"{C_RED}❌ API Key TIDAK VALID atau ada masalah jaringan.{C_RESET}")
        print(f"   Error: {str(e)[:100]}...")
        # Hapus file key yang salah agar user bisa input lagi
        if os.path.exists(API_KEY_FILE):
            os.remove(API_KEY_FILE)
        print(f"{C_YELLOW}   File API Key yang salah sudah dihapus. Silakan jalankan ulang script.{C_RESET}")
        return False

def generate_response(user_message, model):
    """Mengirim prompt ke Gemini dan mendapatkan balasan."""
    full_prompt = f"{CONTEXT_TOKO}\n\nPertanyaan Pelanggan: \"{user_message}\"\n\nJawaban Anda:"
    try:
        response = model.generate_content(full_prompt)
        return response.text
    except Exception as e:
        print(f"{C_RED}❌ Error saat menghubungi Gemini: {e}{C_RESET}")
        return "Maaf kak, sistem AI kami lagi ada gangguan nih. Coba tanya lagi beberapa saat ya."


# --- Fungsi Utama Bot ---

def main_bot_loop(model):
    """Loop utama untuk mendengarkan dan membalas pesan."""
    clear_screen()
    print(" Bot WhatsApp Aktif ".center(70, "="))
    print(f"{C_GREEN}🤖 Bot mulai memantau pesan masuk...{C_RESET}")
    print(f"{C_YELLOW}   Buka WhatsApp Web di browser dan biarkan script ini berjalan.")
    print(f"   Tekan 'Ctrl + C' di terminal ini untuk menghentikan bot.{C_RESET}")
    print("=" * 70)
    
    last_processed_msg = ""

    while True:
        try:
            # Jeda acak yang lebih lama untuk mengurangi risiko banned
            wait_time = random.uniform(15.0, 30.0)
            print(f"\n{C_CYAN}[{datetime.now().strftime('%H:%M:%S')}] Tidur selama {int(wait_time)} detik sebelum cek pesan baru...{C_RESET}")
            time.sleep(wait_time)

            # Mengecek pesan yang belum dibaca
            unread_messages = kit.check_unread()

            if unread_messages:
                print(f"💬 Menemukan {len(unread_messages)} pesan baru!")
                for contact, message in unread_messages:
                    
                    # Anti-Loop: Jangan proses pesan yang sama berulang kali
                    if message == last_processed_msg:
                        continue
                    
                    print(f"   📥 Dari: {contact} | Pesan: {message[:40]}...")

                    print("   🧠 Bot sedang berpikir...")
                    bot_response = generate_response(message, model)
                    print(f"   🤖 Jawaban Bot: {bot_response[:50]}...")

                    # Mengirim balasan
                    kit.sendwhatmsg_instantly(f"+{contact}", bot_response, wait_time=20, tab_close=True, close_time=3)
                    
                    print(f"{C_GREEN}   ✔ Pesan balasan berhasil dikirim ke {contact}{C_RESET}")
                    last_processed_msg = message # Tandai pesan sudah diproses
                    
                    # Jeda acak setelah mengirim untuk meniru manusia
                    time.sleep(random.uniform(8.0, 15.0))
            
        except Exception as e:
            # Error ini sering muncul jika tidak ada pesan baru, bisa diabaikan dengan aman.
            if "No unread message" not in str(e):
                print(f"\n{C_RED}⚠️ Terjadi error tak terduga: {e}{C_RESET}")
                print(f"{C_YELLOW}   Melanjutkan proses dalam 10 detik...{C_RESET}")
                time.sleep(10)

# --- Titik Masuk Eksekusi Script ---
if __name__ == "__main__":
    try:
        display_banner()
        gemini_api_key = setup_api_key()
        
        if gemini_api_key and validate_api_key(gemini_api_key):
            genai.configure(api_key=gemini_api_key)
            gemini_model = genai.GenerativeModel('gemini-pro')
            main_bot_loop(gemini_model)
            
    except KeyboardInterrupt:
        print(f"\n\n{C_YELLOW}🛑 Bot dihentikan oleh pengguna. Sampai jumpa lagi!{C_RESET}")
    except Exception as e:
        print(f"\n{C_RED}❌ Terjadi kesalahan fatal pada script: {e}{C_RESET}")

