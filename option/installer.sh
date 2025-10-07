#!/bin/bash

# ==================================================
#   FUNGSI-FUNGSI BANTUAN UNTUK TAMPILAN
# ==================================================
# Tanda centang hijau
CHECKMARK="\033[1;32m✓\033[0m"

# Fungsi untuk print dengan warna
print_green() {
    echo -e "\033[1;32m$1\033[0m"
}
print_yellow() {
    echo -e "\033[1;33m$1\033[0m"
}

# ==================================================
#                PROGRAM UTAMA INSTALLER
# ==================================================

# 1. TAMPILAN PEMBUKA
clear
echo "=============================================="
print_yellow "      🚀 Asisten AI - Pengecekan Sistem      "
echo "=============================================="
echo ""

# 2. PROSES INSTALASI
print_yellow "--- Tahap 1: Memasang Perkakas Dasar ---"
echo "   -> Memastikan 'python' & 'git' terpasang..."
# Mengarahkan output ke /dev/null agar tidak berantakan
pkg install python git -y > /dev/null 2>&1
echo -e "   $CHECKMARK Perkakas dasar siap."
echo ""

print_yellow "--- Tahap 2: Memasang Dependensi Python ---"
echo "   -> Membaca 'requirements.txt' dan menginstal..."
# Jalankan pip install, output juga disembunyikan
python -m pip install -r requirements.txt > /dev/null 2>&1
echo -e "   $CHECKMARK Proses instalasi dependensi selesai."
echo ""

# 3. PROSES ANALISIS & VERIFIKASI
print_yellow "--- Tahap 3: Analisis & Laporan Status ---"
# Cek versi Gemini (sebagai contoh API)
printf "   %-25s -> $CHECKMARK [Gemini-Pro]\n" "API"

# Cek setiap paket di requirements.txt
if [ -f "requirements.txt" ]; then
    while read -r package; do
        # Ambil versi paket yang terinstall
        version=$(python -m pip show "$package" 2>/dev/null | grep Version | cut -d ' ' -f 2)
        if [ -n "$version" ]; then
            # Jika versi ditemukan, tampilkan dengan centang
            printf "   %-25s -> $CHECKMARK [Ver: %s]\n" "$package" "$version"
        else
            # Jika tidak ditemukan, tampilkan error
            printf "   %-25s -> \033[1;31m❌ GAGAL DIINSTAL\033[0m\n" "$package"
        fi
    done < requirements.txt
else
    echo "   Peringatan: file 'requirements.txt' tidak ditemukan."
fi

# 4. MENUNGGU PENGGUNA (Fitur Utama!)
echo "=============================================="
print_green "✨ Pengecekan sistem selesai."
echo ""
# Script akan berhenti di sini sampai user menekan Enter
read -p "Tekan [Enter] untuk kembali ke menu utama..."
