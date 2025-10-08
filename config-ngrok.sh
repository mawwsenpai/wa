#!/bin/bash
# =======================================================
# config-ngrok.sh - One-Time Installer & Configurator
# =======================================================

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'; BOLD='\033[1m'
TICK="✅"; WARN="⚠️"

clear
echo -e "${CYAN}${BOLD}"
figlet -c "Ngrok Setup"
echo -e "${NC}"

# 1. Check if Ngrok is already installed
if [ -f "./ngrok" ]; then
    echo -e "${GREEN}${TICK} File 'ngrok' sudah ada. Melewatkan instalasi...${NC}"
else
    echo -e "${WARN} File 'ngrok' tidak ditemukan. Memulai instalasi otomatis...${NC}"
    ARCH=$(uname -m)
    echo " -> Mendeteksi arsitektur: $ARCH"

    if [[ "$ARCH" == "aarch64" ]]; then
      URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz"
    else
      URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.tgz"
    fi

    echo " -> Mengunduh Ngrok..."
    curl -L "$URL" -o ngrok.tgz
    echo " -> Mengekstrak file..."
    tar -xvzf ngrok.tgz
    rm ngrok.tgz

    if [ -f "ngrok" ]; then
      echo -e "${GREEN}${TICK} Ngrok berhasil diinstal!${NC}"
    else
      echo -e "${RED}❌ Gagal menginstal Ngrok.${NC}"
      exit 1
    fi
fi

# 2. Prompt for Authtoken
echo ""
echo -e "${YELLOW}--- Konfigurasi Authtoken ---${NC}"
echo "Silakan buka dashboard Ngrok (https://dashboard.ngrok.com/get-started/your-authtoken) dan salin Authtoken Anda."
read -p "Masukkan Authtoken Anda di sini: " authtoken

if [ -z "$authtoken" ]; then
    echo -e "${RED}Authtoken tidak boleh kosong. Skrip berhenti.${NC}"
    exit 1
fi

# 3. Configure Ngrok
./ngrok config add-authtoken "$authtoken"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}${TICK} Konfigurasi Ngrok berhasil disimpan!${NC}"
    echo "Anda sekarang siap untuk menjalankan tunnel."
else
    echo -e "\n${RED}❌ Gagal menyimpan konfigurasi Ngrok.${NC}"
fi