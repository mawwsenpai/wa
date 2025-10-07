#!/bin/bash

# =======================================================
# main.sh (Maww Script V4.3) - FINAL FIX ALUR WA
# =======================================================

# --- KONFIGURASI DAN WARNA ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_FILE="gemini-asisten.js"
PHONE_FILE=".phone_number"
API_FILE=".gemini_config"
AUTH_DIR="auth_info_baileys"
LOG_FILE="install_log_$(date +%Y%m%d_%H%M%S).txt"
VERSION="V4.3"

# --- FUNGSI ANALISIS STATUS LENGKAP ---

get_status_icon() {
    local check_result=$1
    if [ "$check_result" = "✓" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
}

check_nodejs_status() { command -v node &> /dev/null && echo "✓" || echo "✗"; }
check_gemini_status() { [ -f "$API_FILE" ] && echo "✓" || echo "✗"; }
check_logic_file() { [ -f "$SCRIPT_FILE" ] && echo "✓" || echo "✗"; }
check_session_status() { [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ] && echo "✓" || echo "✗"; }

# --- FUNGSI TAMPILAN UI RINGKAS ---
display_header() {
    if ! command -v tput &> /dev/null; then
        pkg install ncurses -y > /dev/null 2>&1
    fi
    tput clear
    
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${CYAN}       🤖 MAWW SCRIPT $VERSION - RINGKAS 🤖     ${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    NODE_STATUS=$(check_nodejs_status)
    GEMINI_STATUS=$(check_gemini_status)
    LOGIC_STATUS=$(check_logic_file)
    SESSION_STATUS=$(check_session_status)

    STATUS_LINE="⚡️Nodejs $(get_status_icon $NODE_STATUS) | 🔑Gemini $(get_status_icon $GEMINI_STATUS) | 🧠Logic $(get_status_icon $LOGIC_STATUS) | 🔗Session $(get_status_icon $SESSION_STATUS)"
    
    echo -e " ${PURPLE}STATUS > ${CYAN}$STATUS_LINE${NC}"
    echo -e "----------------------------------------"
}

pause() {
    echo -e "----------------------------------------"
    read -p "Tekan [Enter] untuk kembali ke menu..."
}

# 1. Install-Path (Fix Log & Modul)
install_path() {
    tput clear
    echo -e "================================================="
    echo -e "    BOT WA SETUP - STARTING ANALISIS SISTEM    "
    echo -e "================================================="
    echo -e "Waktu mulai: $(date)"
    echo -e "Log instalasi: ${YELLOW}$LOG_FILE${NC}"
    
    (
        echo "==================== LOG INSTALASI MAWW SCRIPT V4 ===================="
        echo -e "\n[TOOLS] Memastikan tools wajib terinstal (Node.js & ncurses)..."
        pkg update -y
        pkg install ncurses nodejs -y 
        
        echo -e "\n[FILE] Menyiapkan file proyek..."
        npm init -y > /dev/null
        if [ ! -f "$SCRIPT_FILE" ]; then touch "$SCRIPT_FILE"; fi
        chmod +x main.sh
        
        echo -e "\n[NPM] MENGINSTAL LIBRARY WAJIB (Baileys & Google GenAI)..."
        rm -rf node_modules package-lock.json 
        npm install @google/genai @whiskeysockets/baileys
        if [ $? -ne 0 ]; then
            echo -e "[NPM] GAGAL: Instalasi library gagal."
            exit 1
        fi
        echo "==================== LOG SELESAI ===================="
    ) > "$LOG_FILE" 2>&1

    echo -e "${GREEN}   ✅ Instalasi Selesai! Log detail di $LOG_FILE.${NC}"
    echo -e "${YELLOW}   LANGKAH WAJIB: Isi kode ${GREEN}$SCRIPT_FILE${NC} dengan kode dari Gemini!${NC}"
    
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
    echo -e "${PURPLE}>> 3. KONFIGURASI GEMINI API ${NC}"
    echo -e "----------------------------------------"
    echo -e "Pilih Model yang kamu mau, Cuy:"
    echo "1. gemini-pro"
    echo "2. gemini-1.5-flash"
    read -p "Pilihan Model [1/2]: " model_choice
    
    selected_model=""
    case $model_choice in
        1) selected_model="gemini-pro" ;;
        2) selected_model="gemini-1.5-flash" ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; pause; return ;;
    esac
    
    read -p "Masukan Apikey Gemini (Wajib!): " api_key

    echo "GEMINI_API_KEY=\"$api_key\"" > "$API_FILE"
    echo "GEMINI_MODEL=\"$selected_model\"" >> "$API_FILE"
    echo -e "${GREEN}✅ Konfigurasi Gemini tersimpan di $API_FILE!${NC}"
    pause
}

