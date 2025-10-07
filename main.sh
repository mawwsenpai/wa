#!/bin/bash

# --- Fungsi-fungsi Tampilan & Menu ---
print_green() { echo -e "\033[1;32m$1\033[0m"; }
print_yellow() { echo -e "\033[1;33m$1\033[0m"; }
print_cyan() { echo -e "\033[1;36m$1\033[0m"; }

header() {
    clear
    print_green "=================================================="
    print_green "    🤖 A S I S T E N   A I   T E R M U X v2.0    "
    print_green "                  by Mawwsenpai                 "
    print_green "=================================================="
    echo ""
}

main_menu() {
    header
    print_cyan "   [ MENU UTAMA ]"
    echo "   1. WhatsApp Tools"
    echo "   2. Install/Update Dependensi"
    echo "   3. Opsi"
    echo "   0. Keluar"
    echo ""
}

whatsapp_menu() {
    header
    print_cyan "   [ WHATSAPP TOOLS ]"
    # Placeholder untuk pesan baru
    print_yellow "   1. Pesan Masuk: [ Fitur dalam pengembangan ]"
    echo "   2. Kirim Pesan Baru"
    echo "   3. Opsi WhatsApp"
    echo "   0. Kembali ke Menu Utama"
    echo ""
}

# --- Logika Utama Script ---
while true; do
    main_menu
    read -p "   └─> Pilih opsi: " choice
    
    case $choice in
        1)
            while true; do
                whatsapp_menu
                read -p "   └─> Pilih opsi WhatsApp: " wa_choice
                case $wa_choice in
                    1)
                        echo ""
                        print_yellow "   Fitur ini sedang dalam pengembangan, cuy!"
                        read -p "   Tekan [Enter] untuk kembali..."
                        ;;
                    2)
                        # Panggil script python untuk mengirim pesan
                        # Kita akan buat ini di langkah selanjutnya
                        echo ""
                        print_yellow "   Memanggil modul pengirim pesan..."
                        # python option/whatsapp_handler.py --action send
                        sleep 2
                        ;;
                    3)
                        echo ""
                        print_yellow "   Opsi WhatsApp belum tersedia."
                        read -p "   Tekan [Enter] untuk kembali..."
                        ;;
                    0)
                        break
                        ;;
                    *)
                        echo ""
                        print_yellow "   Pilihan tidak valid."
                        sleep 1
                        ;;
                esac
            done
            ;;
        2)
            ./installer.sh
            ;;
        3)
            echo ""
            print_yellow "   Fitur Opsi belum tersedia."
            read -p "   Tekan [Enter] untuk kembali..."
            ;;
        0)
            echo ""
            print_green "Sampai jumpa, cuy!"
            exit 0
            ;;
        *)
            echo ""
            print_yellow "   Pilihan tidak valid."
            sleep 1
            ;;
    esac
done
