#!/bin/bash

# =======================================================
# main.sh - Script Cepat Buat Jalanin Bot WA
# =======================================================

echo "🔥 STARTING BOT WA TERMUX 🔥"

# Cek apakah Node.js sudah terinstall
if ! command -v node &> /dev/null
then
    echo "❌ ERROR: Node.js belum terinstall. Install dulu: pkg install nodejs"
    exit 1
fi

# Cek apakah library sudah terinstall (cek folder node_modules)
if [ ! -d "node_modules" ]; then
    echo "📦 Dependency (library) belum diinstall. Install dulu..."
    npm install @whiskeysockets/baileys
    if [ $? -ne 0 ]; then
        echo "❌ ERROR: Gagal menginstall Baileys. Cek koneksi internetmu!"
        exit 1
    fi
fi

# Cek apakah file logika bot (index.js) ada
if [ ! -f "index.js" ]; then
    echo "❌ ERROR: File index.js (otak bot) tidak ditemukan!"
    echo "Buat dulu file index.js dan isi kodenya."
    exit 1
fi

echo "✅ Persiapan OK! Menjalankan Otak Bot (index.js)..."

# Jalankan file index.js menggunakan Node.js
# -r esm ini sering dipakai buat nge-support syntax terbaru
node index.js

# Kalo bot berhenti, tampilkan pesan
echo "================================================="
echo "BOT BERHENTI! Cek apakah ada error di atas."
echo "Jalankan lagi dengan: ./main.sh"
echo "================================================="
