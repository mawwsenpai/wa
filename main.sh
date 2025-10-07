#!/bin/bash

# =======================================================
# main.sh (Maww Script V5.1) - REFINED AUTH FLOW
# Perubahan:
# - Alur Menu 3 dibuat lebih runut sesuai permintaan.
# - Skrip akan meminta/konfirmasi nomor HP langsung di Menu 3.
# =======================================================

# --- KONFIGURASI DAN WARNA ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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
VERSION="V5.1"

# --- FUNGSI UTAMA ---
# (Fungsi-fungsi ini tidak berubah)
clear_screen() { if ! command -v tput &> /dev/null; then pkg install ncurses-utils -y > /dev/null 2>&1; fi; tput clear; }
display_header() {
    clear_screen
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${CYAN}${BOLD}         🤖 MAWW SCRIPT $VERSION - REFACTORED BY GEMINI 🤖         ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
}
display_status() {
    echo -e "${PURPLE}╟─ STATUS PRASYARAT ───────────────────────────────────────╢${NC}"
    if command -v node &> /dev/null; then echo -e "${PURPLE}║${NC} ${GREEN}✓${NC} ${BOLD}Node.js${NC}: Terinstal"; else echo -e "${PURPLE}║${NC} ${RED}✗${NC} ${BOLD}Node.js${NC}: Belum terinstal"; fi
    if [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=.*" "$ENV_FILE"; then echo -e "${PURPLE}║${NC} ${GREEN}✓${NC} ${BOLD}Gemini API${NC}: Kunci API sudah diatur"; else echo -e "${PURPLE}║${NC} ${RED}✗${NC} ${BOLD}Gemini API${NC}: Kunci API belum diatur"; fi
    if [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ]; then echo -e "${PURPLE}║${NC} ${GREEN}✓${NC} ${BOLD}Sesi WA${NC}: Aktif"; else echo -e "${PURPLE}║${NC} ${RED}✗${NC} ${BOLD}Sesi WA${NC}: Tidak aktif"; fi
    echo -e "${PURPLE}╟────────────────────────────────────────────────────────────╢${NC}"
}
pause() { read -p "Tekan [Enter] untuk kembali ke menu..."; }

# --- FUNGSI MENU ---
# (Menu 1, 2, 4, 5 tidak berubah)
run_installation() {
    display_header; echo -e "\n${YELLOW}${BOLD}Memulai instalasi...${NC}\n"
    if ! command -v node &> /dev/null; then pkg install nodejs -y; fi
    node "$INSTALL_SCRIPT"; pause
}
setup_env_config() {
    display_header; echo -e "\n${CYAN}${BOLD}--- PENGATURAN KONFIGURASI (.env) ---${NC}\n"
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
    echo -e "\n${GREEN}✓ Konfigurasi disimpan di ${BOLD}$ENV_FILE${NC}."; pause
}

# ====================================================================
# PERUBAHAN DI SINI: FUNGSI OTENTIKASI DENGAN ALUR BARU
# ====================================================================
run_authentication() {
    display_header
    echo -e "\n${CYAN}${BOLD}--- OTENTIKASI WHATSAPP (ALUR BARU) ---${NC}\n"

    # --- Langkah 1: Masukkan/Konfirmasi Nomor HP ---
    echo -e "${YELLOW}Langkah 1: Konfigurasi Nomor Telepon${NC}"
    echo "----------------------------------------"
    
    # Cek apakah file .env dan nomor sudah ada
    CURRENT_PHONE=""
    if [ -f "$ENV_FILE" ]; then
        CURRENT_PHONE=$(grep 'PHONE_NUMBER' "$ENV_FILE" | cut -d'=' -f2)
    fi

    if [ -z "$CURRENT_PHONE" ]; then
        echo "Nomor HP belum diatur."
        read -p "Masukkan Nomor WA Anda (format 62...): " phone_number
    else
        read -p "Gunakan nomor yang tersimpan ($CURRENT_PHONE)? (y/n) [y]: " use_existing
        if [[ "${use_existing:-y}" == "n" ]]; then
            read -p "Masukkan Nomor WA baru (format 62...): " phone_number
        else
            phone_number=$CURRENT_PHONE
        fi
    fi
    
    # Simpan nomor ke .env agar bisa dibaca oleh auth.js
    if grep -q "PHONE_NUMBER=" "$ENV_FILE"; then
        sed -i "s/^PHONE_NUMBER=.*/PHONE_NUMBER=$phone_number/" "$ENV_FILE"
    else
        echo "PHONE_NUMBER=$phone_number" >> "$ENV_FILE"
    fi
    echo -e "${GREEN}✓ Nomor ($phone_number) telah disimpan.${NC}\n"

    # --- Langkah 2: Pilih Metode Login ---
    echo -e "${YELLOW}Langkah 2: Pilih Metode Login${NC}"
    echo "----------------------------------------"
    echo "1. Scan QR Code (Paling Stabil)"
    echo "2. Kode 8 Digit"
    read -p "Pilihan Anda [1]: " choice
    echo ""

    # --- Langkah 3: Munculkan Kode ---
    case ${choice:-1} in
        1) 
            echo "Login dengan QR Code..."
            node "$AUTH_SCRIPT" --method=qr 
            ;;
        2) 
            echo "Login dengan Kode 8 Digit..."
            node "$AUTH_SCRIPT" --method=code 
            ;;
        *) 
            echo -e "${RED}Pilihan tidak valid.${NC}" 
            ;;
    esac
    pause
}
# ====================================================================
# AKHIR DARI PERUBAHAN
# ====================================================================

