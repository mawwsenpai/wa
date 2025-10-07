# --- whatsapp_handler.py ---
import pywhatkit as kit
import time

def kirim_pesan_wa(nomor_tujuan, pesan_teks):
    try:
        sekarang = time.localtime(time.time() + 60) # Jadwalkan 1 menit dari sekarang
        jam_kirim, menit_kirim = sekarang.tm_hour, sekarang.tm_min
        
        print(f"Mencoba mengirim pesan WA ke {nomor_tujuan} pada ~{jam_kirim:02d}:{menit_kirim:02d}...")
        kit.sendwhatmsg(nomor_tujuan, pesan_teks, jam_kirim, menit_kirim, wait_time=20, tab_close=True, close_time=10)
        print("✅ Perintah kirim pesan berhasil dieksekusi. Cek browser-mu.")
    except Exception as e:
        print(f"❌ Gagal mengirim pesan WA. Error: {e}")
