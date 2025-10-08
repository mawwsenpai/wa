#!/bin/bash
# =======================================================
# main.sh (V6.1) - Full Config Menu & Detailed Status
# =======================================================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'
TICK="✅"; CROSS="❌"; WARN="⚠️"
ENV_FILE=".env"; INSTALL_SCRIPT="install.js"; AUTH_SCRIPT="auth.js"; MAIN_SCRIPT="main.js"; AUTH_DIR="auth_info_baileys"; MODULES_DIR="node_modules"; VERSION="V6.1"

check_dependencies() {
    local missing_deps=()
    command -v node &>/dev/null || missing_deps+=("nodejs")
    command -v npm &>/dev/null || missing_deps+=("npm")
    command -v figlet &>/dev/null || missing_deps+=("figlet")
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}${WARN} Dependensi sistem hilang: ${missing_deps[*]}.${NC}"
        read -p "Instal sekarang? (y/n): " confirm
        if [[ "$confirm" == "y" ]]; then pkg update && pkg install -y "${missing_deps[@]}"; else echo -e "${RED}Skrip Batal.${NC}"; exit 1; fi
    fi
}
display_header() {
    clear
    echo -e "${CYAN}"
    figlet -c -f small "BOT-WHATSAPP"
    echo -e "${PURPLE}  MawwScript v6.1-Stabil${NC}"
    echo ""
}

# FUNGSI DIPERBARUI: Tampilan Status lebih detail
display_status() {
    echo -e "${PURPLE}╔═════════════════════════${NC}"
    echo -e "${PURPLE}║  S T A T U S${NC}"
    if command -v node &> /dev/null; then echo -e "${PURPLE}║ ${GREEN}${TICK} Node.js${NC} : Terinstal ($(node -v))"; else echo -e "${PURPLE}║ ${RED}${CROSS} Node.js${NC} : Belum terinstal"; fi
    if [ -d "$MODULES_DIR" ]; then echo -e "${PURPLE}║ ${GREEN}${TICK} Modules${NC}   : Siap digunakan"; else echo -e "${PURPLE}║ ${RED}${CROSS} Modules${NC}   : Belum diinstal (Menu 1)"; fi
    
    # Cek semua API Key
    if [ -f "$ENV_FILE" ]; then
        if grep -q "GEMINI_API_KEY=." "$ENV_FILE" && grep -q "UNSPLASH_API_KEY=." "$ENV_FILE" && grep -q "WEATHER_API_KEY=." "$ENV_FILE"; then
            echo -e "${PURPLE}║ ${GREEN}${TICK} API Keys${NC}  : Semua kunci API sudah diatur"
        else
            echo -e "${PURPLE}║ ${YELLOW}${WARN} API Keys${NC}  : Beberapa kunci API belum diatur (Menu 2)"
        fi
    else
        echo -e "${PURPLE}║ ${RED}${CROSS} Konfig${NC}    : File .env tidak ditemukan (Menu 1 & 2)"
    fi

    if [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ]; then echo -e "${PURPLE}║ ${GREEN}${TICK} Sesi WA${NC}   : Aktif"; else echo -e "${PURPLE}║ ${RED}${CROSS} Sesi WA${NC}   : Tidak aktif (Menu 3)"; fi
    echo -e "${PURPLE}╚═══════════${NC}"
}
pause() { echo ""; read -p "Tekan [Enter] untuk kembali ke menu..."; }

