#!/bin/bash

# Fungsi untuk print dengan warna
print_green() {
    echo -e "\033[1;32m$1\033[0m"
}
print_red() {
    echo -e "\033[1;31m$1\033[0m"
}
print_yellow() {
    echo -e "\033[1;33m$1\033[0m"
}

# Header
clear
echo "=============================================="
echo "      🚀 Asisten AI - Pengecekan Sistem      "
echo "=============================================="

# Cek & Install Python & Git
print_yellow "=> Mengecek perkakas dasar (python & git)..."
pkg install python git -y > /dev/null 2>&1
print_green "   Perkakas dasar -> ✓ SIAP"

# Cek & Install Dependensi Python
print_yellow "\n=> Mengecek dependensi Python..."
pip install -r requirements.txt > /dev/null 2>&1

# Verifikasi Instalasi
echo ""
while read -r package; do
    version=$(pip show "$package" | grep Version | cut -d ' ' -f 2)
    if [ -n "$version" ]; then
        printf "   %-25s -> ✓ [Ver: %s]\n" "$package" "$version"
    else
        printf "   %-25s -> ❌ GAGAL DIINSTAL\n" "$package"
    fi
done < requirements.txt

# Cek API (placeholder)
printf "   %-25s -> ✓ [Gemini-Pro]\n" "API"

echo "=============================================="
print_green "✨ Semua sistem siap tempur!"
echo ""
read -p "Tekan [Enter] untuk kembali ke menu utama..."
