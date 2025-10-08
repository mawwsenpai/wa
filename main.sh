#!/bin/bash
# =======================================================
# main.sh (V8.0 - All-in-One dengan Instalasi Bersih)
# =======================================================
# --- KONFIGURASI WARNA & SIMBOL ---
YELLOW='\033[0;33m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'; NC='\033[0m'; BOLD='\033[1m'
SUCCESS_ICON="✓"; WARN_ICON="⚠️"

# --- NAMA FILE & VERSI ---
ENV_FILE=".env"; INSTALL_SCRIPT="install.js"; AUTH_SCRIPT="auth.js"; MAIN_SCRIPT="main.js"; GEMINI_SCRIPT="gemini.js"
AUTH_DIR="auth_info_baileys"; MODULES_DIR="node_modules"; VERSION="V8.0 - Stabil - By MawwSenpai_"

# --- FUNGSI PRASYARAT ---
check_dependencies() { local missing_deps=(); command -v node &>/dev/null || missing_deps+=("nodejs"); command -v npm &>/dev/null || missing_deps+=("npm"); command -v figlet &>/dev/null || missing_deps+=("figlet"); if [ ${#missing_deps[@]} -ne 0 ]; then echo -e "${YELLOW}${WARN_ICON} Dependensi sistem hilang: ${missing_deps[*]}.${NC}"; read -p "Instal? (y/n): " confirm; if [[ "$confirm" == "y" ]]; then pkg update && pkg install -y "${missing_deps[@]}"; else echo -e "${YELLOW}Skrip Batal.${NC}"; exit 1; fi; fi; }

# --- FUNGSI TAMPILAN (UI MINIMALIS) ---
display_header() { clear; echo ""; echo -e "${WHITE}"; figlet -c -f slant "Wa-Script"; local subtitle="$VERSION"; local terminal_width=$(tput cols); local subtitle_length=${#subtitle}; local padding=$(((terminal_width-subtitle_length)/2)); echo -e "${PURPLE}"; printf "%*s%s\n" "$padding" "" "$subtitle"; echo -e "${NC}"; }
display_status() {
    echo ""; echo -e "${WHITE}--- S T A T U S ---${NC}"
    local format_ok="  ${CYAN}${SUCCESS_ICON} %-12s${NC}: %s\n"; local format_warn="  ${YELLOW}${WARN_ICON} %-12s${NC}: %s\n"
    if command -v node &>/dev/null; then printf "$format_ok" "Node.js" "Terinstal ($(node -v))"; else printf "$format_warn" "Node.js" "Belum terinstal"; fi
    if [ -d "$MODULES_DIR" ]; then printf "$format_ok" "Modules" "Siap digunakan"; else printf "$format_warn" "Modules" "Belum diinstal (Menu 1)"; fi
    if [ -f "$ENV_FILE" ]; then
        if grep -q "GEMINI_API_KEY=." "$ENV_FILE"; then printf "$format_ok" "API Keys" "Kunci utama diatur"; else printf "$format_warn" "API Keys" "Kunci utama kosong (Menu 2)"; fi
    else printf "$format_warn" "Konfigurasi" "File .env tidak ditemukan"; fi
    if [ -d "$AUTH_DIR" ] && [ -f "$AUTH_DIR/creds.json" ]; then printf "$format_ok" "Sesi WA" "Aktif"; else printf "$format_warn" "Sesi WA" "Tidak aktif (Menu 3)"; fi
}
pause() { echo ""; read -p "Tekan [Enter] untuk kembali..."; }

# --- FUNGSI-FUNGSI UTAMA ---

# FUNGSI BARU: Instalasi Bersih & Verifikasi
run_clean_installation() {
    display_header
    echo -e "\n${CYAN}--- Menu 1: Instalasi Bersih (Perbaikan Total) ---\n${NC}"
    echo -e "${YELLOW}Langkah 1: Pembersihan Paksa (Nuklir)...${NC}"
    if [ -d "node_modules" ]; then rm -rf node_modules; echo "  ${CYAN}${SUCCESS_ICON} Folder node_modules dihapus.${NC}"; fi
    if [ -f "package-lock.json" ]; then rm package-lock.json; echo "  ${CYAN}${SUCCESS_ICON} File package-lock.json dihapus.${NC}"; fi
    echo ""
    echo -e "${YELLOW}Langkah 2: Menjalankan Instalasi Bersih...${NC}"
    node "$INSTALL_SCRIPT"
    if [ $? -ne 0 ]; then echo -e "\n${YELLOW}${WARN_ICON} Instalasi modul gagal.${NC}"; pause; return; fi
    echo ""
    echo -e "${YELLOW}Langkah 3: Verifikasi Akurat Hasil Instalasi...${NC}"
    all_ok=true
    node -e "try { require('@google/genai'); console.log('\x1b[36m✓ @google/genai\x1b[0m : Ditemukan dan bisa diakses.'); } catch (e) { console.error('\x1b[33m⚠️ @google/genai\x1b[0m : GAGAL diakses!'); process.exit(1); }"
    if [ $? -ne 0 ]; then all_ok=false; fi
    node -e "try { require('@whiskeysockets/baileys'); console.log('\x1b[36m✓ @whiskeysockets/baileys\x1b[0m : Ditemukan dan bisa diakses.'); } catch (e) { console.error('\x1b[33m⚠️ @whiskeysockets/baileys\x1b[0m : GAGAL diakses!'); process.exit(1); }"
    if [ $? -ne 0 ]; then all_ok=false; fi
    echo ""
    if $all_ok; then echo -e "${CYAN}${BOLD}ANALISIS FINAL: SEMUA KOMPONEN UTAMA BERHASIL DIINSTAL & DIVERIFIKASI!${NC}"; else echo -e "${YELLOW}${BOLD}ANALISIS FINAL: GAGAL! Ada masalah saat instalasi.${NC}"; fi
    pause
}

setup_env_config() {
    display_header; echo -e "\n${CYAN}--- Menu 2: Konfigurasi Bot & Model AI ---\n${NC}"; touch "$ENV_FILE"
    CURRENT_GEMINI=$(grep 'GEMINI_API_KEY' "$ENV_FILE"|cut -d'=' -f2); CURRENT_PHONE=$(grep 'PHONE_NUMBER' "$ENV_FILE"|cut -d'=' -f2); CURRENT_UNSPLASH=$(grep 'UNSPLASH_API_KEY' "$ENV_FILE"|cut -d'=' -f2); CURRENT_WEATHER=$(grep 'WEATHER_API_KEY' "$ENV_FILE"|cut -d'=' -f2)
    echo -e "${WHITE}Isi konfigurasi, tekan [Enter] untuk memakai nilai lama.${NC}"
    read -p "Gemini API Key [${CURRENT_GEMINI:0:5}...]: " gemini_key; read -p "Unsplash API Key [${CURRENT_UNSPLASH:0:5}...]: " unsplash_key; read -p "WeatherAPI.com Key [${CURRENT_WEATHER:0:5}...]: " weather_key; read -p "Nomor WA (awalan 62) [${CURRENT_PHONE}]: " phone_number
    echo ""; echo -e "${BOLD}${WHITE}Pilih Model Gemini:${NC}"; echo "  1. Gemini 1.5 Flash (Cepat, Rekomendasi)"; echo "  2. Gemini 1.5 Pro (Paling Canggih)"; echo "  3. Gemini 1.0 Pro (Klasik, Stabil)"
    read -p "Pilihan Model [1]: " model_choice
    gemini_key=${gemini_key:-$CURRENT_GEMINI}; unsplash_key=${unsplash_key:-$CURRENT_UNSPLASH}; weather_key=${weather_key:-$CURRENT_WEATHER}; phone_number=${phone_number:-$CURRENT_PHONE}
    case ${model_choice:-1} in 2) model="gemini-1.5-pro-latest" ;; 3) model="gemini-1.0-pro" ;; *) model="gemini-1.5-flash-latest" ;; esac
    { echo "GEMINI_API_KEY=$gemini_key"; echo "GEMINI_MODEL=$model"; echo "PHONE_NUMBER=$phone_number"; echo ""; echo "# Kunci API Fitur Tambahan"; echo "UNSPLASH_API_KEY=$unsplash_key"; echo "WEATHER_API_KEY=$weather_key"; } > "$ENV_FILE"
    echo -e "\n${CYAN}${SUCCESS_ICON} Konfigurasi disimpan dengan model: ${BOLD}$model${NC}"; pause
}
run_authentication() { display_header; echo -e "\n${CYAN}--- Menu 3: Hubungkan WhatsApp ---\n${NC}"; if [ ! -d "$MODULES_DIR" ]; then echo -e "${YELLOW}Jalankan instalasi (Menu 1) dulu.${NC}"; pause; return; fi; echo "1. Scan QR (Stabil)"; echo "2. Kode 8 Digit"; read -p "Pilihan [1]: " choice; case ${choice:-1} in 1) node "$AUTH_SCRIPT" --method=qr ;; 2) node "$AUTH_SCRIPT" --method=code ;; *) echo -e "${YELLOW}Pilihan salah.${NC}";; esac; pause; }
run_bot() { display_header; echo -e "\n${CYAN}--- Menu 4: Jalankan Bot ---\n${NC}"; if ! [ -d "$MODULES_DIR" ] || ! [ -f "$ENV_FILE" ] || ! [ -d "$AUTH_DIR" ]; then echo -e "${YELLOW}Semua status harus ${CYAN}✓${YELLOW} dulu.${NC}"; pause; return; fi; echo "Bot online... Tekan CTRL+C untuk berhenti."; node "$MAIN_SCRIPT"; echo -e "\n${YELLOW}Bot berhenti.${NC}"; pause; }
reset_session() { display_header; echo -e "\n${YELLOW}--- Menu 5: Reset Sesi ---\n${NC}"; if [ -d "$AUTH_DIR" ]; then read -p "Yakin hapus sesi? (y/n): " confirm && [[ "$confirm" == "y" ]] && rm -rf "$AUTH_DIR" && echo -e "${CYAN}Sesi dihapus.${NC}" || echo "Batal."; else echo "Tidak ada sesi untuk dihapus."; fi; pause; }
run_gemini_status_check() { display_header; echo -e "\n${CYAN}--- Menu 6: Cek Status API Gemini ---\n${NC}"; if [ ! -f "$GEMINI_SCRIPT" ]; then echo -e "${YELLOW}${WARN_ICON} File ${GEMINI_SCRIPT} tidak ditemukan!${NC}"; pause; return; fi; node "$GEMINI_SCRIPT"; pause; }

