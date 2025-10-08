#!/bin/bash
# =======================================================
# main.sh (V7.2 - Menambahkan Model Eksperimental Gemini)
# =======================================================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'
TICK="✅"; CROSS="❌"; WARN="⚠️"
ENV_FILE=".env"; INSTALL_SCRIPT="install.js"; AUTH_SCRIPT="auth.js"; MAIN_SCRIPT="main.js"; GEMINI_SCRIPT="gemini.js"; AUTH_DIR="auth_info_baileys"; MODULES_DIR="node_modules"; VERSION="V7.2"

check_dependencies() { local missing_deps=(); command -v node &>/dev/null || missing_deps+=("nodejs"); command -v npm &>/dev/null || missing_deps+=("npm"); command -v figlet &>/dev/null || missing_deps+=("figlet"); if [ ${#missing_deps[@]} -ne 0 ]; then echo -e "${YELLOW}${WARN} Dependensi hilang: ${missing_deps[*]}.${NC}"; read -p "Instal? (y/n): " confirm; if [[ "$confirm" == "y" ]]; then pkg update && pkg install -y "${missing_deps[@]}"; else echo -e "${RED}Batal.${NC}"; exit 1; fi; fi; }
display_header() { clear; echo ""; echo -e "${WHITE}"; figlet -c -f smslant "Maww Script"; local subtitle="» v7.2-Stabil by MawwSenpai_ «"; local terminal_width=$(tput cols); local subtitle_length=${#subtitle}; local padding=$(((terminal_width-subtitle_length)/2)); echo -e "${PURPLE}"; printf "%*s%s\n" "$padding" "" "$subtitle"; echo -e "${NC}"; echo ""; }
display_status() {
    echo -e "${PURPLE}╔══════════════════════ S T A T U S ══════════════════════╗${NC}"
    if command -v node &> /dev/null; then printf "║ ${GREEN}%-10s${PURPLE}: %s\n" "Node.js" "✅ Terinstal ($(node -v))"; else printf "║ ${RED}%-10s${PURPLE}: %s\n" "Node.js" "❌ Belum terinstal"; fi
    if [ -d "$MODULES_DIR" ]; then printf "║ ${GREEN}%-10s${PURPLE}: %s\n" "Modules" "✅ Siap digunakan"; else printf "║ ${RED}%-10s${PURPLE}: %s\n" "Modules" "❌ Belum diinstal (Menu 1)"; fi
    if [ -f "$ENV_FILE" ]; then
        local current_model=$(grep 'GEMINI_MODEL' "$ENV_FILE" | cut -d'=' -f2); printf "║ ${GREEN}%-10s${PURPLE}: %s\n" "Model AI" "🤖 ${current_model:-Belum diatur}"
        if grep -q "GEMINI_API_KEY=." "$ENV_FILE"; then printf "║ ${GREEN}%-10s${PURPLE}: %s\n" "API Keys" "✅ Kunci API utama diatur"; else printf "║ ${YELLOW}%-10s${PURPLE}: %s\n" "API Keys" "⚠️ Kunci API utama kosong (Menu 2)"; fi
    else printf "║ ${RED}%-10s${PURPLE}: %s\n" "Konfig" "❌ .env tidak ditemukan (Menu 1 & 2)"; fi
    if [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ]; then printf "║ ${GREEN}%-10s${PURPLE}: %s\n" "Sesi WA" "✅ Aktif"; else printf "║ ${RED}%-10s${PURPLE}: %s\n" "Sesi WA" "❌ Tidak aktif (Menu 3)"; fi
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
}
pause() { echo ""; read -p "Tekan [Enter] untuk kembali ke menu..."; }

# --- FUNGSI KONFIGURASI DENGAN MODEL BARU ---
setup_env_config() {
    display_header; echo -e "\n${CYAN}${BOLD}--- Menu 2: Konfigurasi Bot Lengkap ---${NC}\n"; touch "$ENV_FILE"
    CURRENT_GEMINI=$(grep 'GEMINI_API_KEY' "$ENV_FILE"|cut -d'=' -f2); CURRENT_PHONE=$(grep 'PHONE_NUMBER' "$ENV_FILE"|cut -d'=' -f2); CURRENT_UNSPLASH=$(grep 'UNSPLASH_API_KEY' "$ENV_FILE"|cut -d'=' -f2); CURRENT_WEATHER=$(grep 'WEATHER_API_KEY' "$ENV_FILE"|cut -d'=' -f2)
    echo "Isi konfigurasi, tekan [Enter] untuk memakai nilai lama."; echo "------------------------------------------------------------------"
    read -p "Gemini API Key [${CURRENT_GEMINI:0:5}...]: " gemini_key
    read -p "Unsplash API Key [${CURRENT_UNSPLASH:0:5}...]: " unsplash_key
    read -p "WeatherAPI.com Key [${CURRENT_WEATHER:0:5}...]: " weather_key
    read -p "Nomor WA (awalan 62) [${CURRENT_PHONE}]: " phone_number
    
    echo ""; echo -e "${BOLD}Pilih Model Gemini (untuk ganti jika ada gangguan):${NC}"
    echo "  --- Model Stabil ---"
    echo "  1. Gemini 1.5 Flash (Cepat, Rekomendasi)"
    echo "  2. Gemini 1.5 Pro (Canggih, Kreatif)"
    echo "  3. Gemini 1.0 Pro (Lama, Stabil)"
    echo "  --- Model Eksperimental ---"
    echo -e "  ${YELLOW}4. Gemini 2.5 Flash (Sesuai Info Anda)${NC}"
    echo -e "  ${YELLOW}5. Gemini 2.5 Pro (Sesuai Info Anda)${NC}"
    read -p "Pilihan Model [1]: " model_choice
    echo "------------------------------------------------------------------"
    
    gemini_key=${gemini_key:-$CURRENT_GEMINI}; unsplash_key=${unsplash_key:-$CURRENT_UNSPLASH}; weather_key=${weather_key:-$CURRENT_WEATHER}; phone_number=${phone_number:-$CURRENT_PHONE}
    
    # Menambahkan case untuk model baru
    case ${model_choice:-1} in
        2) model="gemini-1.5-pro" ;;
        3) model="gemini-pro" ;;
        4) model="gemini-2.5-flash" ;; # Nama asumsi
        5) model="gemini-2.5-pro" ;;   # Nama asumsi
        *) model="gemini-1.5-flash" ;;
    esac
    
    { echo "GEMINI_API_KEY=$gemini_key"; echo "GEMINI_MODEL=$model"; echo "PHONE_NUMBER=$phone_number"; echo ""; echo "# --- Kunci API ---"; echo "UNSPLASH_API_KEY=$unsplash_key"; echo "WEATHER_API_KEY=$weather_key"; } > "$ENV_FILE"
    echo -e "\n${GREEN}${TICK} Konfigurasi berhasil disimpan dengan model: ${BOLD}$model${NC}"; pause
}

