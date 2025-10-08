#!/bin/bash
# =======================================================
# main.sh (V6.5 - Rombak Total UI & Gemini)
# =======================================================
# --- KONFIGURASI WARNA & SIMBOL ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'
TICK="✅"; CROSS="❌"; WARN="⚠️"
ENV_FILE=".env"; INSTALL_SCRIPT="install.js"; AUTH_SCRIPT="auth.js"; MAIN_SCRIPT="main.js"; AUTH_DIR="auth_info_baileys"; MODULES_DIR="node_modules"; VERSION="V6.5"

check_dependencies() {
    local missing_deps=(); command -v node &>/dev/null || missing_deps+=("nodejs"); command -v npm &>/dev/null || missing_deps+=("npm"); command -v figlet &>/dev/null || missing_deps+=("figlet")
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}${WARN} Dependensi sistem hilang: ${missing_deps[*]}.${NC}"; read -p "Instal sekarang? (y/n): " confirm
        if [[ "$confirm" == "y" ]]; then pkg update && pkg install -y "${missing_deps[@]}"; else echo -e "${RED}Skrip Batal.${NC}"; exit 1; fi
    fi
}
display_header() {
    clear; echo ""; echo -e "${WHITE}"; figlet -c -f smslant "Maww Script";
    local subtitle="» v6.5-Stabil by MawwSenpai_ «"; local terminal_width=$(tput cols); local subtitle_length=${#subtitle}; local padding=$(((terminal_width - subtitle_length) / 2))
    echo -e "${PURPLE}"; printf "%*s%s\n" "$padding" "" "$subtitle"; echo -e "${NC}"; echo ""
}

# --- FUNGSI TAMPILAN STATUS (UI BARU & RAPI) ---
display_status() {
    local status_format="║ ${GREEN}%-10s${PURPLE}: %s\n"
    local error_format="║ ${RED}%-10s${PURPLE}: %s\n"
    local warn_format="║ ${YELLOW}%-10s${PURPLE}: %s\n"

    echo -e "${PURPLE}╔══════════════════════ S T A T U S ══════════════════════╗${NC}"
    # Status Node.js
    if command -v node &> /dev/null; then
        printf "$status_format" "Node.js" "✅ Terinstal ($(node -v))"
    else
        printf "$error_format" "Node.js" "❌ Belum terinstal"
    fi
    # Status Modules
    if [ -d "$MODULES_DIR" ]; then
        printf "$status_format" "Modules" "✅ Siap digunakan"
    else
        printf "$error_format" "Modules" "❌ Belum diinstal (Menu 1)"
    fi
    # Status Konfigurasi
    if [ -f "$ENV_FILE" ]; then
        if grep -q "GEMINI_API_KEY=." "$ENV_FILE" && grep -q "UNSPLASH_API_KEY=." "$ENV_FILE" && grep -q "WEATHER_API_KEY=." "$ENV_FILE"; then
            printf "$status_format" "API Keys" "✅ Semua kunci diatur"
        else
            printf "$warn_format" "API Keys" "⚠️ Beberapa kunci kosong (Menu 2)"
        fi
    else
        printf "$error_format" "Konfig" "❌ .env tidak ditemukan (Menu 1 & 2)"
    fi
    # Status Sesi WA
    if [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ]; then
        printf "$status_format" "Sesi WA" "✅ Aktif"
    else
        printf "$error_format" "Sesi WA" "❌ Tidak aktif (Menu 3)"
    fi
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
}
pause() { echo ""; read -p "Tekan [Enter] untuk kembali ke menu..."; }

# --- FUNGSI KONFIGURASI (GEMINI LENGKAP) ---
setup_env_config() {
    display_header; echo -e "\n${CYAN}${BOLD}--- Menu 2: Konfigurasi Bot Lengkap ---${NC}\n"; touch "$ENV_FILE"
    CURRENT_GEMINI=$(grep 'GEMINI_API_KEY' "$ENV_FILE"|cut -d'=' -f2)
    CURRENT_PHONE=$(grep 'PHONE_NUMBER' "$ENV_FILE"|cut -d'=' -f2)
    CURRENT_UNSPLASH=$(grep 'UNSPLASH_API_KEY' "$ENV_FILE"|cut -d'=' -f2)
    CURRENT_WEATHER=$(grep 'WEATHER_API_KEY' "$ENV_FILE"|cut -d'=' -f2)
    echo "Isi konfigurasi, tekan [Enter] untuk memakai nilai lama."; echo "------------------------------------------------------------------"
    read -p "Gemini API Key [${CURRENT_GEMINI:0:5}...]: " gemini_key
    read -p "Unsplash API Key [${CURRENT_UNSPLASH:0:5}...]: " unsplash_key
    read -p "WeatherAPI.com Key [${CURRENT_WEATHER:0:5}...]: " weather_key
    read -p "Nomor WA (awalan 62) [${CURRENT_PHONE}]: " phone_number
    echo ""; echo -e "${BOLD}Pilih Model Gemini:${NC}"; echo "  1. Gemini 1.0 Pro (Standar & Stabil)"; echo "  2. Gemini 1.5 Flash (Cepat & Direkomendasikan)"; echo "  3. Gemini 1.5 Pro (Terbaru & Paling Canggih)"
    read -p "Pilihan Model [2]: " model_choice
    echo "------------------------------------------------------------------"
    gemini_key=${gemini_key:-$CURRENT_GEMINI}; unsplash_key=${unsplash_key:-$CURRENT_UNSPLASH}; weather_key=${weather_key:-$CURRENT_WEATHER}; phone_number=${phone_number:-$CURRENT_PHONE}
    case ${model_choice:-2} in 1) model="gemini-pro" ;; 3) model="gemini-1.5-pro" ;; *) model="gemini-1.5-flash" ;; esac
    { echo "GEMINI_API_KEY=$gemini_key"; echo "GEMINI_MODEL=$model"; echo "PHONE_NUMBER=$phone_number"; echo ""; echo "# --- Kunci API untuk Fitur Tambahan ---"; echo "UNSPLASH_API_KEY=$unsplash_key"; echo "WEATHER_API_KEY=$weather_key"; } > "$ENV_FILE"
    echo -e "\n${GREEN}${TICK} Konfigurasi berhasil disimpan dengan model: ${BOLD}$model${NC}"; pause
}

