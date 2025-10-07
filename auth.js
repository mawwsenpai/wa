// auth.js
require('dotenv').config();
const { makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion, DisconnectReason } = require('@whiskeysockets/baileys');
const chalk = require('chalk');

const startAuth = async (method) => {
  const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
  const { version } = await fetchLatestBaileysVersion();
  
  if (state.creds.registered) {
    console.log(chalk.green("✅ Sesi sudah aktif. Tidak perlu otentikasi ulang."));
    return;
  }
  
  const sock = makeWASocket({
    version,
    auth: state,
    printQRInTerminal: method === 'qr',
    browser: ['MawwScriptV5', 'Chrome', '110.0.0.0'],
  });
  
  sock.ev.on('creds.update', saveCreds);
  
  if (method === 'code' && !sock.authState.creds.registered) {
    const phoneNumber = process.env.PHONE_NUMBER;
    if (!phoneNumber) {
      console.error(chalk.red("❌ Nomor HP tidak ditemukan di .env! Isi dari Menu 2."));
      process.exit(1);
    }
    try {
      const pairingCode = await sock.requestPairingCode(phoneNumber);
      console.log(chalk.yellow.bold(`\n KODE OTENTIKASI ANDA: ${pairingCode}\n`));
      console.log(chalk.cyan("Buka WA di HP > Perangkat Tertaut > Tautkan dengan nomor telepon."));
    } catch (e) {
      console.error(chalk.red(`\n❌ Gagal mendapatkan kode: ${e.message}`));
      process.exit(1);
    }
  }
  
  sock.ev.on('connection.update', (update) => {
    const { connection, lastDisconnect, qr } = update;
    if (qr && method === 'qr') console.log(chalk.cyan("\nSilakan scan QR Code ini..."));
    if (connection === 'open') {
      console.log(chalk.green.bold("\n✅ Otentikasi Berhasil! Bot siap dijalankan dari Menu 4."));
      setTimeout(() => process.exit(0), 2000);
    }
    if (connection === 'close') {
      const reason = lastDisconnect?.error?.output?.statusCode;
      const message = reason === DisconnectReason.loggedOut ? "Perangkat ter-logout." : "Koneksi terputus.";
      console.log(chalk.red(`\n❌ ${message} Harap hapus folder 'auth_info_baileys' dan otentikasi ulang.`));
      process.exit(1);
    }
  });
};

const method = process.argv.find(arg => arg.startsWith('--method='))?.split('=')[1];
if (method) {
  startAuth(method);
} else {
  console.log(chalk.red("Tentukan metode: --method=qr atau --method=code"));
}