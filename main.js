// main.js
require('dotenv').config();
const { makeWASocket, useMultiFileAuthState, DisconnectReason, fetchLatestBaileysVersion } = require('@whiskeysockets/baileys');
const chalk = require('chalk');
const { getGeminiResponse } = require('./gemini.js');

const startBot = async () => {
    console.log(chalk.cyan.bold("================== BOT STARTING =================="));
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
    const { version } = await fetchLatestBaileysVersion();
    
    const sock = makeWASocket({ version, auth: state, printQRInTerminal: false });
    
    sock.ev.on('connection.update', (update) => {
        const { connection, lastDisconnect } = update;
        if (connection === 'close') {
            const shouldReconnect = (lastDisconnect.error)?.output?.statusCode !== DisconnectReason.loggedOut;
            console.log(chalk.red(`Koneksi ditutup, mencoba menghubungkan ulang: ${shouldReconnect}`));
            if (shouldReconnect) startBot();
        } else if (connection === 'open') {
            console.log(chalk.green.bold("✅ Bot berhasil terhubung!"));
        }
    });
    
    sock.ev.on('creds.update', saveCreds);
    
    sock.ev.on('messages.upsert', async ({ messages }) => {
        const msg = messages[0];
        if (!msg.message || msg.key.fromMe || msg.key.remoteJid.endsWith('@g.us')) return;
        
        const from = msg.key.remoteJid;
        const text = msg.message.conversation || msg.message.extendedTextMessage?.text || '';
        
        if (text) {
            try {
                await sock.sendPresenceUpdate('composing', from);
                const response = await getGeminiResponse(text);
                await sock.sendMessage(from, { text: response });
                console.log(chalk.green(`[REPLY] Balasan terkirim ke ${from}.`));
            } catch (error) {
                console.error(chalk.red(`[ERROR] Gagal mengirim balasan: ${error.message}`));
            }
        }
    });
};

startBot().catch(err => console.error(chalk.bgRed.white("KESALAHAN FATAL:"), err));