# --- LOOP MENU UTAMA ---
check_dependencies
while true; do
    display_header; display_status; echo ""; echo -e "${WHITE}--- M E N U ---${NC}"
    printf "  ${PURPLE}[%s]${NC} %s\n" "1" "Instalasi Bersih (Perbaikan Total)"
    printf "  ${PURPLE}[%s]${NC} %s\n" "2" "Konfigurasi Bot & Model AI"
    printf "  ${PURPLE}[%s]${NC} %s\n" "3" "Hubungkan Akun WhatsApp"
    READY_TO_RUN=false; if [ -d "$MODULES_DIR" ] && [ -f "$ENV_FILE" ] && grep -q "GEMINI_API_KEY=." "$ENV_FILE" && [ -d "$AUTH_DIR" ]; then READY_TO_RUN=true; fi
    if $READY_TO_RUN; then printf "  ${PURPLE}[%s]${NC} %b%s${NC}\n" "4" "${CYAN}${BOLD}" "Jalankan Bot WhatsApp"; else printf "  ${PURPLE}[%s]${NC} %b%s${NC}\n" "4" "${YELLOW}" "Jalankan Bot WhatsApp (Belum Siap)"; fi
    printf "  ${PURPLE}[%s]${NC} %s\n" "5" "Reset Sesi WhatsApp"
    printf "  ${PURPLE}[%s]${NC} %s\n" "6" "Cek Status API Gemini"
    printf "  ${PURPLE}[%s]${NC} %s\n" "0" "Keluar"; echo ""
    read -p "Pilihan Anda: " choice
    case $choice in 1) run_clean_installation;; 2) setup_env_config;; 3) run_authentication;; 4) run_bot;; 5) reset_session;; 6) run_gemini_status_check;; 0) echo -e "\n${CYAN}Sampai jumpa!${NC}"; exit 0;; *) echo -e "\n${YELLOW}Pilihan salah!${NC}"; pause;; esac
done