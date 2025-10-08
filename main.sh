#!/bin/bash

# =======================================================
# main.sh (Maww Script V6.0) - Aesthetic UI & Robust
# =======================================================

# --- KONFIGURASI WARNA & SIMBOL ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

TICK="✅"
CROSS="❌"
WARN="⚠️"

# --- NAMA FILE KONFIGURASI ---
ENV_FILE=".env"
INSTALL_SCRIPT="install.js"
AUTH_SCRIPT="auth.js"
MAIN_SCRIPT="main.js"
AUTH_DIR="auth_info_baileys"
MODULES_DIR="node_modules"
VERSION="V6.0"

# --- FUNGSI PRASYARAT & TAMPILAN ---

# Cek dependensi sistem sebelum memulai
check_dependencies() {
    local missing_deps=()
    command -v node &> /dev/null || missing_deps+=("nodejs")
    command -v npm &> /dev/null || missing_deps+=("npm")
    command -v figlet &> /dev/null || missing_deps+=("figlet")

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}${WARN} Beberapa dependensi sistem tidak ditemukan: ${missing_deps[*]}.${NC}"
        read -p "Apakah Anda ingin menginstalnya sekarang? (y/n): " confirm
        if [[ "$confirm" == "y" ]]; then
            pkg update && pkg install -y "${missing_deps[@]}"
        else
            echo -e "${RED}Skrip tidak dapat dilanjutkan tanpa dependensi tersebut.${NC}"
            exit 1
        fi
    fi
}

display_header() {
    clear
    echo -e "${CYAN}"
    figlet -c -w $(tput cols) "MAWW SCRIPT"
    echo -e "${PURPLE}"
    figlet -c -w $(tput cols) "V6.0"
    echo -e "${NC}"
}

display_status() {
    echo -e "${PURPLE}╔═════════════════════════ S T A T U S ═════════════════════════╗${NC}"
    # Status Node.js
    if command -v node &> /dev/null; then
        echo -e "${PURPLE}║ ${GREEN}${TICK} Node.js${NC} : Terinstal ($(node -v))"
    else
        echo -e "${PURPLE}║ ${RED}${CROSS} Node.js${NC} : Belum terinstal"
    fi
    # Status Modules
    if [ -d "$MODULES_DIR" ]; then
        echo -e "${PURPLE}║ ${GREEN}${TICK} Modules${NC}   : Folder ditemukan (Siap digunakan)"
    else
        echo -e "${PURPLE}║ ${RED}${CROSS} Modules${NC}   : Belum diinstal (Jalankan Menu 1)"
    fi
    # Status Konfigurasi
    if [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=." "$ENV_FILE"; then
         echo -e "${PURPLE}║ ${GREEN}${TICK} Konfig${NC}    : File .env sudah diatur"
    else
         echo -e "${PURPLE}║ ${YELLOW}${WARN} Konfig${NC}    : .env belum diatur (Jalankan Menu 2)"
    fi
    # Status Sesi WA
    if [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ]; then
        echo -e "${PURPLE}║ ${GREEN}${TICK} Sesi WA${NC}   : Aktif"
    else
        echo -e "${PURPLE}║ ${RED}${CROSS} Sesi WA${NC}   : Tidak aktif (Jalankan Menu 3)"
    fi
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

pause() {
    echo ""
    read -p "Tekan [Enter] untuk kembali ke menu..."
}

# --- FUNGSI MENU ---

run_installation() {
    display_header
    echo -e "\n${CYAN}${BOLD}--- Menu 1: Instalasi & Pembaruan ---${NC}\n"
    node "$INSTALL_SCRIPT"
    pause
}

setup_env_config() {
    display_header
    echo -e "\n${CYAN}${BOLD}--- Menu 2: Konfigurasi Bot ---${NC}\n"
    # (Logika ini sama seperti sebelumnya, tidak perlu diubah)
    touch "$ENV_FILE"
    CURRENT_KEY=$(grep 'GEMINI_API_KEY' "$ENV_FILE" | cut -d'=' -f2)
    CURRENT_PHONE=$(grep 'PHONE_NUMBER' "$ENV_FILE" | cut -d'=' -f2)
    read -p "Masukkan Gemini API Key: " api_key
    read -p "Masukkan Nomor WA (62...): " phone_number
    echo "Pilih Model (1=pro, 2=flash) [2]:"; read -p "Pilihan: " model_choice
    api_key=${api_key:-$CURRENT_KEY}; phone_number=${phone_number:-$CURRENT_PHONE}
    case ${model_choice:-2} in 1) model="gemini-pro" ;; *) model="gemini-1.5-flash" ;; esac
    echo "GEMINI_API_KEY=$api_key" > "$ENV_FILE"
    echo "GEMINI_MODEL=$model" >> "$ENV_FILE"
    echo "PHONE_NUMBER=$phone_number" >> "$ENV_FILE"
    echo -e "\n${GREEN}${TICK} Konfigurasi berhasil disimpan di ${BOLD}$ENV_FILE${NC}."
    pause
}

