# --- kirim.py ---
# Aktor yang tugasnya hanya mengirim pesan WhatsApp

import sys
import time
import pywhatkit as kit
from gemini_assistant import ask_gemini, initialize_gemini
from config_manager import muat_konfigurasi

def kirim_pesan_wa_langsung(nomor_tujuan, pesan_teks):
    """Fungsi untuk mengirim pesan WhatsApp."""
    try:
        sekarang = time.localtime(time.time() + 60) # Jadwalkan 1 menit dari sekarang
        jam_kirim, menit_kirim = sekarang.tm_hour, sekarang.tm_min
        
        print(f"\n   -> Mencoba mengirim ke {nomor_tujuan} pada ~{jam_kirim:02d}:{menit_kirim:02d}...")
        kit.sendwhatmsg(nomor_tujuan, pesan_teks, jam_kirim, menit_kirim, wait_time=20, tab_close=True, close_time=10)
        print("   -> ✅ Perintah kirim berhasil dieksekusi. Cek browser-mu.")
    except Exception as e:
        print(f"   -> ❌ Gagal mengirim pesan WA. Error: {e}")

if __name__ == "__main__":
    # Script ini akan membaca argumen dari baris perintah
    # Argumen 1: Nomor Tujuan
    # Argumen 2: Pesan
    # Argumen 3: Butuh bantuan Gemini atau tidak ('true'/'false')

    if len(sys.argv) < 3:
        print("Penggunaan: python kirim.py <nomor_tujuan> <pesan> [bantuan_gemini]")
        sys.exit(1)

    nomor_tujuan = sys.argv[1]
    pesan_awal = sys.argv[2]
    bantuan_gemini = sys.argv[3] if len(sys.argv) > 3 else 'false'
    
    pesan_final = pesan_awal

    # Jika butuh bantuan Gemini
    if bantuan_gemini == 'true':
        print("   -> Meminta bantuan Gemini untuk memperhalus pesan...")
        config = muat_konfigurasi()
        if config:
            api_key = config.get("gemini_api_key")
            if api_key:
                gemini_model = initialize_gemini(api_key)
                if gemini_model:
                    prompt = f"Perbaiki atau perhalus pesan WhatsApp ini agar lebih baik (santai/profesional sesuai konteks):\n\n'{pesan_awal}'"
                    pesan_final = ask_gemini(gemini_model, prompt)
                    print(f"\n   [ Pesan Final dari Gemini ]\n   ---------------------------\n   {pesan_final}\n   ---------------------------")

    kirim_pesan_wa_langsung(nomor_tujuan, pesan_final)
