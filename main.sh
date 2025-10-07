#!/bin/bash

# =======================================================
# main.sh (Maww Script V5.0) - Refactored by Gemini
# Perubahan:
# - UI/Tampilan menu lebih modern dan informatif.
# - Menggunakan file .env untuk semua konfigurasi.
# - Opsi otentikasi (QR/Kode) dipilih dari menu.
# - Penambahan menu reset sesi.
# - Struktur kode lebih bersih dan modular.
# =======================================================

# --- KONFIGURASI DAN WARNA ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# --- NAMA FILE KONFIGURASI ---
ENV_FILE=".env"
INSTALL_SCRIPT="install.js"
AUTH_SCRIPT="auth.js"
MAIN_SCRIPT="main.js"
AUTH_DIR="auth_info_baileys"
VERSION="V5.0"

# --- FUNGSI UTAMA ---

clear_screen() {
    if ! command -v tput &> /dev/null; then
        echo -e "${YELLOW}Paket 'ncurses-utils' tidak ditemukan. Menginstal...${NC}"
        pkg install ncurses-utils -y > /dev/null 2>&1
    fi
    tput clear
}

display_header() {
    clear_screen
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${CYAN}${BOLD}         🤖 MAWW SCRIPT $VERSION - REFACTORED BY GEMINI 🤖         ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
}

display_status() {
    echo -e "${PURPLE}╟─ STATUS PRASYARAT ───────────────────────────────────────╢${NC}"

    # 1. Cek Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v)
        echo -e "${PURPLE}║${NC} ${GREEN}✓${NC} ${BOLD}Node.js${NC}: Terinstal (versi ${NODE_VERSION})"
    else
        echo -e "${PURPLE}║${NC} ${RED}✗${NC} ${BOLD}Node.js${NC}: Belum terinstal"
    fi

    # 2. Cek File Konfigurasi .env
    if [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=.*" "$ENV_FILE"; then
        echo -e "${PURPLE}║${NC} ${GREEN}✓${NC} ${BOLD}Gemini API${NC}: Kunci API sudah diatur di ${ENV_FILE}"
    else
        echo -e "${PURPLE}║${NC} ${RED}✗${NC} ${BOLD}Gemini API${NC}: Kunci API belum diatur di ${ENV_FILE}"
    fi

    # 3. Cek Sesi WA
    if [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ]; then
        echo -e "${PURPLE}║${NC} ${GREEN}✓${NC} ${BOLD}Sesi WA${NC}: Aktif (folder ${AUTH_DIR} ditemukan)"
    else
        echo -e "${PURPLE}║${NC} ${RED}✗${NC} ${BOLD}Sesi WA${NC}: Tidak aktif"
    fi

    echo -e "${PURPLE}╟────────────────────────────────────────────────────────────╢${NC}"
}

pause() {
    echo ""
    read -p "Tekan [Enter] untuk kembali ke menu..."
}

# --- FUNGSI MENU ---

run_installation() {
    display_header
    echo -e "\n${YELLOW}${BOLD}Memulai proses instalasi dan penyiapan...${NC}\n"
    if ! command -v node &> /dev/null; then
        echo "Node.js belum terinstal. Menginstal sekarang..."
        pkg install nodejs -y
        if [ $? -ne 0 ]; then echo -e "${RED}Gagal menginstal Node.js.${NC}"; pause; return; fi
    fi
    node "$INSTALL_SCRIPT"
    pause
}

setup_env_config() {
    display_header
    echo -e "\n${CYAN}${BOLD}--- PENGATURAN KONFIGURASI (.env) ---${NC}\n"
    touch "$ENV_FILE"
    CURRENT_KEY=$(grep 'GEMINI_API_KEY' "$ENV_FILE" | cut -d'=' -f2)
    CURRENT_PHONE=$(grep 'PHONE_NUMBER' "$ENV_FILE" | cut -d'=' -f2)
    read -p "Masukkan Gemini API Key [${CURRENT_KEY}]: " api_key
    read -p "Masukkan Nomor WA (62...) [${CURRENT_PHONE}]: " phone_number
    echo "Pilih Model Gemini (1=pro, 2=flash) [2]:"
    read -p "Pilihan: " model_choice
    api_key=${api_key:-$CURRENT_KEY}
    phone_number=${phone_number:-$CURRENT_PHONE}
    case ${model_choice:-2} in 1) model="gemini-pro" ;; *) model="gemini-1.5-flash" ;; esac
    echo "GEMINI_API_KEY=$api_key" > "$ENV_FILE"
    echo "GEMINI_MODEL=$model" >> "$ENV_FILE"
    echo "PHONE_NUMBER=$phone_number" >> "$ENV_FILE"
    echo -e "\n${GREEN}✓ Konfigurasi berhasil disimpan di ${BOLD}$ENV_FILE${NC}."
    pause
}