# FUNGSI DIPERBARUI: Menu Konfigurasi lengkap
setup_env_config() {
    display_header
    echo -e "\n${CYAN}${BOLD}--- Menu 2: Konfigurasi Bot Lengkap ---${NC}\n"
    touch "$ENV_FILE"
    
    # Baca semua nilai yang ada
    CURRENT_GEMINI=$(grep 'GEMINI_API_KEY' "$ENV_FILE" | cut -d'=' -f2)
    CURRENT_PHONE=$(grep 'PHONE_NUMBER' "$ENV_FILE" | cut -d'=' -f2)
    CURRENT_UNSPLASH=$(grep 'UNSPLASH_API_KEY' "$ENV_FILE" | cut -d'=' -f2)
    CURRENT_WEATHER=$(grep 'WEATHER_API_KEY' "$ENV_FILE" | cut -d'=' -f2)

    echo -e "Isi konfigurasi di bawah ini. Tekan [Enter] untuk memakai nilai lama jika ada."
    echo "------------------------------------------------------------------"
    read -p "Masukkan Gemini API Key [${CURRENT_GEMINI:0:5}...]: " gemini_key
    read -p "Masukkan Unsplash API Key (untuk .poto) [${CURRENT_UNSPLASH:0:5}...]: " unsplash_key
    read -p "Masukkan WeatherAPI.com Key (untuk .cuaca) [${CURRENT_WEATHER:0:5}...]: " weather_key
    read -p "Masukkan Nomor WA (62...) [${CURRENT_PHONE}]: " phone_number
    echo "Pilih Model Gemini (1=pro, 2=flash) [2]:"; read -p "Pilihan: " model_choice
    echo "------------------------------------------------------------------"

    # Gunakan nilai lama jika input kosong
    gemini_key=${gemini_key:-$CURRENT_GEMINI}
    unsplash_key=${unsplash_key:-$CURRENT_UNSPLASH}
    weather_key=${weather_key:-$CURRENT_WEATHER}
    phone_number=${phone_number:-$CURRENT_PHONE}
    case ${model_choice:-2} in 1) model="gemini-pro" ;; *) model="gemini-1.5-flash" ;; esac
    
    # Tulis ulang file .env dengan semua nilai
    {
        echo "GEMINI_API_KEY=$gemini_key"
        echo "GEMINI_MODEL=$model"
        echo "PHONE_NUMBER=$phone_number"
        echo ""
        echo "# --- Kunci API untuk Fitur Tambahan ---"
        echo "UNSPLASH_API_KEY=$unsplash_key"
        echo "WEATHER_API_KEY=$weather_key"
    } > "$ENV_FILE"

    echo -e "\n${GREEN}${TICK} Konfigurasi berhasil disimpan di ${BOLD}$ENV_FILE${NC}."
    pause
}
# Fungsi-fungsi lain tidak berubah
run_installation() { display_header; echo -e "\n${CYAN}${BOLD}--- Menu 1: Instalasi & Pembaruan ---${NC}\n"; node "$INSTALL_SCRIPT"; pause; }
run_authentication() { display_header; echo -e "\n${CYAN}${BOLD}--- Menu 3: Hubungkan WhatsApp ---${NC}\n"; if [ ! -d "$MODULES_DIR" ]; then echo -e "${RED}${CROSS} Jalankan instalasi (Menu 1) dulu.${NC}"; pause; return; fi; echo "1. Scan QR (Stabil)"; echo "2. Kode 8 Digit"; read -p "Pilihan [1]: " choice; case ${choice:-1} in 1) node "$AUTH_SCRIPT" --method=qr ;; 2) node "$AUTH_SCRIPT" --method=code ;; *) echo -e "${RED}Pilihan salah.${NC}" ;; esac; pause; }
run_bot() { display_header; echo -e "\n${GREEN}${BOLD}--- Menu 4: Jalankan Bot ---${NC}\n"; if ! [ -d "$MODULES_DIR" ] && [ -f "$ENV_FILE" ] && [ -d "$AUTH_DIR" ]; then echo -e "${RED}${CROSS} Semua status harus ${GREEN}✅${RED} dulu.${NC}"; pause; return; fi; echo "Bot online... Tekan CTRL+C untuk berhenti."; node "$MAIN_SCRIPT"; echo -e "\n${YELLOW}Bot berhenti.${NC}"; pause; }
reset_session() { display_header; echo -e "\n${YELLOW}${BOLD}--- Menu 5: Reset Sesi ---${NC}\n"; if [ -d "$AUTH_DIR" ]; then read -p "Yakin hapus sesi? (y/n): " confirm && [[ "$confirm" == "y" ]] && rm -rf "$AUTH_DIR" && echo -e "${GREEN}${TICK} Sesi dihapus.${NC}" || echo "Batal."; else echo "Tidak ada sesi untuk dihapus."; fi; pause; }

# --- LOOP MENU UTAMA ---
check_dependencies
while true; do
    display_header; display_status; READY_TO_RUN=false
    if [ -d "$MODULES_DIR" ] && [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=." "$ENV_FILE" && [ -d "$AUTH_DIR" ]; then READY_TO_RUN=true; fi
    echo -e "${PURPLE}╔═══════════════════════════════════════════${NC}"
    echo -e "${PURPLE}║ M E N U   U T A M A                       ${NC}"
    echo -e "${PURPLE}║  ${CYAN}1. Install / Update Modules${NC}                              "
    echo -e "${PURPLE}║  ${CYAN}2. Konfigurasi Bot (Semua API Key)${NC}                      "
    echo -e "${PURPLE}║  ${CYAN}3. Hubungkan Akun WhatsApp${NC}                               "
    if $READY_TO_RUN; then echo -e "${PURPLE}║  ${GREEN}${BOLD}4. Jalankan Bot${NC}                                          "; else echo -e "${PURPLE}║  ${RED}4. Jalankan Bot (Belum Siap)${NC}                              "; fi
    echo -e "${PURPLE}║  ${YELLOW}5. Reset Sesi WhatsApp${NC}                                   "
    echo -e "${PURPLE}║  ${RED}0. Keluar dari Skrip${NC}                                     "
    echo -e "${PURPLE}║                                                                 ${NC}"
    echo -e "${PURPLE}╚═══════════════════${NC}"
    read -p "Masukkan pilihan Anda: " choice
    case $choice in 1) run_installation;; 2) setup_env_config;; 3) run_authentication;; 4) run_bot;; 5) reset_session;; 0) echo -e "\n${CYAN}Sampai jumpa!${NC}"; exit 0;; *) echo -e "\n${RED}Pilihan salah!${NC}"; pause;; esac
done