#!/bin-bash
# =======================================================
# start-tunnel.sh - Starts the server and Ngrok tunnel
# =======================================================

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'; BOLD='\033[1m'

# Check if ngrok executable exists
if [ ! -f "./ngrok" ]; then
    echo -e "${RED}❌ File 'ngrok' tidak ditemukan.${NC}"
    echo -e "${YELLOW}Harap jalankan './config-ngrok.sh' terlebih dahulu.${NC}"
    exit 1
fi

# Start the Node.js server in the background
echo -e "${CYAN}--- Memulai Server & Tunnel ---${NC}"
echo -e "⏳ Memulai Node.js server di latar belakang..."
node server.js &
SERVER_PID=$!
sleep 2

# Check if the server started successfully
if ! ps -p $SERVER_PID > /dev/null; then
   echo -e "\n${RED}❌ SERVER GAGAL DIMULAI!${NC}"
   echo -e "${YELLOW}Jalankan 'node server.js' secara manual untuk melihat pesan error.${NC}"
   exit 1
fi
echo -e "${GREEN}✅ Node.js server berjalan (PID: $SERVER_PID).${NC}"

# Start the ngrok tunnel in the foreground
echo -e "🚇 Memulai Ngrok tunnel untuk port 3000..."
./ngrok http 3000

# After ngrok is closed (with Ctrl+C), kill the server
echo -e "\n${YELLOW}🛑 Ngrok berhenti. Menghentikan Node.js server...${NC}"
kill $SERVER_PID
echo -e "${GREEN}Server berhasil dihentikan.${NC}"