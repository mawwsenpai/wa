#!/bin/bash

# =======================================================
# test.sh - Skrip Uji Coba Lokal (Membuka Browser Otomatis)
# =======================================================

# --- KONFIGURASI WARNA & NAMA FILE ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'
TICK="✅"
CROSS="❌"
WARN="⚠️"

SERVER_SCRIPT="server.js"

# --- FUNGSI ---

# Cek dependensi sistem sebelum memulai
check_dependencies() {
    local missing_deps=()
    command -v node &>/dev/null || missing_deps+=("nodejs")
    command -v termux-open-url &>/dev/null || missing_deps+=("termux-api")

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}${WARN} Dependensi sistem hilang: ${missing_deps[*]}.${NC}"
        read -p "Instal sekarang? (y/n): " confirm
        if [[ "$confirm" == "y" ]]; then
            pkg update && pkg install -y "${missing_deps[@]}"
        else
            echo -e "${RED}Skrip tidak dapat dilanjutkan tanpa dependensi tersebut.${NC}"
            exit 1
        fi
    fi
}

# --- LOGIKA UTAMA SKRIP ---

# Jalankan pengecekan dependensi dulu
check_dependencies

clear
echo -e "\n${CYAN}${BOLD}--- Menjalankan Server Uji Coba Lokal ---${NC}\n"

if [ ! -f "$SERVER_SCRIPT" ]; then
    echo -e "${RED}${CROSS} File server.js tidak ditemukan!${NC}"
    exit 1
fi

# Menjalankan server Node.js di latar belakang
echo -e "${YELLOW}⏳ Memulai server di http://localhost:3000...${NC}"
node "$SERVER_SCRIPT" &
# Simpan PID dari proses yang baru saja dijalankan
server_pid=$!

# Beri waktu 3 detik agar server siap
sleep 3

# Buka URL di browser secara otomatis
echo -e "${GREEN}🚀 Membuka browser... Silakan cek tab baru di Chrome.${NC}"
termux-open-url http://localhost:3000

echo -e "\n-----------------------------------------------------"
read -p "Server sedang berjalan di latar belakang. Tekan [Enter] untuk menghentikan server."

# Hentikan proses server saat pengguna menekan Enter
echo -e "${YELLOW}🛑 Menghentikan server...${NC}"
kill $server_pid
echo -e "${GREEN}Server berhasil dihentikan.${NC}"
echo ""