run_gemini_status_check() { display_header; if [ ! -f "$GEMINI_SCRIPT" ]; then echo -e "${RED}${CROSS} File ${GEMINI_SCRIPT} tidak ditemukan!${NC}"; else node "$GEMINI_SCRIPT"; fi; pause; }
run_installation() { display_header; echo -e "\n${CYAN}${BOLD}--- Menu 1: Instalasi & Pembaruan ---${NC}\n"; node "$INSTALL_SCRIPT"; pause; }
run_authentication() { display_header; echo -e "\n${CYAN}${BOLD}--- Menu 3: Hubungkan WhatsApp ---${NC}\n"; if [ ! -d "$MODULES_DIR" ]; then echo -e "${RED}Jalankan instalasi (Menu 1) dulu.${NC}"; pause; return; fi; echo "1. Scan QR (Stabil)"; echo "2. Kode 8 Digit"; read -p "Pilihan [1]: " choice; case ${choice:-1} in 1) node "$AUTH_SCRIPT" --method=qr ;; 2) node "$AUTH_SCRIPT" --method=code ;; *) echo -e "${RED}Pilihan salah.${NC}";; esac; pause; }
run_bot() { display_header; echo -e "\n${GREEN}${BOLD}--- Menu 4: Jalankan Bot ---${NC}\n"; if ! [ -d "$MODULES_DIR" ] || ! [ -f "$ENV_FILE" ] || ! [ -d "$AUTH_DIR" ]; then echo -e "${RED}Semua status harus ✅ dulu.${NC}"; pause; return; fi; echo "Bot online... Tekan CTRL+C untuk berhenti."; node "$MAIN_SCRIPT"; echo -e "\n${YELLOW}Bot berhenti.${NC}"; pause; }
reset_session() { display_header; echo -e "\n${YELLOW}${BOLD}--- Menu 5: Reset Sesi ---${NC}\n"; if [ -d "$AUTH_DIR" ]; then read -p "Yakin hapus sesi? (y/n): " confirm && [[ "$confirm" == "y" ]] && rm -rf "$AUTH_DIR" && echo -e "${GREEN}Sesi dihapus.${NC}" || echo "Batal."; else echo "Tidak ada sesi untuk dihapus."; fi; pause; }

check_dependencies
while true; do
    display_header; display_status; READY_TO_RUN=false
    if [ -d "$MODULES_DIR" ] && [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=." "$ENV_FILE" && [ -d "$AUTH_DIR" ]; then READY_TO_RUN=true; fi
    menu_format="║  %b%-56s${PURPLE}║${NC}\n"
    echo -e "${PURPLE}╔══════════════════════ M E N U   U T A M A ═════════════════════╗${NC}"
    printf "$menu_format" "${CYAN}1. " "Install / Update Modules"; printf "$menu_format" "${CYAN}2. " "Konfigurasi Bot & Model AI"; printf "$menu_format" "${CYAN}3. " "Hubungkan Akun WhatsApp"
    if $READY_TO_RUN; then printf "$menu_format" "${GREEN}${BOLD}4. " "Jalankan Bot WhatsApp${NC}"; else printf "$menu_format" "${RED}4. " "Jalankan Bot WhatsApp (Belum Siap)"; fi
    printf "$menu_format" "${YELLOW}5. " "Reset Sesi WhatsApp"; printf "$menu_format" "${CYAN}6. " "Cek Status API Gemini"; printf "$menu_format" "${RED}0. " "Keluar dari Skrip"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    read -p "Masukkan pilihan Anda: " choice
    case $choice in 1)run_installation;;2)setup_env_config;;3)run_authentication;;4)run_bot;;5)reset_session;;6)run_gemini_status_check;;0)echo -e "\n${CYAN}Sampai jumpa!${NC}";exit 0;;*)echo -e "\n${RED}Pilihan salah!${NC}";pause;;esac
done