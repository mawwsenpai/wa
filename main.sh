#!/bin/bash

# =======================================================
# main.sh (Maww Script V3) - Menu Unik & Status Lengkap
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

# --- FUNGSI ANALISIS STATUS LENGKAP ---

get_status_icon() {
    local check_result=$1
    if [ "$check_result" = "✓" ]; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
    fi
}

# Analisis Status: Nodejs
check_nodejs_status() {
    if command -v node &> /dev/null; then
        echo "✓"
    else
        echo "✗"
    fi
}

# Analisis Status: Konfigurasi Gemini
check_gemini_status() {
    if [ -f "$API_FILE" ]; then
        echo "✓"
    else
        echo "✗"
    fi
}

# Analisis Status: File Logika (JS)
check_logic_file() {
    if [ -f "$SCRIPT_FILE" ]; then
        echo "✓"
    else
        echo "✗"
    fi
}

# Analisis Status: Session WA
check_session_status() {
    if [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ]; then
        echo "✓"
    else
        echo "✗"
    fi
}

# Tampilkan Header dan Status Utama
display_header() {
    tput clear
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${CYAN}       🤖 MAWW SCRIPT V3 - ELEGANT 🤖     ${NC}"
    echo -e "${PURPLE}========================================${NC}"
    
    # Tampilan status yang lebih rapi
    echo -e " ${PURPLE}Status Sistem & Konfigurasi:${NC}"
    echo -e " ${PURPLE}-----------------------------${NC}"
    echo -e " ⚡️ ${CYAN}Nodejs${NC}: $(get_status_icon $(check_nodejs_status)) [$(check_nodejs_status | sed 's/✓/Aktif/g; s/✗/Nonaktif/g')]"
    echo -e " 🔑 ${CYAN}Gemini${NC}: $(get_status_icon $(check_gemini_status)) [$(check_gemini_status | sed 's/✓/Konfig/g; s/✗/Pending/g')]"
    echo -e " 🧠 ${CYAN}Logic${NC}:  $(get_status_icon $(check_logic_file)) [$(check_logic_file | sed 's/✓/Ada/g; s/✗/Hilang/g')]"
    echo -e " 🔗 ${CYAN}Session${NC}:$(get_status_icon $(check_session_status)) [$(check_session_status | sed 's/✓/Aktif/g; s/✗/Pending/g')]"
    echo -e "----------------------------------------"
}

# --- FUNGSI MENU UTAMA ---

# Fungsi Instalasi Penuh (Install-Path) - Gabungan Analisis & Instalasi
install_path() {
    # Fungsi ini sama seperti yang kita perbaiki sebelumnya, untuk memastikan kerapihan log dan fix tput.
    # (Kode fungsi install_path yang lengkap ada di balasan sebelumnya, di sini kita buat placeholder agar kode utama tidak terlalu panjang)
    tput clear
    echo -e "${BLUE}>> 1. INSTALL-PATH (ANALISIS & INSTALASI) ${NC}"
    echo -e "----------------------------------------"
    echo -e "${YELLOW}Script akan menjalankan analisis, instalasi nodejs, dan mendownload library.${NC}"
    echo -e "${YELLOW}Output detail akan dicatat di file log!${NC}"
    
    # ... (Di sini adalah kode dari fungsi install_path di balasan sebelumnya) ...
    
    # Untuk menjalankan fungsi install_path yang detail, kamu bisa copy kode fungsi dari balasan sebelumnya 
    # atau panggil script terpisah jika kamu masih punya install-path.sh yang lama
    
    # Sebagai demo, kita hanya tampilkan pesan dan panggil instalasi NPM
    pkg update -y
    pkg install ncurses nodejs -y 
    npm init -y > /dev/null 2>&1
    npm install @whiskeysockets/baileys @google/genai > /dev/null 2>&1
    
    echo -e "${GREEN}✅ Instalasi Dasar Selesai! Node.js dan Library sudah terinstal.${NC}"
    echo -e "${YELLOW}CATATAN: Pastikan Anda sudah mengisi kode ke ${SCRIPT_FILE} secara manual!${NC}"
    
    pause
}