# 4. Fungsi Utama Menjalankan Bot (Run)
run_bot() {
    display_header
    
    # Cek kelengkapan FILE WAJIB
    if [ "$(check_nodejs_status)" != "✓" ] || [ "$(check_logic_file)" != "✓" ] || [ "$(check_gemini_status)" != "✓" ]; then
        echo -e "${RED}❌ Konfigurasi File Dasar Belum Lengkap! Pastikan Menu 1 dan 3 sudah selesai.${NC}"
        pause; return
    fi
    if [ ! -f "$PHONE_FILE" ]; then
        echo -e "${RED}❌ Nomor WA belum dikonfigurasi! Harap jalankan Menu 2 dulu.${NC}"
        pause; return
    fi

    echo -e "${PURPLE}>> 🚀 BOT SIAP JALAN! ${NC}"
    
    if [ "$(check_session_status)" != "✓" ]; then
        echo -e "${YELLOW}!!! PERHATIAN: Session WA Pending. Bot akan TAMPILKAN KODE 8 DIGIT! !!!${NC}"
        echo -e "${YELLOW}SEGERA SIAPKAN HP KAMU UNTUK OTENTIKASI!${NC}"
    fi
    echo -e "----------------------------------------"
    
    export GEMINI_API_KEY=$(grep 'GEMINI_API_KEY=' "$API_FILE" | cut -d'"' -f2)
    export GEMINI_MODEL=$(grep 'GEMINI_MODEL=' "$API_FILE" | cut -d'"' -f2)
    export PHONE_NUMBER=$(cat "$PHONE_FILE")
    
    echo -e "Nomor HP: ${PHONE_NUMBER}"
    echo -e "Model AI: ${GEMINI_MODEL}"
    echo -e "========================================"

    node "$SCRIPT_FILE"
    
    echo -e "========================================"
    echo -e "${YELLOW}BOT BERHENTI. Cek session atau error di atas.${NC}"
    pause
}


# --- LOOP MENU UTAMA ---
pkg install ncurses -y > /dev/null 2>&1 
while true; do
    display_header
    
    NODE_OK=$(check_nodejs_status)
    LOGIC_OK=$(check_logic_file)
    GEMINI_OK=$(check_gemini_status)
    SESSION_OK=$(check_session_status)
    
    echo -e "${PURPLE}>> PILIH MENU ${NC}"
    echo -e "----------------------------------------"

    echo -e "1. ${YELLOW}Install-Path (Instalasi & Perbaikan File Wajib)${NC}"
    echo "2. Konfigurasi Nomor WA"
    echo "3. Konfigurasi Gemini API"

    # FIX: Dynamic Menu 4 Label
    if [ "$NODE_OK" = "✓" ] && [ "$LOGIC_OK" = "✓" ] && [ "$GEMINI_OK" = "✓" ]; then
        if [ "$SESSION_OK" = "✓" ]; then
            echo -e "4. ${GREEN}Mulai Bot (Online / Session Aktif)${NC}"
        else
            echo -e "4. ${YELLOW}Mulai Bot (Otentikasi WA / Kode 8 Digit)${NC}" 
        fi
    else
        echo "4. Mulai Bot (Konfigurasi File belum lengkap)"
    fi
    
    echo "0. Keluar"
    echo -e "----------------------------------------"
    
    read -p "Pilihan Anda: " choice

    case $choice in
        1) install_path ;;
        2) setup_whatsapp_auth ;;
        3) setup_gemini_api ;;
        4) run_bot ;;
        0) echo -e "${CYAN}Sampai Jumpa, Cuy!${NC}"; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; pause ;;
    esac
done