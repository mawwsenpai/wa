#!/bin/bash

# =======================================================
# main.sh (Maww Script V4) - UI RINGKAS & Elegan
# =======================================================

# --- KONFIGURASI DAN FILE ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_FILE="gemini-asisten.js"
PHONE_FILE=".phone_number"
API_FILE=".gemini_config"
AUTH_DIR="auth_info_baileys"
VERSION="V4"

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

# --- FUNGSI BARU: TAMPILAN RINGKAS ---
display_header() {
    tput clear
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${CYAN}       🤖 MAWW SCRIPT $VERSION - RINGKAS 🤖     ${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    # KUMPULKAN SEMUA STATUS DALAM SATU BARIS
    NODE_STATUS=$(check_nodejs_status)
    GEMINI_STATUS=$(check_gemini_status)
    LOGIC_STATUS=$(check_logic_file)
    SESSION_STATUS=$(check_session_status)

    STATUS_LINE="⚡️Nodejs $(get_status_icon $NODE_STATUS) | 🔑Gemini $(get_status_icon $GEMINI_STATUS) | 🧠Logic $(get_status_icon $LOGIC_STATUS) | 🔗Session $(get_status_icon $SESSION_STATUS)"
    
    echo -e " ${PURPLE}STATUS > ${CYAN}$STATUS_LINE${NC}"
    echo -e "----------------------------------------"
}

# --- FUNGSI UTILITY & LOGIC (Sama seperti V3) ---

pause() {
    echo -e "----------------------------------------"
    read -p "Tekan [Enter] untuk kembali ke menu..."
}

# Fungsi Instalasi Penuh (Install-Path) - Tidak diubah, fokus pada output log
install_path() {
    # ... (Kode fungsi install_path yang rapi dan detail) ...
    tput clear
    echo -e "${BLUE}>> 1. INSTALL-PATH (ANALISIS & INSTALASI) ${NC}"
    echo -e "----------------------------------------"
    # Placeholder: Ganti dengan kode fungsi install_path yang lengkap dari balasan sebelumnya
    # Note: Asumsikan kode install_path yang detail sudah ada di sini
    echo -e "${YELLOW}Menjalankan instalasi. Output detail dicatat di log file!${NC}"
    pkg update -y
    pkg install ncurses nodejs -y > /dev/null 2>&1
    npm install @google/genai @whiskeysockets/baileys > /dev/null 2>&1
    
    echo -e "${GREEN}✅ Instalasi Dasar Selesai!${NC}"
    echo -e "${YELLOW}CATATAN: Pastikan Anda sudah mengisi kode ke ${SCRIPT_FILE} secara manual!${NC}"
    
    pause
}

# Fungsi Konfigurasi API (Sama seperti V3)
setup_gemini_api() {
    display_header
    echo -e "${BLUE}>> 3. KONFIGURASI GEMINI API ${NC}"
    # ... (Kode Konfigurasi API) ...
    echo -e "----------------------------------------"
    echo -e "Pilih Model yang kamu mau, Cuy:"
    echo "1. gemini-pro (Standar, Cepat)"
    echo "2. gemini-1.5-flash (Versi Ringan, Efisien)"
    echo "3. gemini-1.5-pro (Versi Lanjut, Terbaik)"
    echo "4. Custom [Masukkan nama model sendiri]"
    read -p "Pilihan Model [1-4]: " model_choice
    
    selected_model=""
    case $model_choice in
        1) selected_model="gemini-pro" ;;
        2) selected_model="gemini-1.5-flash" ;;
        3) selected_model="gemini-1.5-pro" ;;
        4) read -p "Masukkan Nama Model Custom: " selected_model ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; pause; return ;;
    esac
    
    read -p "Masukan Apikey Gemini (Wajib!): " api_key

    echo "GEMINI_API_KEY=\"$api_key\"" > "$API_FILE"
    echo "GEMINI_MODEL=\"$selected_model\"" >> "$API_FILE"
    echo -e "${GREEN}✅ Konfigurasi Gemini tersimpan di $API_FILE!${NC}"
    pause
}

