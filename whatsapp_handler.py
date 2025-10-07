# --- whatsapp_handler.py ---
# Aktor yang tugasnya hanya mengirim pesan WhatsApp

import sys
import time
import pywhatkit

# Impor dari file sejajar (tanpa 'option.')
from gemini_assistant import ask_gemini, initialize_gemini
from config_manager import muat_konfigurasi

def kirim_pesan_wa(nomor_tujuan, pesan_teks, bantuan_gemini):
    """Fungsi utama untuk memproses dan mengirim pesan WhatsApp."""
    pesan_final = pesan_teks
    
    if bantuan_gemini == 'true':
        print("   -> Meminta bantuan Gemini untuk memperhalus pesan...")
        config = muat_konfigurasi()
        if config and initialize_gemini(config.get("gemini_api_key")):
            prompt = f"Perbaiki atau perhalus pesan WhatsApp ini agar lebih baik (santai/profesional sesuai konteks):\n\n'{pesan_teks}'"
            pesan_final = ask_gemini(prompt)
            print(f"\n   [ Pesan Final dari Gemini ]\n   ---------------------------\n   {pesan_final}\n   ---------------------------")
        else:
            print("   -> Gagal memuat API Key untuk Gemini. Menggunakan pesan asli.")

    try:
        sekarang = time.localtime(time.time() + 60) # Jadwalkan 1 menit dari sekarang
        jam_kirim, menit_kirim = sekarang.tm_hour, sekarang.tm_min
        
        print(f"\n   -> Mencoba mengirim ke {nomor_tujuan} pada ~{jam_kirim:02d}:{menit_kirim:02d}...")
        pywhatkit.sendwhatmsg(nomor_tujuan, pesan_final, jam_kirim, menit_kirim, wait_time=20, tab_close=True, close_time=10)
        print("   -> ✅ Perintah kirim berhasil dieksekusi. Cek browser-mu.")
    except Exception as e:
        print(f"   -> ❌ Gagal mengirim pesan WA. Error: {e}")

if __name__ == "__main__":
    # Script ini membaca argumen dari baris perintah yang dilempar oleh main.sh
    if len(sys.argv) < 3:
        print("Error: Argumen tidak lengkap.")
        sys.exit(1)

    nomor_tujuan = sys.argv[1]
    pesan_awal = sys.argv[2]
    bantuan_gemini = sys.argv[3] if len(sys.argv) > 3 else 'false'
    
    kirim_pesan_wa(nomor_tujuan, pesan_awal, bantuan_gemini)
