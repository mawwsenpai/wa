#!/bin/bash

# --- Variabel & Fungsi Bantuan ---
CONFIG_FILE="$HOME/MawwScript/wa/config.json"
export PYTHONDONTWRITEBYTECODE=1 # Biar nggak nyampah __pycache__

print_green() { echo -e "\033[1;32m$1\033[0m"; }
print_yellow() { echo -e "\033[1;33m$1\033[0m"; }
print_cyan() { echo -e "\033[1;36m$1\033[0m"; }

header() {
    clear
    print_green "=================================================="
    print_green "    🤖 A S I S T E N   A I   T E R M U X v3.0    "
    print_green "                  by Mawwsenpai                 "
    print_green "=================================================="; echo ""
}

# --- LOGIKA LOGIN / SETUP ---
if [ ! -f "$CONFIG_FILE" ]; then
    header
    print_cyan "   --- SETUP PERTAMA KALI ---"
    echo "   Selamat datang! Kamu perlu memasukkan Kunci API Gemini untuk memulai."
    echo "   Dapatkan kunci gratis di aistudio.google.com"
    echo ""
    read -p "   [?] Masukkan Kunci API Gemini-mu: " apikey
    
    # Panggil config_manager.py untuk menyimpan kunci
    python config_manager.py --setup --apikey "$apikey"
    
    echo ""
    read -p "   Tekan [Enter] untuk melanjutkan..."
fi

# --- Logika Utama Script ---
# (Sama seperti sebelumnya, tapi dengan sedikit perbaikan)
while true; do
    header
    print_cyan "   [ MENU UTAMA ]"
    echo "   1. WhatsApp Tools"
    echo "   2. Jalankan Ulang Pengecekan Sistem"
    echo "   0. Keluar"
    read -p $'\n   └─> Pilih opsi: ' choice
    case $choice in
        1)
            # ... (Menu WhatsApp tetap sama) ...
            while true; do
                header
                print_cyan "   [ WHATSAPP TOOLS ]"
                print_yellow "   1. Pesan Masuk: [ Fitur dalam pengembangan ]"
                echo "   2. Kirim Pesan Baru"
                echo "   0. Kembali"
                read -p $'\n   └─> Pilih opsi: ' wa_choice
                case $wa_choice in
                    2)
                        echo ""; print_cyan "   --- Kirim Pesan Baru ---"
                        print_yellow "   PENTING: Saat pertama kali, browser akan menampilkan QR Code."
                        print_yellow "   Scan dengan HP-mu untuk menautkan WhatsApp. (Hanya sekali)"
                        read -p "   [?] Nomor Tujuan (+628...): " nomor
                        read -p "   [?] Tulis Pesan: " pesan
                        read -p "   [?] Minta bantuan Gemini? (y/n): " gemini_choice
                        bantuan_gemini="false"
                        if [[ "$gemini_choice" == "y" ]]; then bantuan_gemini="true"; fi
                        # Panggil aktor Python
                        python whatsapp_handler.py "$nomor" "$pesan" "$bantuan_gemini"
                        read -p $'\n   Tekan [Enter] untuk kembali...'
                        ;;
                    0) break ;;
                    *) echo ""; print_yellow "   Pilihan tidak valid."; sleep 1 ;;
                esac
            done ;;
        2) ./installer.sh ;;
        0) echo ""; print_green "Sampai jumpa, cuy!"; exit 0 ;;
        *) echo ""; print_yellow "   Pilihan tidak valid."; sleep 1 ;;
    esac
done
