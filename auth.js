// auth.js (Sudah Diperbaiki)
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
    console.log(chalk.cyan('Mempersiapkan sesi...'));
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
    const { version } = await fetchLatestBaileysVersion();

    const sock = makeWASocket({
        version,
        auth: state,
        printQRInTerminal: false, // Kita handle QR manual
        browser: ['MawwScript-V10', 'Chrome', '120.0.0.0']
    });

    sock.ev.on('creds.update', saveCreds);

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update;

        if (qr) {
            console.log(chalk.yellow('\nSilakan scan QR Code di bawah ini:\n'));
            qrcode.generate(qr, { small: true });
        }

        if (connection === 'connecting') {
            console.log(chalk.yellow('Menghubungkan ke WhatsApp...'));
        }

        if (connection === 'open') {
            console.log(chalk.green.bold("\n✅ Otentikasi Berhasil! Koneksi terhubung."));
            // Menutup proses setelah 2 detik agar pesan terbaca
            setTimeout(() => process.exit(0), 2000); 
        }

        if (connection === 'close') {
            const statusCode = lastDisconnect?.error?.output?.statusCode;

            if (statusCode && statusCode !== DisconnectReason.loggedOut) {
                console.log(chalk.yellow(`Koneksi terputus (Kode: ${statusCode}), mencoba menghubungkan ulang...`));
                // Coba sambungkan lagi dengan memanggil fungsi utama
                startAuth(method);
            } else {
                console.error(chalk.red.bold(`\n❌ GAGAL: Perangkat Ter-logout.`));
                console.log(chalk.yellow('Harap hapus folder "auth_info_baileys" dan hubungkan ulang.'));
                process.exit(1);
            }
        }
    });
    
    // Bagian untuk pairing code tetap sama
    if (method === 'code') {
        const phoneNumber = process.env.PHONE_NUMBER;
        if (!phoneNumber) {
            console.error(chalk.red("❌ Nomor HP tidak ditemukan di .env! Atur di Menu 2."));
            process.exit(1);
        }
        try {
            await new Promise(resolve => setTimeout(resolve, 1500)); // Jeda singkat
            const pairingCode = await sock.requestPairingCode(phoneNumber);
            console.log(chalk.green.bold(`\n✅ Kode Pairing WhatsApp Anda: ${pairingCode}\n`));
        } catch (e) {
            console.error(chalk.red(`\n❌ Gagal mendapatkan kode: ${e.message}`));
            console.log(chalk.yellow('Pastikan nomor HP benar dan perangkat terhubung ke internet.'));
            process.exit(1);
        }
    }
};

// --- Pemicu Skrip ---
// Mengambil argumen --method dari command line
const method = process.argv.find(arg => arg.startsWith('--method='))?.split('=')[1];
if (method && ['qr', 'code'].includes(method)) {
    startAuth(method);
} else {
    console.log(chalk.red("Metode tidak valid. Gunakan --method=qr atau --method=code"));
}
