// wa-config.js

const { makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion } = require('@whiskeysockets/baileys');

// Diambil dari environment variable (diekspor oleh main.sh)
const phoneNumber = process.env.PHONE_NUMBER;

async function startAuth() {
  console.log(`[AUTH] Memulai Proses Otentikasi WA...`);
  
  const { state } = await useMultiFileAuthState('auth_info_baileys');
  const { version } = await fetchLatestBaileysVersion();
  
  // Check apakah sudah terdaftar
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
  
  try {
    const pairingCode = await sock.requestPairingCode(phoneNumber);
    
    console.log(`\n======================================`);
    console.log(`🔥 KODE OTENTIKASI (8 DIGIT) KAMU: ${pairingCode}`);
    console.log(`MASUKKAN KODE INI SEGERA DI HP KAMU.`);
    console.log(`======================================\n`);
    
    // Loop sampai berhasil membuat session
    sock.ev.on('connection.update', (update) => {
      if (update.connection === 'open') {
        console.log('✅ OTENTIKASI SUKSES! Session tersimpan. Kamu bisa menjalankan Menu 5 sekarang.');
        process.exit(0);
      }
    });
    
  } catch (error) {
    console.error(`\n❌ GAGAL MENGAMBIL KODE OTENTIKASI!`);
    console.error(`Error: ${error.output?.payload?.message || error.message}`);
    console.error(`SOLUSI: Coba lagi atau hapus folder 'auth_info_baileys'.`);
    process.exit(1);
  }
}

startAuth();