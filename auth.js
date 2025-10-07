// auth.js - VERSI PERBAIKAN
require('dotenv').config();
const {
  makeWASocket,
  useMultiFileAuthState,
  fetchLatestBaileysVersion,
  DisconnectReason
} = require('@whiskeysockets/baileys');
const chalk = require('chalk');
const qrcode = require('qrcode-terminal'); // Library baru untuk QR

const startAuth = async (method) => {
  const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
  const { version } = await fetchLatestBaileysVersion();
  
  if (state.creds.registered) {
    console.log(chalk.green("✅ Sesi sudah aktif. Tidak perlu otentikasi ulang."));
    return;
  }
  
  console.log(chalk.cyan(`[INFO] Memulai otentikasi dengan metode: ${method.toUpperCase()}`));
  
  const sock = makeWASocket({
    version,
    auth: state,
    // Opsi 'printQRInTerminal' dihapus karena sudah usang dan tidak stabil
    browser: ['MawwScriptV5', 'Chrome', '110.0.0.0'],
  });
  
  sock.ev.on('creds.update', saveCreds);
  
  // --- LOGIKA UTAMA UNTUK KONEKSI ---
  sock.ev.on('connection.update', async (update) => {
    const { connection, lastDisconnect, qr } = update;
    
    // Jika QR code muncul
    if (qr) {
      console.log(chalk.yellow("\n================================================="));
      console.log("Silakan scan QR Code di bawah ini:");
      // Menggambar QR code menggunakan library baru yang lebih andal
      qrcode.generate(qr, { small: true
      console.log(chalk.yellow("================================================="));
      console.log(chalk.cyan("💡 Tips: Cubit layar (zoom out) jika QR code tidak pas."));
    }
    
    // Jika koneksi terbuka (berhasil)
    if (connection === 'open') {
      console.log(chalk.green.bold("\n✅ Otentikasi Berhasil! Bot siap dijalankan dari Menu 4."));
      setTimeout(() => process.exit(0), 2000);
    }
    
    // Jika koneksi ditutup
    if (connection === 'close') {
      const reason = lastDisconnect?.error?.output?.statusCode;
      let message = "Koneksi terputus.";
      
      if (reason === DisconnectReason.loggedOut) {
        message = "Perangkat ter-logout. Sesi akan dihapus.";
      } else if (reason === DisconnectReason.restartRequired) {
        message = "Restart diperlukan, silakan jalankan ulang skrip.";
      }
      
      console.log(chalk.red(`\n❌ ${message} Harap coba lagi.`));
      // Keluar dari proses jika koneksi gagal
      process.exit(1);
    }
  });
  
  // --- LOGIKA KHUSUS UNTUK KODE 8 DIGIT ---
  if (method === 'code' && !sock.authState.creds.registered) {
    const phoneNumber = process.env.PHONE_NUMBER;
    if (!phoneNumber) {
      console.error(chalk.red("❌ Nomor HP tidak ditemukan di .env! Isi dari Menu 2."));
      process.exit(1);
    }
    try {
      // Tunda sebentar untuk memastikan socket siap
      await new Promise(resolve => setTimeout(resolve, 1500));
      const pairingCode = await sock.requestPairingCode(phoneNumber);
      console.log(chalk.yellow("\n================================================="));
      console.log(chalk.bold.yellow(` KODE OTENTIKASI ANDA: ${pairingCode}`));
      console.log(chalk.yellow("================================================="));
      console.log(chalk.cyan("Buka WhatsApp di HP Anda:\n1. Klik titik tiga (⋮) > Perangkat tertaut\n2. Klik 'Tautkan perangkat'\n3. Pilih 'Tautkan dengan nomor telepon'\n4. Masukkan kode di atas."));
    } catch (e) {
      console.error(chalk.red(`\n❌ Gagal mendapatkan kode: ${e.message}`));
      console.error(chalk.yellow("SOLUSI: Coba lagi, atau gunakan metode QR Code yang lebih stabil."));
      process.exit(1);
    }
  }
};

// --- LOGIKA UNTUK MENJALANKAN DARI TERMINAL ---
const method = process.argv.find(arg => arg.startsWith('--method='))?.split('=')[1];
if (method && ['qr', 'code'].includes(method)) {
  startAuth(method);
} else {
  console.log(chalk.red("Metode tidak valid. Gunakan --method=qr atau --method=code"));
}