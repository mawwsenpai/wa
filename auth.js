// auth.js - VERSI STABIL DAN TANGGUH
require('dotenv').config();
const {
  makeWASocket,
  useMultiFileAuthState,
  fetchLatestBaileysVersion,
  DisconnectReason
} = require('@whiskeysockets/baileys');
const chalk = require('chalk');
const qrcode = require('qrcode-terminal');

const startAuth = async (method) => {
  // Timeout untuk seluruh proses otentikasi
  const authTimeout = setTimeout(() => {
    console.error(chalk.red.bold('\n❌ GAGAL: Proses otentikasi memakan waktu terlalu lama (60 detik).'));
    console.error(chalk.yellow('SOLUSI: Periksa koneksi internet Anda atau coba lagi nanti.'));
    process.exit(1);
  }, 60000); // 60 detik
  
  console.log(chalk.blue('Mempersiapkan status otentikasi...'));
  const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
  const { version } = await fetchLatestBaileysVersion();
  
  if (state.creds.registered) {
    console.log(chalk.green("✅ Sesi sudah aktif. Tidak perlu otentikasi ulang."));
    clearTimeout(authTimeout);
    return;
  }
  
  console.log(chalk.cyan(`[INFO] Memulai Baileys v${version.join('.')} dengan metode: ${method.toUpperCase()}`));
  const sock = makeWASocket({
    version,
    auth: state,
    browser: ['MawwScriptV5-Stable', 'Chrome', '120.0.0.0'],
    connectTimeoutMs: 30000, // Timeout koneksi internal 30 detik
    emitOwnEvents: false,
  });
  
  sock.ev.on('creds.update', saveCreds);
  
  sock.ev.on('connection.update', async (update) => {
    const { connection, lastDisconnect, qr } = update;
    
    if (qr) {
      console.log(chalk.yellow("\n================== SCAN QR DI SINI =================="));
      qrcode.generate(qr, { small: true });
      console.log(chalk.yellow("==================================================="));
      console.log(chalk.cyan("💡 Tips: Gunakan fitur scan dari galeri di dalam WhatsApp."));
    }
    
    switch (connection) {
      case 'connecting':
        console.log(chalk.yellow('⏳ Menghubungkan ke WhatsApp...'));
        break;
        
      case 'open':
        console.log(chalk.green.bold("\n✅ OTENTIKASI BERHASIL! Bot siap dijalankan."));
        clearTimeout(authTimeout); // Batalkan timeout karena sudah berhasil
        setTimeout(() => process.exit(0), 1000);
        break;
        
      case 'close':
        const reason = lastDisconnect?.error?.output?.statusCode;
        let errorMessage = `Koneksi ditutup.`;
        
        if (reason === DisconnectReason.badSession) {
          errorMessage = 'Sesi Buruk. Harap hapus folder auth_info_baileys dan coba lagi.';
        } else if (reason === DisconnectReason.connectionClosed) {
          errorMessage = 'Koneksi Ditutup. Periksa internet Anda.';
        } else if (reason === DisconnectReason.connectionLost) {
          errorMessage = 'Koneksi Hilang. Periksa internet Anda.';
        } else if (reason === DisconnectReason.connectionReplaced) {
          errorMessage = 'Koneksi Digantikan. Sesi lain dibuka di tempat lain.';
        } else if (reason === DisconnectReason.loggedOut) {
          errorMessage = 'Perangkat Ter-logout. Harap scan ulang.';
        } else if (reason === DisconnectReason.restartRequired) {
          errorMessage = 'Restart Diperlukan. Silakan jalankan ulang skrip.';
        } else if (reason === DisconnectReason.timedOut) {
          errorMessage = 'Koneksi Timeout. Periksa internet Anda.';
        } else {
          errorMessage = `Penyebab tidak diketahui: ${lastDisconnect?.error?.message}`;
        }
        
        console.error(chalk.red.bold(`\n❌ GAGAL: ${errorMessage}`));
        clearTimeout(authTimeout);
        process.exit(1);
    }
  });
  
  if (method === 'code' && !sock.authState.creds.registered) {
    const phoneNumber = process.env.PHONE_NUMBER;
    if (!phoneNumber) {
      console.error(chalk.red("❌ Nomor HP tidak ditemukan di .env!"));
      clearTimeout(authTimeout);
      process.exit(1);
    }
    try {
      await new Promise(resolve => setTimeout(resolve, 1500));
      console.log(chalk.yellow('Meminta kode pairing...'));
      const pairingCode = await sock.requestPairingCode(phoneNumber);
      console.log(chalk.green.bold(`\n✅ Kode Anda: ${pairingCode}\n`));
      console.log(chalk.cyan("Segera masukkan kode ini di WhatsApp Anda!"));
    } catch (e) {
      console.error(chalk.red(`\n❌ Gagal mendapatkan kode: ${e.message}`));
      console.error(chalk.yellow("SOLUSI: Coba lagi, atau gunakan metode QR Code yang lebih stabil."));
      clearTimeout(authTimeout);
      process.exit(1);
    }
  }
};

const method = process.argv.find(arg => arg.startsWith('--method='))?.split('=')[1];
if (method && ['qr', 'code'].includes(method)) {
  startAuth(method);
} else {
  console.log(chalk.red("Metode tidak valid."));
}