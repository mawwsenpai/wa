#!/bin/bash

# =======================================================
# install-path.sh - Script Instalasi Bot WA Otomatis
# =======================================================

# Warna buat tampilan elegan
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# File Log
LOG_FILE="install_log_$(date +%Y%m%d_%H%M%S).txt"
exec &> >(tee "$LOG_FILE") # Redirect semua output ke terminal DAN ke file log

echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}    BOT WA SETUP - STARTING ANALISIS SISTEM    ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo -e "Waktu mulai instalasi: $(date)"
echo -e "Output instalasi disimpan ke: ${YELLOW}$LOG_FILE${NC}"
echo " "

# --- BAGIAN 1: INSTALASI PRASYARAT (NODE.JS) ---
echo -e "${BLUE}>> 1. MEMERIKSA DAN MENGINSTAL NODE.JS...${NC}"

if command -v node &> /dev/null
then
    echo -e "${GREEN}   ✅ Node.js sudah terinstal.${NC} (Versi: $(node -v))"
else
    echo -e "${YELLOW}   ⏳ Node.js belum terinstal. Memulai instalasi...${NC}"
    pkg update && pkg upgrade -y
    pkg install nodejs -y
    if [ $? -ne 0 ]; then
        echo -e "${RED}   ❌ GAGAL! Instalasi Node.js gagal. Cek koneksi internet!${NC}"
        exit 1
    fi
    echo -e "${GREEN}   ✅ Node.js berhasil diinstal.${NC}"
fi

# --- BAGIAN 2: SETUP FILE PROYEK ---
echo " "
echo -e "${BLUE}>> 2. MENYIAPKAN FILE DAN FOLDER PROYEK...${NC}"

# Membuat file manifest (package.json)
echo -e "${YELLOW}   ⏳ Membuat package.json...${NC}"
npm init -y > /dev/null
echo -e "${GREEN}   ✅ package.json berhasil dibuat.${NC}"

# Membuat file starter (main.sh)
echo -e "${YELLOW}   ⏳ Membuat main.sh (Starter Script)...${NC}"
touch main.sh
chmod +x main.sh
echo -e "${GREEN}   ✅ main.sh berhasil dibuat dan diberi izin eksekusi.${NC}"

# Membuat file logika (index.js)
echo -e "${YELLOW}   ⏳ Membuat index.js (Otak Bot)...${NC}"
touch index.js
echo -e "${GREEN}   ✅ index.js siap diisi kode.${NC}"

# --- BAGIAN 3: MENGUNDUH DAN INSTALASI LIBRARY ---
echo " "
echo -e "${BLUE}>> 3. MENGUNDUH DAN MENGINSTAL LIBRARY (BAILEYS)...${NC}"

echo -e "${YELLOW}   ⏳ Memulai instalasi library @whiskeysockets/baileys...${NC}"
npm install @whiskeysockets/baileys
if [ $? -ne 0 ]; then
    echo -e "${RED}   ❌ GAGAL! Instalasi Baileys gagal. Cek koneksi internet!${NC}"
    exit 1
fi
echo -e "${GREEN}   ✅ Semua library berhasil diinstal di node_modules/.${NC}"


# --- BAGIAN 4: FINAL CHECK DAN INFORMASI ---
echo " "
echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}    SETUP BOT WA SELESAI! SEMUA FILE DIBUTUHKAN SIAP    ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo " "
echo -e "DETAIL FILE & FOLDER YANG TERSEDIA (Total 5):"
echo -e "-------------------------------------------------"
echo -e "${GREEN}1. index.js       ${NC}: (File) Tempat kode bot kamu (otak)."
echo -e "${GREEN}2. main.sh        ${NC}: (File) Script buat menjalankan bot."
echo -e "${GREEN}3. package.json   ${NC}: (File) Manifest proyek."
echo -e "${GREEN}4. node_modules/  ${NC}: (Folder) Gudang semua library."
echo -e "${GREEN}5. auth_info_baileys/: (Folder) Akan muncul setelah kamu login pertama kali."
echo -e "-------------------------------------------------"
echo -e "${YELLOW}LANGKAH BERIKUTNYA (Wajib):${NC}"
echo -e "1. ${YELLOW}ISI KODE:${NC} Copy-paste kode index.js (mode Kode 8 Digit) dari Gemini."
echo -e "2. ${YELLOW}ISI KODE:${NC} Isi kode main.sh (Starter Script) dari Gemini."
echo -e "3. ${YELLOW}JALANKAN:${NC} Ketik ${GREEN}./main.sh${NC} untuk memulai dan mendapatkan Kode 8 Digit."
echo -e " "
echo -e "Waktu selesai instalasi: $(date)"
echo -e "${BLUE}=================================================${NC}"