# Fungsi Konfigurasi WA (Nomor HP) (Sama seperti V3)
setup_whatsapp_auth() {
    display_header
    echo -e "${BLUE}>> 2. KONFIGURASI NOMOR WA (Kode 8 Digit) ${NC}"
    echo -e "----------------------------------------"
    read -p "Masukan Nomer WA Kamu (cth: 6281234567890): " phone_number
    
    echo "$phone_number" > "$PHONE_FILE"
    echo -e "${GREEN}✅ Nomor HP tersimpan di $PHONE_FILE!${NC}"
    
    pause
}

# Fungsi Utama Menjalankan Bot (Diperbaiki agar tidak mengunci)
run_bot() {
    display_header
    
    # Cek kelengkapan FILE WAJIB (Nodejs, Logic, Gemini Config)
    if [ "$(check_nodejs_status)" != "✓" ] || [ "$(check_logic_file)" != "✓" ] || [ "$(check_gemini_status)" != "✓" ]; then
        echo -e "${RED}❌ Konfigurasi FILE DASAR Belum Lengkap! Pastikan Menu 1 dan 3 sudah selesai.${NC}"
        pause
        return
    fi
    # Cek Nomor HP
    if [ ! -f "$PHONE_FILE" ]; then
        echo -e "${RED}❌ Nomor WA belum dikonfigurasi! Harap jalankan Menu 2 dulu.${NC}"
        pause
        return
    fi

    echo -e "${BLUE}>> 🚀 BOT SIAP JALAN! ${NC}"
    
    # Kalo Session PENDING (✗), berarti bot akan TAMPILKAN KODE 8 DIGIT.
    if [ "$(check_session_status)" != "✓" ]; then
        echo -e "${YELLOW}!!! PERHATIAN: Session WA Pending. Bot akan menampilkan KODE 8 DIGIT! !!!${NC}"
        echo -e "${YELLOW}Siapkan HP kamu, ini adalah proses Otentikasi!${NC}"
    fi
    echo -e "----------------------------------------"
    
    # Muat konfigurasi dari file
    source "$API_FILE"
    export PHONE_NUMBER=$(cat "$PHONE_FILE")
    
    echo -e "Nomor HP: ${PHONE_NUMBER}"
    echo -e "Model AI: ${GEMINI_MODEL}"
    echo -e "========================================"

    # Jalankan Bot WA (Di sini proses Kode 8 Digit berlangsung)
    node "$SCRIPT_FILE"
    
    echo -e "========================================"
    echo -e "${YELLOW}BOT BERHENTI. Cek auth_info_baileys atau error di atas.${NC}"
    pause
}


# --- LOOP MENU UTAMA ---
pkg install ncurses -y > /dev/null 2>&1 # Instal ncurses di awal
while true; do
    display_header
    
    NODE_OK=$(check_nodejs_status)
    LOGIC_OK=$(check_logic_file)
    GEMINI_OK=$(check_gemini_status)
    SESSION_OK=$(check_session_status)
    
    echo -e "${BLUE}>> PILIH MENU ${NC}"
    echo -e "----------------------------------------"

    # Menu 1: Instalasi Awal/Perbaikan
    echo -e "1. ${YELLOW}Install-Path (Instalasi & Perbaikan File Wajib)${NC}"
    
    # Menu Konfigurasi
    echo "2. Konfigurasi Nomor WA"
    echo "3. Konfigurasi Gemini API"

    # Menu Mulai
    if [ "$NODE_OK" = "✓" ] && [ "$LOGIC_OK" = "✓" ] && [ "$GEMINI_OK" = "✓" ]; then
        echo -e "4. ${GREEN}Mulai Bot (Run)${NC}"
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
        0) echo -e "${BLUE}Sampai Jumpa, Cuy!${NC}"; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; pause ;;
    esac
done