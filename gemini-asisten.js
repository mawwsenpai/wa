// gemini-asisten.js

// Import library Wajib
const {
  makeWASocket,
  useMultiFileAuthState,
  DisconnectReason,
  fetchLatestBaileysVersion
} = require('@whiskeysockets/baileys');
// Import library Gemini
const { GoogleGenAI } = require('@google/genai');

// --- KONFIGURASI PENTING ---
// Variabel ini di-set di main.sh (API KEY, Model, dan Nomor HP)
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-pro';
const phoneNumber = process.env.PHONE_NUMBER;
// ----------------------------

// Inisialisasi Gemini
if (!GEMINI_API_KEY) {
  console.error("❌ ERROR GEMINI: GEMINI_API_KEY belum disetel! Harap jalankan Konfigurasi Gemini API di main.sh");
  process.exit(1);
}
const ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY });


// Fungsi Utama Bot
async function startBot() {
  console.log(`[STATUS] Menggunakan Model Gemini: ${GEMINI_MODEL}`);
  
  // --- (LOGIKA KONEKSI DAN AUTENTIKASI BAILLEYS) ---
  
  // Ambil sesi/auth dari folder 'auth_info_baileys'
  const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
  
  // Cek versi Baileys terbaru
  const { version } = await fetchLatestBaileysVersion();
  console.log(`[STATUS] Menggunakan Baileys versi: ${version}`);
  
  // Bikin koneksi WhatsApp
  const sock = makeWASocket({
    version,
    auth: state,
    // Kita matikan printQRInTerminal karena kita mau pakai pairing code
    printQRInTerminal: false,
    browser: ['MawwScriptV2', 'Safari', '1.0.0'],
  });
  
  // Logika PAIRING CODE (Kode 8 Digit) - JIKA BELUM TERDAFTAR
  if (!sock.authState.creds.registered) {
    if (!phoneNumber) {
      throw new Error('❌ ERROR: Nomor HP belum disetel! Harap jalankan Konfigurasi Nomor WA di main.sh');
    }
    
    // Minta kode pairing dari WhatsApp
    const pairingCode = await sock.requestPairingCode(phoneNumber);
    
    console.log(`\n======================================`);
    console.log(`🔥 GASS! KODE PAIRING KAMU ADALAH: ${pairingCode}`);
    console.log(`SEGERA MASUKKAN KODE INI DI HP KAMU:`);
    console.log(`(Buka WhatsApp Utama > Pengaturan/Settings > Perangkat Tertaut > Tautkan dengan Nomor Telepon)`);
    console.log(`======================================\n`);
  }
  
  // 1. EVENT LISTENER: Atur kalo koneksi ada perubahan
  sock.ev.on('connection.update', (update) => {
    const { connection, lastDisconnect } = update;
    
    if (connection === 'close') {
      const shouldReconnect = (lastDisconnect.error)?.output?.statusCode !== DisconnectReason.loggedOut;
      console.log('Koneksi tertutup. Mencoba hubungkan ulang:', shouldReconnect);
      
      if (shouldReconnect) {
        startBot();
      } else {
        console.log('❌ Koneksi Di-logout! Hapus folder auth_info_baileys untuk login lagi.');
      }
    } else if (connection === 'open') {
      console.log('Koneksi tersambung! Bot siap beraksi! 😎');
    }
  });
  
  // Simpen sesi/kredensial setiap ada perubahan
  sock.ev.on('creds.update', saveCreds);
  
  // --- (LOGIKA BALASAN DENGAN GEMINI) ---
  
  // 2. EVENT LISTENER: Logic Balasan dengan Gemini
  sock.ev.on('messages.upsert', async ({ messages, type }) => {
    const m = messages[0];
    // Abaikan jika tidak ada pesan atau pesan dari bot sendiri (fromMe)
    if (!m.message || m.key.fromMe) return;
    
    const from = m.key.remoteJid;
    // Ambil teks dari berbagai jenis pesan
    const text = m.message.conversation || m.message.extendedTextMessage?.text || '';
    const lowerText = text.toLowerCase();
    
    console.log(`[PESAN BARU] Dari: ${from} | Isi: ${text}`);
    
    // 1. Balasan Khusus (Sesuai Perintah User di Saved Information)
    let response = '';
    if (lowerText === 'hey') {
      response = 'Kamu siapa? 🤔';
    } else if (lowerText === 'maww') {
      response = 'oh sayangku 🥰';
    } else if (lowerText === 'lah') {
      response = 'Gajelas 😒';
    } else if (lowerText === 'masa lupa sih') {
      response = 'Kan udah kujelasin, kamu siapa?';
    }
    
    if (response) {
      await sock.sendMessage(from, { text: response });
      return; // Jangan lanjut ke Gemini jika ada balasan khusus
    }
    
    // 2. Balasan Otomatis Menggunakan Gemini
    try {
      console.log(`[GEMINI] Meneruskan pesan ke AI...`);
      
      // Perintah ke Gemini
      const result = await ai.models.generateContent({
        model: GEMINI_MODEL,
        contents: text,
      });
      
      const geminiResponse = result.text.trim();
      
      // Kirim balasan dari Gemini
      await sock.sendMessage(from, { text: geminiResponse });
      console.log(`[BOT BALAS GEMINI] Balasan: ${geminiResponse.substring(0, 50)}...`);
      
    } catch (e) {
      console.error('❌ ERROR GEMINI RESPONSE:', e);
      await sock.sendMessage(from, { text: `Yah, ${GEMINI_MODEL} lagi ngambek nih. Coba lagi ya, Cuy! 😔` });
    }
  });
}

startBot();