run_bot() {
    display_header; echo -e "\n${GREEN}${BOLD}--- MENJALANKAN BOT ---${NC}\n"
    if ! command -v node &> /dev/null || [ ! -f "$ENV_FILE" ] || [ ! -d "$AUTH_DIR" ]; then echo -e "${RED}✗ Prasyarat belum terpenuhi!${NC}"; pause; return; fi
    echo "Bot sedang online... Tekan CTRL+C untuk berhenti."; node "$MAIN_SCRIPT"
    echo -e "\n${YELLOW}Bot telah berhenti.${NC}"; pause
}
reset_session() {
    display_header; echo -e "\n${YELLOW}${BOLD}--- RESET SESI WHATSAPP ---${NC}\n"
    if [ -d "$AUTH_DIR" ]; then read -p "Yakin ingin hapus sesi? (y/n): " confirm && [[ "$confirm" == "y" ]] && rm -rf "$AUTH_DIR" && echo -e "${GREEN}✓ Sesi dihapus.${NC}" || echo "Batal."; else echo "Tidak ada sesi untuk dihapus."; fi
    pause
}

# --- LOOP MENU UTAMA ---
while true; do
    display_header; display_status
    READY_TO_RUN=false
    if command -v node &> /dev/null && [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=.*" "$ENV_FILE" && [ -d "$AUTH_DIR" ]; then READY_TO_RUN=true; fi
    echo -e "${PURPLE}╟─ MENU UTAMA ─────────────────────────────────────────────╢${NC}"
    echo -e "${PURPLE}║${NC} 1. ${CYAN}Install / Update Dependencies${NC}"
    echo -e "${PURPLE}║${NC} 2. ${CYAN}Konfigurasi Lengkap (API, Model, No HP)${NC}"
    echo -e "${PURPLE}║${NC} 3. ${CYAN}${BOLD}Hubungkan WhatsApp (Alur Baru)${NC}"
    if $READY_TO_RUN; then echo -e "${PURPLE}║${NC} 4. ${GREEN}${BOLD}Jalankan Bot${NC}"; else echo -e "${PURPLE}║${NC} 4. ${RED}Jalankan Bot (Belum Siap)${NC}"; fi
    echo -e "${PURPLE}║${NC} 5. ${YELLOW}Reset Sesi WhatsApp${NC}"
    echo -e "${PURPLE}║${NC} 0. ${RED}Keluar${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
    read -p "Pilihan Anda: " choice
    case $choice in 1) run_installation;; 2) setup_env_config;; 3) run_authentication;; 4) run_bot;; 5) reset_session;; 0) exit 0;; *) pause;; esac
done