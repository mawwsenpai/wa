# --- ui_handler.py ---
from gemini_assistant import ask_gemini
from whatsapp_handler import kirim_pesan_wa

def start_menu(gemini_model):
    print("🤖 Asisten AI siap! Ketik 'keluar' untuk berhenti.")
    print("----------------------------------------------")
    
    while True:
        try:
            print("\n--- Mode Asisten ---")
            pilihan = input("> Kamu [chat/wa/keluar]: ").lower()
            
            if pilihan in ['keluar', 'exit', 'quit']:
                print("🤖 Sampai jumpa, cuy!"); break
            elif pilihan == 'chat':
                teks_chat = input("[?] Teks untuk Gemini: ")
                jawaban = ask_gemini(gemini_model, teks_chat)
                print(f"🤖 Asisten: {jawaban}")
            elif pilihan == 'wa':
                handle_menu_wa(gemini_model)
            else:
                print("Pilihan tidak valid. Ketik 'chat', 'wa', atau 'keluar'.")
        except KeyboardInterrupt:
            print("\n🤖 Sampai jumpa, cuy!"); break
        except Exception as e:
            print(f"❌ Terjadi error di menu utama: {e}"); break

def handle_menu_wa(gemini_model):
    print("\n--- Kirim Pesan WhatsApp ---")
    nomor_tujuan = input("[?] Nomor WA Tujuan (+628...): ")
    if not nomor_tujuan.startswith('+'):
        print("❌ Format nomor WA tidak valid. Harus diawali dengan kode negara (+62).")
        return
        
    pesan_wa = input("[?] Pesan yang akan dikirim: ")
    
    konfirmasi = input("[?] Mau pesan ini dibantu Gemini dulu? (y/n): ").lower()
    if konfirmasi == 'y':
        prompt = f"Perhalus atau buat pesan WhatsApp ini lebih santai/profesional:\n'{pesan_wa}'"
        pesan_wa = ask_gemini(gemini_model, prompt)
        print(f"🤖 Pesan setelah diperhalus: {pesan_wa}")
    
    kirim_pesan_wa(nomor_tujuan, pesan_wa)
