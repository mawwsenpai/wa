# --- main.py ---
# VERSI 2.1 - Dengan Brankas Pribadi & Fungsi Kirim Pesan WA

import os
import sys
import json
import getpass
import time # Untuk jeda waktu
import google.generativeai as genai
import pywhatkit as kit # Library untuk kirim WA

# --- LOKASI BRANKAS PRIBADI ---
CONFIG_DIR = os.path.expanduser("~/MawwScript/wa")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")

def setup_awal():
    """Fungsi ini akan berjalan HANYA jika file config belum ada."""
    print("==============================================")
    print("🚀 Selamat Datang! Mari kita setup Asisten AI-mu.")
    print("   (Konfigurasi akan disimpan di brankas pribadimu)")
    print("==============================================")
    
    api_key = getpass.getpass("[?] Masukkan Kunci API Gemini-mu (input tersembunyi): ")
    nomor_wa_default = input("[?] Masukkan nomor WA-mu sebagai default pengirim (+628...): ")

    konfigurasi = {
        "gemini_api_key": api_key,
        "user_whatsapp_number": nomor_wa_default
    }
    
    try:
        os.makedirs(CONFIG_DIR, exist_ok=True)
        with open(CONFIG_FILE, 'w') as f:
            json.dump(konfigurasi, f, indent=4)
        print("\n✅ Setup Selesai! Konfigurasi telah disimpan di:")
        print(f"   {CONFIG_FILE}")
        print("\n   Jalankan script ini lagi untuk mulai menggunakan asisten.")
    except Exception as e:
        print(f"\n❌ Gagal menyimpan konfigurasi. Error: {e}")
        
    sys.exit()

def muat_konfigurasi():
    """Fungsi untuk membaca konfigurasi dari file."""
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except Exception:
        return None

def kirim_pesan_wa(nomor_tujuan, pesan_teks, jam, menit):
    """Fungsi untuk mengirim pesan WhatsApp menggunakan pywhatkit."""
    try:
        print(f"Mengirim pesan WA ke {nomor_tujuan} pada jam {jam}:{menit}...")
        kit.sendwhatmsg(nomor_tujuan, pesan_teks, jam, menit, tab_close=True)
        print("✅ Pesan WA berhasil dijadwalkan untuk dikirim.")
    except Exception as e:
        print(f"❌ Gagal mengirim pesan WA. Pastikan WhatsApp Web sudah login dan browser terbuka. Error: {e}")

# --- PROGRAM UTAMA DIMULAI DI SINI ---

if not os.path.exists(CONFIG_FILE):
    setup_awal()

print(f"✅ Konfigurasi ditemukan di '{CONFIG_FILE}'. Memuat...")
config = muat_konfigurasi()

if config and config.get("gemini_api_key") and config.get("user_whatsapp_number"):
    try:
        API_KEY = config.get("gemini_api_key")
        DEFAULT_WA_NUMBER = config.get("user_whatsapp_number")
        genai.configure(api_key=API_KEY)
        model = genai.GenerativeModel('gemini-pro')
        print("🤖 Asisten AI siap! Ketik 'keluar' untuk berhenti.")
        print("----------------------------------------------")
    except Exception as e:
        print(f"❌ Gagal mengkonfigurasi API. Mungkin Kunci API salah.")
        sys.exit()
else:
    print("❌ Kunci API atau Nomor WA tidak ditemukan di file konfigurasi.")
    print(f"   Coba hapus file lama (jika ada) dengan perintah:")
    print(f"   rm {CONFIG_FILE}")
    sys.exit()

# Loop chat utama
while True:
    try:
        print("\n--- Mode Asisten ---")
        pertanyaan_user = input("> Kamu [chat/wa/keluar]: ")
        
        if pertanyaan_user.lower() in ['keluar', 'exit', 'quit']:
            print("🤖 Sampai jumpa, cuy!")
            break
        elif pertanyaan_user.lower() == 'chat':
            # Mode chat biasa dengan Gemini
            teks_chat = input("[?] Teks untuk Gemini: ")
            response = model.generate_content(teks_chat)
            print(f"🤖 Asisten: {response.text}")
        elif pertanyaan_user.lower() == 'wa':
            # Mode kirim WA
            print("\n--- Kirim Pesan WhatsApp ---")
            nomor_tujuan_wa = input("[?] Nomor WA Tujuan (+628...): ")
            pesan_wa = input("[?] Pesan yang akan dikirim: ")
            
            # Kita bisa minta Gemini buat bikin pesan dulu kalo mau
            konfirmasi_gemini = input("[?] Mau pesan ini dibenerin/diperhalus Gemini dulu? (y/n): ")
            if konfirmasi_gemini.lower() == 'y':
                print("🤖 Mengirim pesan ke Gemini untuk diperhalus...")
                prompt_gemini = f"Perhalus atau buat pesan WhatsApp ini lebih santai/profesional:\n'{pesan_wa}'"
                response_gemini = model.generate_content(prompt_gemini)
                pesan_wa = response_gemini.text
                print(f"🤖 Pesan setelah diperhalus: {pesan_wa}")
                
            # Jadwalkan pengiriman 15 detik dari sekarang
            sekarang = time.localtime()
            jam_kirim = sekarang.tm_hour
            menit_kirim = sekarang.tm_min + 1 # Kirim 1 menit lagi

            # Penanganan kasus menit > 59
            if menit_kirim >= 60:
                menit_kirim -= 60
                jam_kirim = (jam_kirim + 1) % 24 # Jika jam > 23, kembali ke 0

            # Cek apakah nomor tujuan valid
            if not nomor_tujuan_wa.startswith('+'):
                print("❌ Format nomor WA tidak valid. Harus diawali dengan kode negara (misal +62).")
            else:
                kirim_pesan_wa(nomor_tujuan_wa, pesan_wa, jam_kirim, menit_kirim)
                print("Silakan buka browser yang muncul untuk konfirmasi pengiriman!")
        else:
            print("Pilihan tidak valid. Ketik 'chat', 'wa', atau 'keluar'.")

    except KeyboardInterrupt:
        print("\n🤖 Sampai jumpa, cuy!")
        break
    except Exception as e:
        print(f"❌ Terjadi error: {e}")
        # Kamu bisa tambahkan logic untuk mengembalikan ke menu utama atau keluar
        break