run_authentication() {
    display_header
    echo -e "\n${CYAN}${BOLD}--- Menu 3: Hubungkan WhatsApp ---${NC}\n"
    if [ ! -d "$MODULES_DIR" ]; then
        echo -e "${RED}${CROSS} Harap jalankan instalasi (Menu 1) terlebih dahulu.${NC}"
        pause; return
    fi
    
    echo "Pilih Metode Login:"
    echo "1. Scan QR Code (Paling Stabil)"
    echo "2. Kode 8 Digit"
    read -p "Pilihan Anda [1]: " choice
    
    case ${choice:-1} in
        1) node "$AUTH_SCRIPT" --method=qr ;;
        2) node "$AUTH_SCRIPT" --method=code ;;
        *) echo -e "${RED}Pilihan tidak valid.${NC}" ;;
    esac
    pause
}

run_bot() {
    display_header
    echo -e "\n${GREEN}${BOLD}--- Menu 4: Jalankan Bot ---${NC}\n"
    if ! [ -d "$MODULES_DIR" ] || ! [ -f "$ENV_FILE" ] || ! [ -d "$AUTH_DIR" ]; then
        echo -e "${RED}${CROSS} Semua status harus ${GREEN}✅${RED} sebelum bot bisa dijalankan.${NC}"
        pause; return
    fi
    
    echo "Bot sedang online... Tekan CTRL+C untuk berhenti."
    node "$MAIN_SCRIPT"
    echo -e "\n${YELLOW}Bot telah berhenti.${NC}"
    pause
}

reset_session() {
    display_header
    echo -e "\n${YELLOW}${BOLD}--- Menu 5: Reset Sesi ---${NC}\n"
    if [ -d "$AUTH_DIR" ]; then
        read -p "Anda yakin ingin menghapus sesi login saat ini? (y/n): " confirm
        if [[ "$confirm" == "y" ]]; then
            rm -rf "$AUTH_DIR"
            echo -e "${GREEN}${TICK} Sesi berhasil dihapus. Silakan hubungkan ulang.${NC}"
        else
            echo "Reset dibatalkan."
        fi
    else
        echo "Tidak ada sesi aktif untuk dihapus."
    fi
    pause
}

# --- LOOP MENU UTAMA ---
check_dependencies
while true; do
    display_header
    display_status

    READY_TO_RUN=false
    if [ -d "$MODULES_DIR" ] && [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=." "$ENV_FILE" && [ -d "$AUTH_DIR" ]; then
        READY_TO_RUN=true
    fi

    echo -e "${PURPLE}╔══════════════════════ M E N U   U T A M A ═════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                                 ║${NC}"
    echo -e "${PURPLE}║  ${CYAN}1. Install / Update Modules${NC}                              ║"
    echo -e "${PURPLE}║  ${CYAN}2. Konfigurasi (API Key, No HP)${NC}                          ║"
    echo -e "${PURPLE}║  ${CYAN}3. Hubungkan Akun WhatsApp${NC}                               ║"
    if $READY_TO_RUN; then
        echo -e "${PURPLE}║  ${GREEN}${BOLD}4. Jalankan Bot${NC}                                          ║"
    else
        echo -e "${PURPLE}║  ${RED}4. Jalankan Bot (Belum Siap)${NC}                              ║"
    fi
    echo -e "${PURPLE}║  ${YELLOW}5. Reset Sesi WhatsApp${NC}                                   ║"
    echo -e "${PURPLE}║  ${RED}0. Keluar dari Skrip${NC}                                     ║"
    echo -e "${PURPLE}║                                                                 ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "Masukkan pilihan Anda: " choice

    case $choice in
        1) run_installation;;
        2) setup_env_config;;
        3) run_authentication;;
        4) run_bot;;
        5) reset_session;;
        0) echo -e "\n${CYAN}Terima kasih telah menggunakan Maww Script! Sampai jumpa!${NC}"; exit 0;;
        *) echo -e "\n${RED}Pilihan tidak valid!${NC}"; pause;;
    esac
done