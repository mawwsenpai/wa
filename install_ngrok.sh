# Hapus file lama yang mungkin rusak
rm ngrok.tgz ngrok 2>/dev/null

# Deteksi arsitektur prosesor
ARCH=$(uname -m)
echo "Mendeteksi arsitektur: $ARCH"

# Tentukan URL download berdasarkan arsitektur
if [[ "$ARCH" == "aarch64" ]]; then
  URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz"
elif [[ "$ARCH" == "arm"* || "$ARCH" == "aarch32" ]]; then
  URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.tgz"
else
  echo "Arsitektur $ARCH tidak didukung."
  exit 1
fi

# Download file yang benar
echo "Mengunduh Ngrok dari URL yang tepat..."
curl -L "$URL" -o ngrok.tgz

# Ekstrak file
echo "Mengekstrak file..."
tar -xvzf ngrok.tgz

# Verifikasi
if [ -f "ngrok" ]; then
  echo "✅ Ngrok berhasil diunduh dan diekstrak!"
  echo "Anda bisa melanjutkan ke langkah berikutnya."
else
  echo "❌ Gagal mengekstrak Ngrok. File unduhan mungkin masih rusak."
fi