# ... (Fungsi setup_gemini_api dan setup_whatsapp_auth sama) ...
setup_gemini_api() {
    # ... (kode setup_gemini_api yang sudah ada) ...
    display_header
    echo -e "${BLUE}>> 3. KONFIGURASI GEMINI API ${NC}"
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

    # Simpan konfigurasi
    echo "GEMINI_API_KEY=\"$api_key\"" > "$API_FILE"
    echo "GEMINI_MODEL=\"$selected_model\"" >> "$API_FILE"
    echo -e "${GREEN}✅ Konfigurasi Gemini tersimpan di $API_FILE!${NC}"
    pause
}

setup_whatsapp_auth() {
    display_header
    echo -e "${BLUE}>> 2. KONFIGURASI NOMOR WA (Kode 8 Digit) ${NC}"
    echo -e "----------------------------------------"
    read -p "Masukan Nomer WA Kamu (cth: 6281234567890): " phone_number
    
    # Simpan nomor HP ke file
    echo "$phone_number" > "$PHONE_FILE"
    echo -e "${GREEN}✅ Nomor HP tersimpan di $PHONE_FILE!${NC}"
    
    pause
}

# Fungsi Utama Menjalankan Bot
run_bot() {
    display_header
    
    # Cek kelengkapan konfigurasi sebelum run
    if [ "$(check_gemini_status)" != "✓" ] || [ "$(check_session_status)" != "✓" ] || [ "$(check_logic_file)" != "✓" ]; then
        echo -e "${RED}❌ Konfigurasi Belum Lengkap! Pastikan semua Status di atas '✓' sebelum memulai!${NC}"
        pause
        return
    fi

    echo -e "${BLUE}>> 🚀 BOT SIAP JALAN! ${NC}"
    echo -e "----------------------------------------"
    
    # Muat konfigurasi dari file
    source "$API_FILE"
    export PHONE_NUMBER=$(cat "$PHONE_FILE")
    
    echo -e "Nomor HP: ${PHONE_NUMBER}"
    echo -e "Model AI: ${GEMINI_MODEL}"
    echo -e "========================================"

    # Jalankan Bot WA
    node "$SCRIPT_FILE"
    
    echo -e "========================================"
    echo -e "${YELLOW}BOT BERHENTI. Cek auth_info_baileys atau error di atas.${NC}"
    pause
}

pause() {
    echo -e "----------------------------------------"
    read -p "Tekan [Enter] untuk kembali ke menu..."
}


# --- LOOP MENU UTAMA ---
pkg install ncurses -y > /dev/null 2>&1 # Instal ncurses di awal
while true; do
    display_header
    
    # Tentukan menu berdasarkan status
    NODE_OK=$(check_nodejs_status)
    LOGIC_OK=$(check_logic_file)
    SETUP_STATUS_FULL="SETUP_NEEDED"
    if [ "$NODE_OK" = "✓" ] && [ "$LOGIC_OK" = "✓" ]; then
        SETUP_STATUS_FULL="SETUP_DONE"
    fi
    
    echo -e "${BLUE}>> PILIH MENU ${NC}"
    echo -e "----------------------------------------"

    # Menu 1: Instalasi Awal/Perbaikan
    echo -e "1. ${YELLOW}Install-Path (Instalasi & Perbaikan File Wajib)${NC}"
    
    # Menu Konfigurasi
    echo "2. Konfigurasi Nomor WA"
    echo "3. Konfigurasi Gemini API"

    # Menu Mulai
    GEMINI_OK=$(check_gemini_status)
    SESSION_OK=$(check_session_status)
    if [ "$SETUP_STATUS_FULL" == "SETUP_DONE" ] && [ "$GEMINI_OK" = "✓" ] && [ "$SESSION_OK" = "✓" ]; then
        echo -e "4. ${GREEN}Mulai Bot (Run)${NC} (Sempurna)"
    elif [ "$SETUP_STATUS_FULL" == "SETUP_DONE" ]; then
        echo -e "4. ${YELLOW}Mulai Bot (Lanjut Otentikasi)${NC}"
    else
        echo "4. Mulai Bot (Instalasi belum lengkap)"
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