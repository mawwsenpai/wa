# Script Bot-Whatsapp
<div align="center">
  <pre>v6.1-Stabil by MawwSenpai_</pre>
  <h3></h3>
</div>

---

Selamat datang di **Maww Script**, sebuah skrip bot WhatsApp multifungsi yang dirancang untuk berjalan di lingkungan Termux. Dibangun dengan Node.js dan library Baileys, serta diintegrasikan dengan Google Gemini untuk kemampuan AI, bot ini siap menjadi asisten pribadi Anda.

## ✨ Fitur Unggulan

* **🤖 Obrolan AI Cerdas:** Terintegrasi dengan Google Gemini untuk menjawab pertanyaan dan mengobrol secara natural.
* **✨ Sistem Perintah & Registrasi:** Dilengkapi sistem registrasi pengguna dan penanganan perintah yang terstruktur.
* **🖼️ Pencarian Gambar HD:** Cari dan kirim gambar berkualitas tinggi langsung dari Unsplash dengan perintah `.poto`.
* **🌤️ Informasi Cuaca:** Dapatkan informasi cuaca terkini dari seluruh dunia dengan perintah `.cuaca`.
* **🎵 Fitur YouTube:** Cari video dengan `.ytsearch` dan unduh audionya dengan `.ytaudio`.
* **🎨 Pembuat Stiker:** Ubah gambar menjadi stiker WhatsApp dengan mudah menggunakan perintah `.sticker`.
* **🌐 Dukungan Proxy:** Pengguna terdaftar dapat mengatur proxy pribadi untuk anonimitas.
* **💄 UI Terminal Aestetik:** Dikelola melalui script `main.sh` dengan tampilan yang bersih dan jelas.

## 📋 Prasyarat

* HP Android dengan aplikasi **Termux**.
* Koneksi internet yang stabil.
* Akun WhatsApp (Biasa atau Business).
* Sedikit kesabaran untuk proses setup awal. 😊

## 🚀 Panduan Instalasi

Ikuti langkah-langkah ini dengan teliti di dalam Termux.

1.  **Siapkan Folder Proyek:**
    Buat folder baru untuk bot dan letakkan semua file skrip (`main.sh`, `install.js`, `auth.js`, `script.js`, `gemini.js`) di dalamnya.

2.  **Install Dependensi Sistem:**
    Jalankan perintah ini untuk memastikan Termux Anda memiliki semua yang dibutuhkan.
    ```bash
    pkg update && pkg upgrade
    pkg install nodejs git figlet
    ```

3.  **Beri Izin Eksekusi:**
    Jadikan skrip utama dapat dieksekusi.
    ```bash
    chmod +x main.sh
    ```

4.  **Jalankan Skrip Utama:**
    Mulai skrip untuk pertama kalinya.
    ```bash
    ./main.sh
    ```

5.  **Install Modul Node.js:**
    Setelah skrip berjalan, pilih **Menu 1 (Install / Update Modules)** dari menu utama. Ini akan mengunduh semua library Node.js yang dibutuhkan oleh bot.

## ⚙️ Konfigurasi

Setelah instalasi selesai, Anda perlu mengatur kunci API agar semua fitur dapat berjalan.

1.  Jalankan **Menu 2 (Konfigurasi Bot)** dari `main.sh`.
2.  Skrip akan meminta Anda untuk memasukkan informasi berikut, yang akan disimpan di file `.env`.

| Variabel | Fungsi | Tempat Mendapatkan |
| :--- | :--- | :--- |
| `GEMINI_API_KEY` | Untuk fitur obrolan AI | [Google AI Studio](https://makersuite.google.com/app/apikey) |
| `UNSPLASH_API_KEY`| Untuk fitur `.poto` | [Unsplash Developers](https://unsplash.com/developers) |
| `WEATHER_API_KEY` | Untuk fitur `.cuaca` | [WeatherAPI.com](https://www.weatherapi.com/) |
| `PHONE_NUMBER` | Nomor WA untuk otentikasi | Nomor Anda sendiri (format `62...`) |

## 🕹️ Cara Menggunakan

1.  **Hubungkan WhatsApp:** Jalankan **Menu 3** untuk menautkan akun WhatsApp Anda menggunakan metode Scan QR (disarankan) atau Kode 8 Digit.
2.  **Jalankan Bot:** Setelah semua status di menu utama berwarna hijau (✅), pilih **Menu 4 (Jalankan Bot)**.
3.  **Gunakan Perintah:** Buka WhatsApp dan kirim pesan ke nomor bot Anda dari nomor lain.

### Daftar Perintah

* `.menu` - Memulai proses registrasi pengguna.
* `.poto <kata kunci>` - Mencari dan mengirim gambar.
    * *Contoh: `.poto aurora borealis`*
* `.cuaca <nama kota>` - Menampilkan info cuaca.
    * *Contoh: `.cuaca Tokyo`*
* `.ytsearch <kata kunci>` - Mencari 5 video teratas di YouTube.
    * *Contoh: `.ytsearch tutorial termux`*
* `.ytaudio <URL YouTube>` - Mengunduh dan mengirim audio dari link YouTube.
* `.sticker` - Balas (reply) sebuah gambar dengan perintah ini untuk membuatnya menjadi stiker.
* *Obrolan biasa* - Semua chat yang tidak diawali dengan `.` akan dijawab oleh AI (Gemini).

## ⚠️ Peringatan

* Proyek ini menggunakan API tidak resmi dari WhatsApp (Baileys). Ada risiko (meskipun kecil untuk penggunaan pribadi) bahwa nomor Anda bisa diblokir sementara atau permanen oleh WhatsApp.
* Gunakan dengan bijak dan jangan melakukan spam. Pengembang tidak bertanggung jawab atas penyalahgunaan skrip ini.

## 💖 Kredit

Proyek ini tidak akan mungkin terwujud tanpa kerja keras dari para pengembang library open-source berikut:
* [Baileys](https://github.com/WhiskeySockets/Baileys)
* [Google Gemini](https://ai.google.dev/)
* Dan semua library pendukung lainnya yang digunakan dalam proyek ini.