#!/bin/bash
# =======================================================
# test.sh - V2.0 - UI Rombak Total dengan Analisis
# =======================================================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'
TICK="✅"; CROSS="❌"; WARN="⚠️"
SERVER_SCRIPT="server.js"
INSTALL_SCRIPT="install.js"

clear
echo -e "${CYAN}${BOLD}"
figlet -c "Test Server"
echo -e "${NC}"

# --- LANGKAH 1: ANALISIS & INSTALASI ---
echo -e "${YELLOW}--- Langkah 1: Analisis & Instalasi Dependensi ---${NC}"
if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo -e "${RED}${CROSS} File installer (install.js) tidak ditemukan!${NC}"
    exit 1
fi
node "$INSTALL_SCRIPT"
# Cek status exit dari proses instalasi
if [ $? -ne 0 ]; then
    echo -e "\n${RED}${CROSS} Proses instalasi gagal. Harap periksa error di atas.${NC}"
    exit 1
fi
echo -e "${GREEN}${TICK} Instalasi dependensi selesai.${NC}"
echo ""

# --- LANGKAH 2: UJI COBA MENJALANKAN SERVER ---
echo -e "${YELLOW}--- Langkah 2: Uji Coba Menjalankan Server ---${NC}"
if [ ! -f "$SERVER_SCRIPT" ]; then
    echo -e "${RED}${CROSS} File server (server.js) tidak ditemukan!${NC}"
    exit 1
fi
echo -e "⏳ Mencoba menjalankan 'node server.js'..."
# Jalankan di foreground untuk menangkap error
node "$SERVER_SCRIPT" > /dev/null 2>&1 &
SERVER_PID=$!
sleep 2 # Beri waktu untuk crash jika ada

# Cek apakah prosesnya masih berjalan
if ps -p $SERVER_PID > /dev/null; then
   echo -e "${GREEN}${TICK} Server berhasil berjalan tanpa error awal.${NC}"
   kill $SERVER_PID # Matikan lagi untuk dijalankan di langkah berikutnya
else
   echo -e "\n${RED}${CROSS} SERVER GAGAL DIMULAI!${NC}"
   echo -e "${YELLOW}Menampilkan pesan error dari 'node server.js':${NC}"
   echo "-----------------------------------------------------"
   # Jalankan lagi di foreground untuk menampilkan error kepada user
   node "$SERVER_SCRIPT"
   echo "-----------------------------------------------------"
   echo -e "${RED}Server gagal. Skrip berhenti.${NC}"
   exit 1
fi
echo ""

# --- LANGKAH 3: JALANKAN FINAL & BUKA BROWSER ---
echo -e "${YELLOW}--- Langkah 3: Menjalankan Server & Membuka Browser ---${NC}"
echo -e "⏳ Memulai server di http://localhost:3000..."
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