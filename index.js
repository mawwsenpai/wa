// index.js

// Import module yang dibutuhkan dari Baileys
const {
    makeWASocket,
    useMultiFileAuthState,
    DisconnectReason,
    fetchLatestBaileysVersion
} = require('@whiskeysockets/baileys');

// Fungsi utama buat jalanin bot
async function startBot() {
    // Ganti dengan nomor HP kamu (format 628xxxxxxxxx)
    const phoneNumber = '628XXXXXXXXXX'; // <--- GANTI NOMOR INI, CUY!

    // Ambil sesi/auth dari folder 'auth_info_baileys'
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
    
    // Cek versi Baileys terbaru
    const { version } = await fetchLatestBaileysVersion();
    console.log(`Menggunakan Baileys versi: ${version}`);

    // Bikin koneksi WhatsApp
    const sock = makeWASocket({
        version,
        auth: state,
        // Kita matikan printQRInTerminal karena kita mau pakai pairing code
        printQRInTerminal: false, 
        browser: ['TermuxBot', 'Safari', '1.0.0'], // Meniru device/browser
    });

    // Cek status login
    if (!sock.authState.creds.registered) {
        // Jika belum terautentikasi, minta kode pairing (kode 8 digit)
        if (!phoneNumber) {
             throw new Error('❌ ERROR: Harap masukkan nomor HP di kode index.js!');
        }
        
        // Minta kode pairing dari WhatsApp
        const pairingCode = await sock.requestPairingCode(phoneNumber);

        console.log(`\n======================================`);
        console.log(`🔥 GASS! KODE PAIRING KAMU ADALAH: ${pairingCode}`);
        console.log(`SEGERA MASUKKAN KODE INI DI HP KAMU:`);
        console.log(`(Buka WhatsApp Utama > Pengaturan/Settings > Perangkat Tertaut/Linked Devices > Tautkan dengan Nomor Telepon/Link with Phone Number)`);
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


    // 2. EVENT LISTENER: Atur kalo ada pesan masuk (Logika Bot Kamu!)
    sock.ev.on('messages.upsert', async ({ messages, type }) => {
        const m = messages[0];
        if (!m.message || m.key.fromMe) return; 

        const from = m.key.remoteJid;
        const text = m.message.conversation || m.message.extendedTextMessage?.text || '';
        
        console.log(`[PESAN BARU] Dari: ${from} | Isi: ${text}`);

        // --- LOGIKA BALASAN Sesuai Request Kamu ---
        const lowerText = text.toLowerCase();
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
             console.log(`[BOT BALAS] ke: ${from} | Balasan: ${response}`);
        }
    });
}

// Jalankan fungsi bot
startBot();
