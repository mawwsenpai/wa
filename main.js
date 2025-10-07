// main.js

const { makeWASocket, useMultiFileAuthState, DisconnectReason, fetchLatestBaileysVersion } = require('@whiskeysockets/baileys');
// Import Logic Balasan dari gemini-config.js
const { handleMessage } = require('./gemini-config'); 

// Diambil dari main.sh, memastikan API Key sudah ada
if (!process.env.GEMINI_API_KEY) {
    console.error("❌ ERROR: API Key belum dimuat. Jalankan Menu 3 (Konfigurasi Gemini)!");
    process.exit(1);
}

async function startBot() {
    console.log(`[STATUS] BOT ONLINE`);

    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
    const { version } = await fetchLatestBaileysVersion();
    
    // Cek apakah sudah terautentikasi (wajib)
    if (!state.creds.registered) {
        console.error("❌ ERROR: Bot belum terautentikasi! Jalankan Menu 4 (Otentikasi WA) dulu.");
        process.exit(1);
    }
    
    const sock = makeWASocket({
        version,
        auth: state,
        browser: ['MawwScriptV5', 'Chrome', '110.0.0.0'],
    });

    sock.ev.on('connection.update', (update) => {
        const { connection, lastDisconnect } = update;
        if (connection === 'close') {
            const shouldReconnect = (lastDisconnect.error)?.output?.statusCode !== DisconnectReason.loggedOut;
            console.log('Koneksi tertutup. Mencoba hubungkan ulang:', shouldReconnect);
            if (shouldReconnect) { startBot(); } else {
                console.log('❌ Di-logout! Hapus auth_info_baileys untuk login lagi.');
            }
        } else if (connection === 'open') {
            console.log('✅ Bot tersambung dan siap beraksi! 😎');
        }
    });

    sock.ev.on('creds.update', saveCreds);

    // Event Pesan: Kirim ke gemini-config.js untuk di-handle
    sock.ev.on('messages.upsert', async ({ messages, type }) => {
        const m = messages[0];
        if (!m.message || m.key.fromMe) return; 

        const from = m.key.remoteJid;
        const text = m.message.conversation || m.message.extendedTextMessage?.text || '';
        
        // Panggil fungsi balasan AI
        handleMessage(sock, m, from, text);
    });
}

startBot();