// wa-config.js - Versi Kode 8 Digit (Rentan Error 428)

const {
  makeWASocket,
  useMultiFileAuthState,
  fetchLatestBaileysVersion,
  DisconnectReason
} = require('@whiskeysockets/baileys');

const phoneNumber = process.env.PHONE_NUMBER;

async function startAuth() {
  console.log(`[AUTH] Memulai Proses Otentikasi WA (Metode Kode 8 Digit)...`);
  
  const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
  const { version } = await fetchLatestBaileysVersion();
  
  if (state.creds.registered) {
    console.log("✅ WA Sudah terdaftar (Session Aktif). Hapus folder 'auth_info_baileys' untuk memulai ulang.");
    return;
  }
  
  if (!phoneNumber) {
    console.error("❌ ERROR: Nomor HP belum disetel di Menu 2 main.sh!");
    process.exit(1);
  }
  
  const sock = makeWASocket({
    version,
    auth: state,
    printQRInTerminal: false,
    browser: ['MawwScriptV5', 'Chrome', '110.0.0.0'],
  });
  
  sock.ev.on('creds.update', saveCreds);
  
  try {
    const pairingCode = await sock.requestPairingCode(phoneNumber);
    
    console.log(`\n======================================`);
    console.log(`🔥 KODE OTENTIKASI (8 DIGIT) KAMU: ${pairingCode}`);
    console.log(`MASUKKAN KODE INI SEGERA DI HP KAMU (Tautkan dengan Nomor Telepon).`);
    console.log(`======================================\n`);
    
    sock.ev.on('connection.update', (update) => {
      if (update.connection === 'open') {
        console.log('✅ OTENTIKASI SUKSES! Session tersimpan. Kamu bisa menjalankan Menu 5 sekarang.');
        process.exit(0);
      }
      if (update.connection === 'close' && update.lastDisconnect) {
        const reason = update.lastDisconnect.error?.output?.statusCode;
        if (reason === DisconnectReason.loggedOut) {
          console.log(`\n❌ GAGAL OTENTIKASI: Di-logout.`);
        } else if (reason === 428) {
          console.log(`\n❌ GAGAL OTENTIKASI: Error 428 (Connection Closed/Protocol). Coba lagi atau HAPUS folder sesi!`);
        }
      }
    });
    
  } catch (error) {
    // Blok ini menangkap error yang kamu dapatkan (Connection Closed)
    console.error(`\n❌ GAGAL MENGAMBIL KODE OTENTIKASI!`);
    console.error(`Error: ${error.output?.payload?.message || error.message}`);
    console.error(`SOLUSI: Harap hapus folder 'auth_info_baileys' dan coba lagi.`);
    process.exit(1);
  }
}

startAuth();