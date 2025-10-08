#!/bin/bash
# ===================================================================
# test.sh - V3.0 (Pamungkas) - Instalasi Ngrok & Server Otomatis
# ===================================================================

# --- Konfigurasi ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'
TICK="✅"; CROSS="❌"; WARN="⚠️"
SERVER_SCRIPT="server.js"
INSTALL_SCRIPT="install.js"

# --- Fungsi Header ---
display_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    figlet -c "Test Server"
    echo -e "${NC}"
}

# --- Mulai Skrip ---
display_header

# ===================================================================
# LANGKAH 1: INSTALASI NGROK OTOMATIS JIKA DIPERLUKAN
# ===================================================================
echo -e "${YELLOW}--- Langkah 1: Memeriksa & Menginstal Ngrok ---${NC}"

if [ -f "./ngrok" ]; then
    echo -e "${GREEN}${TICK} File 'ngrok' sudah ada. Melanjutkan...${NC}"
else
    echo -e "${WARN} File 'ngrok' tidak ditemukan. Memulai instalasi otomatis..."
    
    # Deteksi arsitektur prosesor
    ARCH=$(uname -m)
    echo " -> Mendeteksi arsitektur: $ARCH"

    # Tentukan URL download berdasarkan arsitektur
    if [[ "$ARCH" == "aarch64" ]]; then
      URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz"
    elif [[ "$ARCH" == "arm"* || "$ARCH" == "aarch32" ]]; then
      URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.tgz"
    else
      echo -e "${RED}${CROSS} Arsitektur $ARCH tidak didukung oleh skrip ini.${NC}"
      exit 1
    fi

    # Download file yang benar
    echo " -> Mengunduh Ngrok dari URL yang tepat..."
    curl -L "$URL" -o ngrok.tgz

    # Ekstrak file
    echo " -> Mengekstrak file..."
    tar -xvzf ngrok.tgz

    # Hapus file arsip
    rm ngrok.tgz

    # Verifikasi
    if [ -f "ngrok" ]; then
      echo -e "${GREEN}${TICK} Ngrok berhasil diinstal!${NC}"
    else
      echo -e "${RED}${CROSS} Gagal menginstal Ngrok. Coba jalankan skrip ini lagi.${NC}"
      exit 1
    fi
fi
echo ""

# ===================================================================
# LANGKAH 2: INSTALASI MODUL NODE.JS
# ===================================================================
echo -e "${YELLOW}--- Langkah 2: Menginstal Modul Node.js ---${NC}"
if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo -e "${RED}${CROSS} File installer (install.js) tidak ditemukan!${NC}"
    exit 1
fi
node "$INSTALL_SCRIPT"
if [ $? -ne 0 ]; then
    echo -e "\n${RED}${CROSS} Proses instalasi modul gagal. Harap periksa error di atas.${NC}"
    exit 1
fi
echo -e "${GREEN}${TICK} Instalasi modul selesai.${NC}"
echo ""

# ===================================================================
# LANGKAH 3: MENJALANKAN SERVER & BUKA BROWSER
# ===================================================================
echo -e "${YELLOW}--- Langkah 3: Menjalankan Server & Membuka Browser ---${NC}"
if [ ! -f "$SERVER_SCRIPT" ]; then
    echo -e "${RED}${CROSS} File server (server.js) tidak ditemukan!${NC}"
    exit 1
fi

echo -e "⏳ Memulai server di http://localhost:3000..."
node "$SERVER_SCRIPT" &
server_pid=$!
sleep 3

# Cek apakah server masih berjalan sebelum buka browser
if ! ps -p $server_pid > /dev/null; then
   echo -e "\n${RED}${CROSS} SERVER GAGAL DIMULAI!${NC}"
   echo -e "${YELLOW}Jalankan 'node server.js' secara manual untuk melihat pesan error.${NC}"
   exit 1
fi

echo -e "${GREEN}🚀 Membuka browser...${NC}"
termux-open-url http://localhost:3000

echo -e "\n-----------------------------------------------------"
read -p "Server berjalan di latar belakang. Tekan [Enter] untuk menghentikan."
echo -e "${YELLOW}🛑 Menghentikan server...${NC}"
kill $server_pid
echo -e "${GREEN}Server berhasil dihentikan.${NC}"
echo ""