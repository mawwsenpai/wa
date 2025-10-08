#!/bin/bash
# =======================================================
# setup.sh - Skrip Perbaikan & Instalasi Total
# =======================================================

# --- KONFIGURASI ---
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'; BOLD='\033[1m'
TICK="✅"; CROSS="❌"; WARN="⚠️"

# --- MULAI ---
clear
echo -e "${CYAN}${BOLD}"
figlet -c "Setup Script"
echo -e "${NC}"
echo -e "${YELLOW}Skrip ini akan melakukan pembersihan total dan instalasi bersih.\n${NC}"

# --- LANGKAH 1: PEMBERSIHAN PAKSA ---
echo -e "${YELLOW}--- Langkah 1: Pembersihan Paksa (Nuklir) ---${NC}"
echo "Ini akan menghapus semua modul lama untuk memastikan tidak ada file korup."
if [ -d "node_modules" ]; then
    echo "⏳ Menghapus folder node_modules..."
    rm -rf node_modules
    echo -e "${GREEN}${TICK} Selesai.${NC}"
fi
if [ -f "package-lock.json" ]; then
    echo "⏳ Menghapus file package-lock.json..."
    rm package-lock.json
    echo -e "${GREEN}${TICK} Selesai.${NC}"
fi
echo "Pembersihan total berhasil."
echo ""

# --- LANGKAH 2: INSTALASI BERSIH ---
echo -e "${YELLOW}--- Langkah 2: Menjalankan Instalasi Bersih ---${NC}"
if [ ! -f "install.js" ]; then
    echo -e "${RED}${CROSS} File 'install.js' tidak ditemukan! Gagal melanjutkan.${NC}"
    exit 1
fi
node "install.js"
if [ $? -ne 0 ]; then
    echo -e "\n${RED}${CROSS} Proses instalasi modul gagal. Harap periksa error di atas.${NC}"
    exit 1
fi
echo -e "${GREEN}${TICK} Instalasi modul selesai.${NC}"
echo ""

# --- LANGKAH 3: VERIFIKASI AKURAT ---
echo -e "${YELLOW}--- Langkah 3: Verifikasi Akurat Hasil Instalasi ---${NC}"
echo "Mengecek apakah library penting benar-benar bisa diakses..."
all_ok=true

# Tes verifikasi untuk @google/genai
node -e "try { require('@google/genai'); console.log('\x1b[32m✅ @google/genai : Ditemukan dan bisa diakses.\x1b[0m'); } catch (e) { console.error('\x1b[31m❌ @google/genai : GAGAL diakses!\x1b[0m'); process.exit(1); }"
if [ $? -ne 0 ]; then all_ok=false; fi

# Tes verifikasi untuk @whiskeysockets/baileys
node -e "try { require('@whiskeysockets/baileys'); console.log('\x1b[32m✅ @whiskeysockets/baileys : Ditemukan dan bisa diakses.\x1b[0m'); } catch (e) { console.error('\x1b[31m❌ @whiskeysockets/baileys : GAGAL diakses!\x1b[0m'); process.exit(1); }"
if [ $? -ne 0 ]; then all_ok=false; fi

echo ""
if $all_ok; then
    echo -e "${GREEN}${BOLD}ANALISIS FINAL: SEMUA KOMPONEN UTAMA BERHASIL DIINSTAL & DIVERIFIKASI!${NC}"
    echo "Anda sekarang bisa menjalankan ./main.sh dengan aman."
else
    echo -e "${RED}${BOLD}ANALISIS FINAL: GAGAL! Ada masalah kritis saat instalasi.${NC}"
    echo "Ini menandakan ada masalah yang lebih dalam dengan Termux atau NPM Anda."
fi