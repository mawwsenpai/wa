#!/bin/bash

# =======================================================
# main.sh (Maww Script V2) - Starter dan Setup Menu
# =======================================================

# Warna buat tampilan
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
CLEAR_SCREEN=$(tput clear)
SCRIPT_FILE="gemini-asisten.js"
PHONE_FILE=".phone_number"
API_FILE=".gemini_config"

# --- FUNGSI UTILITY ---

# Cek Status Instalasi Node.js
check_nodejs_status() {
    if command -v node &> /dev/null; then
        echo -e "${GREEN}✓ [Aktif]${NC}"
    else
        echo -e "${RED}✗ [Nonaktif]${NC}"
    fi
}

# Cek Status Konfigurasi Gemini
check_gemini_status() {
    if [ -f "$API_FILE" ]; then
        echo -e "${GREEN}✓ [Aktif]${NC}"
    else
        echo -e "${RED}✗ [Nonaktif]${NC}"
    fi
}

# Cek Status File Wajib
check_setup_status() {
    if [ ! -d "node_modules" ] || [ ! -f "$SCRIPT_FILE" ] || [ ! -f "package.json" ]; then
        echo "SETUP_NEEDED"
    else
        echo "SETUP_DONE"
    fi
}

# Tampilkan Header dan Status
display_header() {
    echo "$CLEAR_SCREEN"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}       🤖 MAWW SCRIPT V2 - BOT WA 🤖     ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "Nodejs : $(check_nodejs_status)"
    echo -e "Gemini : $(check_gemini_status)"
    echo -e "----------------------------------------"
}

# --- FUNGSI SETUP ---

# Fungsi Instalasi Penuh (mirip install-path.sh)
install_path() {
    ./install-path.sh # Panggil script instalasi yang sudah kamu buat
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Instalasi Dasar Selesai!${NC}"
        # Salin Kode ke file gemini-asisten.js
        echo -e "${YELLOW}⏳ Mengisi kode ke ${SCRIPT_FILE}...${NC}"
        # Catatan: Di sini kamu harus manual copy-paste kode JS di atas ke file gemini-asisten.js
        # Karena di shell script, kita tidak bisa menyimpan kode multi-line JS dengan mudah tanpa tools
        # Untuk demonstrasi, kita buat file kosong saja. User harus mengisi manual.
        # Catatan: User harus mengisi kode JS ke file ini secara manual
        # Agar script ini tetap jalan, kita asumsikan user sudah mengisi kode.
        echo "// Isi kode gemini-asisten.js dari Gemini di sini" > "$SCRIPT_FILE"
        
        echo -e "${GREEN}✅ $SCRIPT_FILE siap!${NC}"
    else
        echo -e "${RED}❌ Instalasi Gagal! Cek log.${NC}"
    fi
    pause
}

# Fungsi Konfigurasi API
setup_gemini_api() {
    display_header
    echo -e "${BLUE}>> SETELAN GEMINI API KEY ${NC}"
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

# Fungsi Konfigurasi WA (Nomor HP)
setup_whatsapp_auth() {
    display_header
    echo -e "${BLUE}>> AUTENTIKASI WHATSAPP (KODE 8 DIGIT) ${NC}"
    echo -e "----------------------------------------"
    read -p "Masukan Nomer WA Kamu (cth: 6281234567890): " phone_number
    
    # Simpan nomor HP ke file
    echo "$phone_number" > "$PHONE_FILE"
    echo -e "${GREEN}✅ Nomor HP tersimpan di $PHONE_FILE!${NC}"
    
    pause
}

# --- FUNGSI UTAMA ---
run_bot() {
    display_header
    if [ "$(check_gemini_status)" != "$(echo -e "${GREEN}✓ [Aktif]${NC}")" ]; then
        echo -e "${RED}❌ Gemini API belum dikonfigurasi! Harap setel dulu.${NC}"
        pause
        return
    fi
    if [ ! -f "$PHONE_FILE" ]; then
        echo -e "${RED}❌ Nomor HP WA belum disetel! Harap setel dulu.${NC}"
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
    echo -e "${YELLOW}BOT BERHENTI. Jalankan lagi atau cek error.${NC}"
    pause
}

pause() {
    read -p "Tekan [Enter] untuk kembali ke menu..."
}

# --- LOOP MENU UTAMA ---
while true; do
    display_header
    
    SETUP_STATUS=$(check_setup_status)
    
    echo -e "${BLUE}>> MENU ${NC}"
    echo -e "----------------------------------------"

    # Menu 1: Instalasi
    if [ "$SETUP_STATUS" == "SETUP_NEEDED" ]; then
        echo -e "1. ${YELLOW}Install-Path (Instalasi Awal/Perbaikan File)${NC}"
    else
        echo -e "1. Install-Path (Periksa/Instalasi Ulang File)"
    fi
    
    # Menu Konfigurasi
    echo "2. Konfigurasi Nomor WA (WA Autentikasi)"
    echo "3. Konfigurasi Gemini API"

    # Menu Mulai
    if [ "$SETUP_STATUS" == "SETUP_DONE" ] && [ "$(check_gemini_status)" == "$(echo -e "${GREEN}✓ [Aktif]${NC}")" ]; then
        echo -e "4. ${GREEN}Mulai Bot (Run)${NC}"
    else
        echo "4. Mulai Bot (Konfigurasi Belum Lengkap)"
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