run_installation() { display_header; echo -e "\n${CYAN}${BOLD}--- Menu 1: Instalasi & Pembaruan ---${NC}\n"; node "$INSTALL_SCRIPT"; pause; }
run_authentication() { display_header; echo -e "\n${CYAN}${BOLD}--- Menu 3: Hubungkan WhatsApp ---${NC}\n"; if [ ! -d "$MODULES_DIR" ]; then echo -e "${RED}${CROSS} Jalankan instalasi (Menu 1) dulu.${NC}"; pause; return; fi; echo "1. Scan QR (Stabil)"; echo "2. Kode 8 Digit"; read -p "Pilihan [1]: " choice; case ${choice:-1} in 1) node "$AUTH_SCRIPT" --method=qr ;; 2) node "$AUTH_SCRIPT" --method=code ;; *) echo -e "${RED}Pilihan salah.${NC}" ;; esac; pause; }
run_bot() { display_header; echo -e "\n${GREEN}${BOLD}--- Menu 4: Jalankan Bot ---${NC}\n"; if ! [ -d "$MODULES_DIR" ] || ! [ -f "$ENV_FILE" ] || ! [ -d "$AUTH_DIR" ]; then echo -e "${RED}${CROSS} Semua status harus ${GREEN}✅${RED} dulu.${NC}"; pause; return; fi; echo "Bot online... Tekan CTRL+C untuk berhenti."; node "$MAIN_SCRIPT"; echo -e "\n${YELLOW}Bot berhenti.${NC}"; pause; }
reset_session() { display_header; echo -e "\n${YELLOW}${BOLD}--- Menu 5: Reset Sesi ---${NC}\n"; if [ -d "$AUTH_DIR" ]; then read -p "Yakin hapus sesi? (y/n): " confirm && [[ "$confirm" == "y" ]] && rm -rf "$AUTH_DIR" && echo -e "${GREEN}${TICK} Sesi dihapus.${NC}" || echo "Batal."; else echo "Tidak ada sesi untuk dihapus."; fi; pause; }

# --- LOOP MENU UTAMA (UI BARU & RAPI) ---
check_dependencies
while true; do
    display_header; display_status; READY_TO_RUN=false
    if [ -d "$MODULES_DIR" ] && [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=." "$ENV_FILE" && [ -d "$AUTH_DIR" ]; then READY_TO_RUN=true; fi
    
    # Format untuk menu: ║ [spasi] [ikon warna] [teks] [padding] ║
    menu_format="║  %b%-56s${PURPLE}║${NC}\n"
    
    echo -e "${PURPLE}╔══════════════════════ M E N U   U T A M A ═════════════════════╗${NC}"
    printf "$menu_format" "${CYAN}1. " "Install / Update Modules"
    printf "$menu_format" "${CYAN}2. " "Konfigurasi Bot (Semua API Key)"
    printf "$menu_format" "${CYAN}3. " "Hubungkan Akun WhatsApp"
    if $READY_TO_RUN; then
        printf "$menu_format" "${GREEN}${BOLD}4. " "Jalankan Bot WhatsApp${NC}"
    else
        printf "$menu_format" "${RED}4. " "Jalankan Bot WhatsApp (Belum Siap)"
    fi
    printf "$menu_format" "${YELLOW}5. " "Reset Sesi WhatsApp"
    printf "$menu_format" "${RED}0. " "Keluar dari Skrip"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    read -p "Masukkan pilihan Anda: " choice
    case $choice in 1) run_installation;; 2) setup_env_config;; 3) run_authentication;; 4) run_bot;; 5) reset_session;; 0) echo -e "\n${CYAN}Sampai jumpa!${NC}"; exit 0;; *) echo -e "\n${RED}Pilihan salah!${NC}"; pause;; esac
done