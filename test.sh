#!/bin/bash
# =======================================================
# test.sh - Skrip Uji Coba Lokal (Menggunakan Master Installer)
# =======================================================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'
SERVER_SCRIPT="server.js"
INSTALL_SCRIPT="install.js" # <-- Diubah ke install.js

check_dependencies() {
    local missing_deps=(); command -v node &>/dev/null || missing_deps+=("nodejs"); command -v termux-open-url &>/dev/null || missing_deps+=("termux-api")
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}Dependensi sistem hilang: ${missing_deps[*]}.${NC}"; read -p "Instal? (y/n): " confirm
        if [[ "$confirm" == "y" ]]; then pkg update && pkg install -y "${missing_deps[@]}"; else echo -e "${RED}Batal.${NC}"; exit 1; fi
    fi
}

check_dependencies
clear
echo -e "\n${CYAN}${BOLD}--- Mempersiapkan Lingkungan Uji Coba Lokal ---${NC}\n"

if [ -f "$INSTALL_SCRIPT" ]; then
    node "$INSTALL_SCRIPT"
else
    echo -e "${RED}File ${INSTALL_SCRIPT} tidak ditemukan!${NC}"
    exit 1
fi

if [ ! -f "$SERVER_SCRIPT" ]; then
    echo -e "${RED}File ${SERVER_SCRIPT} tidak ditemukan!${NC}"
    exit 1
fi

echo -e "\n${YELLOW}⏳ Memulai server di http://localhost:3000...${NC}"
node "$SERVER_SCRIPT" &
server_pid=$!
sleep 3

echo -e "${GREEN}🚀 Membuka browser...${NC}"
termux-open-url http://localhost:3000

echo -e "\n-----------------------------------------------------"
read -p "Server berjalan di latar belakang. Tekan [Enter] untuk menghentikan."
echo -e "${YELLOW}🛑 Menghentikan server...${NC}"
kill $server_pid
echo -e "${GREEN}Server berhasil dihentikan.${NC}"
echo ""