# --- ui_handler.py ---
# VERSI 2.0 - Edisi UI Ganteng

# Kita butuh modul-modul lain untuk dipanggil
from .gemini_assistant import ask_gemini
from .whatsapp_handler import kirim_pesan_wa

def display_header():
    """Menampilkan header utama aplikasi yang keren."""
    print("==============================================")
    print("      🤖 Asisten AI Termux v1.0 by Maww    ")
    print("==============================================")
    print("Selamat datang! Asisten siap membantumu.")

def start_menu(gemini_model):
    """Fungsi utama untuk menampilkan menu dan mengatur alur program."""
    display_header()
    
    while True:
        try:
            print("\n┌─[ MENU UTAMA ]")
            pilihan = input("└─> Pilih mode [chat / wa / keluar]: ").lower()
            
            if pilihan in ['keluar', 'exit', 'quit', 'q']:
                print("\n🤖 Terima kasih telah menggunakan asisten. Sampai jumpa, cuy!")
                break
            elif pilihan == 'chat':
                handle_menu_chat(gemini_model)
            elif pilihan == 'wa':
                handle_menu_wa(gemini_model)
            else:
                print("❌ Pilihan tidak valid. Silakan coba lagi.")
        except KeyboardInterrupt:
            print("\n\n🤖 Terima kasih telah menggunakan asisten. Sampai jumpa, cuy!")
            break
        except Exception as e:
            print(f"\n❌ Terjadi error tak terduga di menu utama: {e}")
            break

def handle_menu_chat(gemini_model):
    """Menangani logika untuk mode chat dengan Gemini."""
    print("\n┌─[ MODE CHAT DENGAN GEMINI ]")
    print("│ Ketik 'kembali' untuk kembali ke menu utama.")
    while True:
        teks_chat = input("├─> Kamu: ")
        if teks_chat.lower() == 'kembali':
            print("└─> Kembali ke menu utama...")
            break
        
        jawaban = ask_gemini(gemini_model, teks_chat)
        print(f"└─> Asisten: {jawaban}")

def handle_menu_wa(gemini_model):
    """Menangani logika untuk mode kirim pesan WhatsApp."""
    print("\n┌─[ MODE KIRIM PESAN WHATSAPP ]")
    
    nomor_tujuan = input("├─> Masukkan Nomor WA Tujuan (+628...): ")
    if not nomor_tujuan.startswith('+'):
        print("└─> ❌ Format nomor WA tidak valid. Kembali ke menu utama.")
        return
        
    pesan_wa = input("├─> Tulis pesanmu: ")
    
    konfirmasi = input("└─> Perhalus pesan dengan Gemini? [y/n]: ").lower()
    if konfirmasi == 'y':
        prompt = f"Kamu adalah asisten yang cerdas. Perbaiki atau perhalus pesan WhatsApp ini agar lebih baik (santai/profesional sesuai konteks):\n\n'{pesan_wa}'"
        pesan_wa_final = ask_gemini(gemini_model, prompt)
        print(f"\n  [ Pesan Final ]\n  -----------------\n  {pesan_wa_final}\n  -----------------")
    else:
        pesan_wa_final = pesan_wa
    
    kirim_pesan_wa(nomor_tujuan, pesan_wa_final)

