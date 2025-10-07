#!/bin/bash

# =======================================================
# main.sh (Maww Script V5) - FINAL UI & PROPORSIONAL
# =======================================================

# --- KONFIGURASI DAN WARNA ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

WA_CONFIG_FILE="wa-config.js"
GEMINI_CONFIG_FILE="gemini-config.js"
INSTALL_CONFIG_FILE="install-config.js"
MAIN_RUN_FILE="main.js"

PHONE_FILE=".phone_number"
API_FILE=".gemini_config"
AUTH_DIR="auth_info_baileys"
VERSION="V5"

# --- FUNGSI ANALISIS STATUS LENGKAP ---

get_status_icon() { local check_result=$1; [ "$check_result" = "✓" ] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"; }
check_nodejs_status() { command -v node &> /dev/null && echo "✓" || echo "✗"; }
check_gemini_status() { [ -f "$API_FILE" ] && echo "✓" || echo "✗"; }
check_session_status() { [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ] && echo "✓" || echo "✗"; }
check_all_files_exist() { 
    if [ -f "$WA_CONFIG_FILE" ] && [ -f "$GEMINI_CONFIG_FILE" ] && [ -f "$MAIN_RUN_FILE" ]; then 
        echo "✓" 
    else 
        echo "✗"
    fi
}


# --- FUNGSI TAMPILAN UI RINGKAS ---
display_header() {
    tput clear
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${CYAN}       🤖 MAWW SCRIPT $VERSION - FINAL 🤖     ${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    NODE_STATUS=$(check_nodejs_status)
    GEMINI_STATUS=$(check_gemini_status)
    SESSION_STATUS=$(check_session_status)
    FILES_OK=$(check_all_files_exist)

    STATUS_LINE="⚡️Nodejs $(get_status_icon $NODE_STATUS) | 🔑Gemini $(get_status_icon $GEMINI_STATUS) | 🔗Session $(get_status_icon $SESSION_STATUS) | 🧠Files $(get_status_icon $FILES_OK)"
    
    echo -e " ${PURPLE}STATUS > ${CYAN}$STATUS_LINE${NC}"
    echo -e "----------------------------------------"
}

pause() {
    echo -e "----------------------------------------"
    read -p "Tekan [Enter] untuk kembali ke menu..."
}

# --- FUNGSI MENU ---

# 1. Install-Config (Download Modules)
install_config() {
    display_header
    echo -e "${PURPLE}>> 1. INSTALASI & DOWNLOAD FILES ${NC}"
    echo -e "----------------------------------------"
    
    if [ "$(check_nodejs_status)" = "✗" ]; then
        echo -e "${YELLOW}⏳ Node.js belum terinstal. Menginstal sekarang...${NC}"
        pkg install nodejs -y
        if [ $? -ne 0 ]; then echo -e "${RED}❌ Gagal instal Node.js.${NC}"; pause; return; fi
    fi
    
    # Menjalankan logic instalasi dari file JS
    echo -e "${YELLOW}⏳ Menjalankan $INSTALL_CONFIG_FILE untuk download modules...${NC}"
    node "$INSTALL_CONFIG_FILE"
    
    echo -e "${GREEN}✅ Instalasi Modules Selesai!${NC}"
    
    pause
}

# 2. Konfigurasi WA
setup_whatsapp_auth() {
    display_header
    echo -e "${PURPLE}>> 2. KONFIGURASI NOMOR WA ${NC}"
    echo -e "----------------------------------------"
    read -p "Masukan Nomer WA Kamu (cth: 62812...): " phone_number
    
    echo "$phone_number" > "$PHONE_FILE"
    echo -e "${GREEN}✅ Nomor HP tersimpan di $PHONE_FILE!${NC}"
    
    pause
}

# 3. Konfigurasi Gemini API
setup_gemini_api() {
    display_header
    # ... (Kode Konfigurasi Gemini API) ...
    echo -e "${PURPLE}>> 3. KONFIGURASI GEMINI API ${NC}"
    echo -e "----------------------------------------"
    read -p "Masukan Apikey Gemini (Wajib!): " api_key
    echo "GEMINI_API_KEY=\"$api_key\"" > "$API_FILE"
    echo "GEMINI_MODEL=\"gemini-1.5-flash\"" >> "$API_FILE"
    echo -e "${GREEN}✅ Konfigurasi Gemini tersimpan!${NC}"
    pause
}

# 4. Otentikasi WA (Membuat Session)
authenticate_wa() {
    display_header

    if [ "$(check_session_status)" = "✓" ]; then
        echo -e "${GREEN}✅ Session sudah Aktif! Langsung ke Menu 5 (Run).${NC}"
        pause; return
    fi
    
    # Cek Prasyarat WA Otentikasi
    if [ "$(check_nodejs_status)" = "✗" ] || [ ! -f "$PHONE_FILE" ]; then
        echo -e "${RED}❌ Prasyarat Gagal. Cek Nodejs (Menu 1) dan Nomor WA (Menu 2).${NC}"
        pause; return
    fi
    
    echo -e "${YELLOW}⏳ Memulai Otentikasi WA (Kode 8 Digit)...${NC}"
    
    # Eksport variabel sebelum menjalankan wa-config.js
    export PHONE_NUMBER=$(cat "$PHONE_FILE")
    
    # Jalankan logic autentikasi
    node "$WA_CONFIG_FILE"
    
    pause
}

# 5. Run Bot (Setelah Semua ✓)
run_bot() {
    display_header
    
    # Cek Kunci (Semua wajib ✓)
    if [ "$(check_nodejs_status)" != "✓" ] || [ "$(check_session_status)" != "✓" ] || [ "$(check_gemini_status)" != "✓" ] || [ "$(check_all_files_exist)" != "✓" ]; then
        echo -e "${RED}❌ KUNCI GAGAL: Semua status di atas harus '✓' sebelum RUN!${NC}"
        pause; return
    fi

    echo -e "${GREEN}>> 🚀 BOT SIAP ONLINE! ${NC}"
    echo -e "----------------------------------------"
    
    # Eksport konfigurasi dari file
    export GEMINI_API_KEY=$(grep 'GEMINI_API_KEY=' "$API_FILE" | cut -d'"' -f2)
    export GEMINI_MODEL=$(grep 'GEMINI_MODEL=' "$API_FILE" | cut -d'"' -f2)
    
    echo -e "Model AI: ${GEMINI_MODEL}"
    echo -e "========================================"

    # Jalankan Bot Utama
    node "$MAIN_RUN_FILE"
    
    echo -e "========================================"
    echo -e "${YELLOW}BOT BERHENTI.${NC}"
    pause
}


# --- LOOP MENU UTAMA ---
pkg install ncurses -y > /dev/null 2>&1 
while true; do
    display_header
    
    # Kunci untuk Menu RUN (Menu 5)
    READY_TO_RUN="✗"
    if [ "$(check_nodejs_status)" = "✓" ] && [ "$(check_session_status)" = "✓" ] && [ "$(check_gemini_status)" = "✓" ] && [ "$(check_all_files_exist)" = "✓" ]; then
        READY_TO_RUN="✓"
    fi
    
    echo -e "${PURPLE}>> PILIH MENU ${NC}"
    echo -e "----------------------------------------"

    echo -e "1. ${YELLOW}Install-Config (Instalasi Modules/Files)${NC}"
    echo "2. Konfigurasi Nomor WA"
    echo "3. Konfigurasi Gemini API"
    echo "4. Otentikasi WA (Kode 8 Digit)"

    if [ "$READY_TO_RUN" = "✓" ]; then
        echo -e "5. ${GREEN}Mulai Bot (RUN / ONLINE)${NC}"
    else
        echo "5. Mulai Bot (Konfigurasi belum lengkap)"
    fi
    
    echo "0. Keluar"
    echo -e "----------------------------------------"
    
    read -p "Pilihan Anda: " choice

    case $choice in
        1) install_config ;;
        2) setup_whatsapp_auth ;;
        3) setup_gemini_api ;;
        4) authenticate_wa ;;
        5) run_bot ;;
        0) echo -e "${CYAN}Sampai Jumpa, Cuy!${NC}"; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; pause ;;
    esult/ncurses/bin/tput" ;;
    esac
done