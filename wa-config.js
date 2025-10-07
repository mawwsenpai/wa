// wa-config.js - Versi QR Code (Paling Stabil)

const {
  makeWASocket,
  useMultiFileAuthState,
  fetchLatestBaileysVersion,
  DisconnectReason
} = require('@whiskeysockets/baileys');

// Catatan: Nomor HP tidak digunakan di versi QR, tapi kita biarkan saja
const phoneNumber = process.env.PHONE_NUMBER;

async function startAuth() {
  console.log(`[AUTH] Memulai Proses Otentikasi WA (Metode QR Code)...`);
  
  const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
  const { version } = await fetchLatestBaileysVersion();
  
  // Check apakah sudah terdaftar
  if (state.creds.registered) {
    console.log("✅ WA Sudah terdaftar (Session Aktif). Hapus folder 'auth_info_baileys' untuk memulai ulang.");
    return;
  }
  
  const sock = makeWASocket({
    version,
    auth: state,
    // AKTIFKAN INI: QR Code akan muncul di terminal
    printQRInTerminal: true,
    browser: ['MawwScriptV5', 'Chrome', '110.0.0.0'],
  });
  
  // Event Listener buat menyimpan kredensial
  sock.ev.on('creds.update', saveCreds);
  
  // Event Listener buat status koneksi
  sock.ev.on('connection.update', (update) => {
    const { connection, lastDisconnect, qr } = update;
    
    if (qr) {
      console.log('\n======================================');
      console.log('🔥 QR CODE MUNCUL! SCAN SEKARANG JUGA.');
      console.log('======================================');
    }
    
    if (connection === 'open') {
      console.log('\n✅ OTENTIKASI SUKSES! Session tersimpan. Kamu bisa menjalankan Menu 5 sekarang.');
      process.exit(0); // Keluar dari script setelah sukses
    }
    
    if (connection === 'close') {
      const shouldReconnect = (lastDisconnect.error)?.output?.statusCode !== DisconnectReason.loggedOut;
      if (!shouldReconnect) {
        console.log(`\n❌ GAGAL OTENTIKASI: Session ditolak. Harap hapus folder 'auth_info_baileys' dan coba lagi.`);
      } else {
        // Di sini bisa ditambahkan logika coba lagi jika gagal
      }
      process.exit(1);
    }
  });
}

startAuth();