run_authentication() {
    display_header
    echo -e "\n${CYAN}${BOLD}--- OTENTIKASI WHATSAPP ---${NC}\n"
    if [ ! -f "$AUTH_SCRIPT" ]; then echo -e "${RED}File ${AUTH_SCRIPT} tidak ditemukan.${NC}"; pause; return; fi
    echo "Pilih Metode: 1. Scan QR (Stabil) 2. Kode 8 Digit"
    read -p "Pilihan [1]: " choice
    case ${choice:-1} in 1) node "$AUTH_SCRIPT" --method=qr ;; 2) node "$AUTH_SCRIPT" --method=code ;; *) echo -e "${RED}Pilihan tidak valid.${NC}" ;; esac
    pause
}

run_bot() {
    display_header
    echo -e "\n${GREEN}${BOLD}--- MENJALANKAN BOT ---${NC}\n"
    if ! command -v node &> /dev/null || [ ! -f "$ENV_FILE" ] || [ ! -d "$AUTH_DIR" ]; then
        echo -e "${RED}✗ Prasyarat belum terpenuhi! Pastikan semua status ✓.${NC}"
        pause
        return
    fi
    echo "Bot sedang online... Tekan CTRL+C untuk berhenti."
    node "$MAIN_SCRIPT"
    echo -e "\n${YELLOW}Bot telah berhenti.${NC}"
    pause
}

reset_session() {
    display_header
    echo -e "\n${YELLOW}${BOLD}--- RESET SESI WHATSAPP ---${NC}\n"
    if [ -d "$AUTH_DIR" ]; then
        read -p "Anda yakin ingin menghapus sesi login? (y/n): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            rm -rf "$AUTH_DIR"
            echo -e "${GREEN}✓ Sesi berhasil dihapus.${NC}"
        else
            echo "Reset dibatalkan."
        fi
    else
        echo "Tidak ada sesi aktif untuk dihapus."
    fi
    pause
}

# --- LOOP MENU UTAMA ---
while true; do
    display_header
    display_status
    READY_TO_RUN=false
    if command -v node &> /dev/null && [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=.*" "$ENV_FILE" && [ -d "$AUTH_DIR" ]; then READY_TO_RUN=true; fi
    echo -e "${PURPLE}╟─ MENU UTAMA ─────────────────────────────────────────────╢${NC}"
    echo -e "${PURPLE}║${NC} 1. ${CYAN}Install / Update Dependencies${NC}"
    echo -e "${PURPLE}║${NC} 2. ${CYAN}Konfigurasi (API Key, No WA, Model)${NC}"
    echo -e "${PURPLE}║${NC} 3. ${CYAN}Hubungkan WhatsApp (Otentikasi)${NC}"
    if [ "$READY_TO_RUN" = true ]; then echo -e "${PURPLE}║${NC} 4. ${GREEN}${BOLD}Jalankan Bot${NC}"; else echo -e "${PURPLE}║${NC} 4. ${RED}Jalankan Bot (Belum Siap)${NC}"; fi
    echo -e "${PURPLE}║${NC} 5. ${YELLOW}Reset Sesi WhatsApp${NC}"
    echo -e "${PURPLE}║${NC} 0. ${RED}Keluar${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Masukkan pilihan Anda: " choice
    case $choice in 1) run_installation;; 2) setup_env_config;; 3) run_authentication;; 4) run_bot;; 5) reset_session;; 0) echo -e "\n${CYAN}Sampai jumpa!${NC}"; exit 0;; *) echo -e "\n${RED}Pilihan tidak valid!${NC}"; pause;; esac
done