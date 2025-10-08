
require('dotenv').config();
const { makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion, DisconnectReason } = require('@whiskeysockets/baileys');
const chalk = require('chalk');
const qrcode = require('qrcode-terminal');

async function startAuth(method) {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
    const { version } = await fetchLatestBaileysVersion();
    const sock = makeWASocket({ version, auth: state, browser: ['MawwScript-V8', 'Chrome', '120.0.0.0'] });
    sock.ev.on('creds.update', saveCreds);
    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect, qr } = update;
        if (qr) { qrcode.generate(qr, { small: true }); }
        if (connection === 'open') { console.log(chalk.green.bold("\n✅ Otentikasi Berhasil!")); setTimeout(()=>process.exit(0), 1000); }
        if (connection === 'close') {
            const reason = lastDisconnect?.error?.output?.statusCode;
            console.error(chalk.red.bold(`\n❌ GAGAL: ${reason === DisconnectReason.loggedOut ? "Perangkat Ter-logout." : `Koneksi ditutup.`}`));
            process.exit(1);
        }
    });
    if (method === 'code') {
        const phoneNumber = process.env.PHONE_NUMBER;
        if (!phoneNumber) { console.error(chalk.red("❌ Nomor HP tidak ditemukan di .env!")); process.exit(1); }
        try {
            await new Promise(resolve => setTimeout(resolve, 1500));
            const pairingCode = await sock.requestPairingCode(phoneNumber);
            console.log(chalk.green.bold(`\n✅ Kode Anda: ${pairingCode}\n`));
        } catch (e) { console.error(chalk.red(`\n❌ Gagal mendapatkan kode: ${e.message}`)); process.exit(1); }
    }
};
const method = process.argv.find(arg=>arg.startsWith('--method='))?.split('=')[1];
if (method && ['qr', 'code'].includes(method)) { startAuth(method); } else { console.log(chalk.red("Metode tidak valid.")); }