#!/bin/bash

# =======================================================
# main.sh (Maww Script V2) - Starter dan Setup Menu
# Versi Rapi dan Fix Tput
# =======================================================

# --- KONFIGURASI DAN FILE ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
SCRIPT_FILE="gemini-asisten.js"
PHONE_FILE=".phone_number"
API_FILE=".gemini_config"
LOG_FILE="install_log_$(date +%Y%m%d_%H%M%S).txt"

# --- FUNGSI UTILITY ---

# Cek & Install Tools Wajib (Fix tput command not found)
install_required_tools() {
    pkg update -y
    if ! command -v tput &> /dev/null; then
        echo -e "${YELLOW}   ⏳ Menginstal paket 'ncurses' untuk tampilan rapi...${NC}"
        pkg install ncurses -y > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}   ❌ Gagal instal ncurses. Tampilan mungkin kurang rapi.${NC}"
        fi
    fi
}

# Tampilkan Header dan Status
display_header() {
    tput clear # Bersihkan layar pakai tput yang sudah diinstal
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}       🤖 MAWW SCRIPT V2 - BOT WA 🤖     ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "Nodejs : $(check_nodejs_status)"
    echo -e "Gemini : $(check_gemini_status)"
    echo -e "----------------------------------------"
}

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

pause() {
    echo -e "----------------------------------------"
    read -p "Tekan [Enter] untuk kembali ke menu..."
}

# --- FUNGSI SETUP ---

# Fungsi Instalasi Penuh (Install-Path) - LEBIH DETAIL DAN ELEGÁN
install_path() {
    tput clear
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${GREEN}    BOT WA SETUP - STARTING ANALISIS SISTEM    ${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo -e "Waktu mulai: $(date)"
    echo -e "Log instalasi: ${YELLOW}$LOG_FILE${NC}"
    
    # Redirect semua output ke file log
    (
        echo "==================== LOG INSTALASI MAWW SCRIPT V2 ===================="
        echo "Waktu Mulai: $(date)"
        echo "PATH: $(pwd)"
        echo "======================================================================"
        
        # --- 1. INSTALASI PRASYARAT (NODE.JS) ---
        echo -e "\n${BLUE}>> 1. MEMERIKSA DAN MENGINSTAL NODE.JS...${NC}"
        if command -v node &> /dev/null
        then
            echo -e "   [NODE] Status: Node.js sudah terinstal. (Versi: $(node -v))"
        else
            echo -e "   [NODE] Status: Node.js belum terinstal. Memulai instalasi..."
            pkg install nodejs -y 
            if [ $? -ne 0 ]; then
                echo -e "   [NODE] GAGAL: Instalasi Node.js gagal."
                exit 1
            fi
            echo -e "   [NODE] Sukses: Node.js berhasil diinstal."
        fi

        # --- 2. SETUP FILE PROYEK ---
        echo -e "\n${BLUE}>> 2. MENYIAPKAN FILE DAN FOLDER PROYEK...${NC}"
        
        # Membuat package.json
        echo -e "   [NPM] Status: Membuat package.json..."
        npm init -y > /dev/null
        echo -e "   [NPM] Sukses: package.json berhasil dibuat."

        # Membuat file gemini-asisten.js (otomatis isi kode placeholder)
        if [ ! -f "$SCRIPT_FILE" ]; then
            echo -e "   [FILE] Status: Membuat $SCRIPT_FILE (Otak Bot)..."
            # Buat file kosong, user harus paste kode nanti
            touch "$SCRIPT_FILE"
            echo -e "   [FILE] Sukses: $SCRIPT_FILE berhasil dibuat. (Perlu diisi kode!)"
        else
            echo -e "   [FILE] Status: $SCRIPT_FILE sudah ada. Tidak ditimpa."
        fi

        # Membuat main.sh (sudah ada, hanya memastikan izin eksekusi)
        echo -e "   [FILE] Status: Memastikan main.sh memiliki izin eksekusi..."
        chmod +x main.sh
        echo -e "   [FILE] Sukses: Izin eksekusi main.sh disetel."

        # --- 3. MENGUNDUH DAN INSTALASI LIBRARY ---
        echo -e "\n${BLUE}>> 3. MENGUNDUH DAN MENGINSTAL LIBRARY (BAILEYS & GEMINI)...${NC}"
        echo -e "   [NPM] Status: Memulai instalasi Baileys dan Google GenAI..."
        npm install @whiskeysockets/baileys @google/genai
        if [ $? -ne 0 ]; then
            echo -e "   [NPM] GAGAL: Instalasi library gagal."
            exit 1
        fi
        echo -e "   [NPM] Sukses: Semua library terinstal di node_modules/."

        echo "==================== LOG SELESAI ===================="
        echo "Waktu Selesai: $(date)"
        echo "====================================================="
    ) > "$LOG_FILE" 2>&1 # Tutup redirect log

    # Tampilkan hasil setelah log selesai
    echo -e "${GREEN}   ✅ Instalasi Selesai! Cek $LOG_FILE untuk log detail.${NC}"
    echo -e "${YELLOW}   CATATAN: Log instalasi sudah dibuat dengan detail.${NC}"

    echo -e "\n${BLUE}DAFTAR FILE/FOLDER YANG SIAP DIGUNAKAN:${NC}"
    echo -e "----------------------------------------"
    echo -e "1. ${GREEN}gemini-asisten.js${NC}: ${YELLOW}WAJIB diisi kode bot + AI.${NC}"
    echo -e "2. ${GREEN}main.sh${NC}: Menu utama ini."
    echo -e "3. ${GREEN}node_modules/${NC}: Library Bot."
    echo -e "4. ${GREEN}package.json${NC}: Manifest Proyek."
    echo -e "5. ${GREEN}.gemini_config${NC} & ${GREEN}.phone_number${NC}: Akan dibuat di menu Konfigurasi."
    echo -e "----------------------------------------"
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

# Fungsi Utama Menjalankan Bot
run_bot() {
    display_header
    
    # Cek kelengkapan konfigurasi
    if [ "$(check_gemini_status)" != "$(echo -e "${GREEN}✓ [Aktif]${NC}")" ] || [ ! -f "$PHONE_FILE" ] || [ "$(check_setup_status)" == "SETUP_NEEDED" ]; then
        echo -e "${RED}❌ Konfigurasi Belum Lengkap! Pastikan Menu 1, 2, dan 3 sudah selesai.${NC}"
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


# --- LOOP MENU UTAMA ---
install_required_tools # Install tput dulu
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