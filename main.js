// main.js - (Final) Router Pesan
require('dotenv').config();
const { makeWASocket, useMultiFileAuthState, DisconnectReason, fetchLatestBaileysVersion } = require('@whiskeysockets/baileys');
const chalk = require('chalk');
const { handleCommand } = require('./script.js');

const startBot = async () => {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
    const { version } = await fetchLatestBaileysVersion();
    const sock = makeWASocket({ version, auth: state, printQRInTerminal: false });
    
    sock.ev.on('connection.update', (update) => {
        const { connection, lastDisconnect } = update;
        if (connection === 'close') {
            const shouldReconnect = (lastDisconnect.error)?.output?.statusCode !== DisconnectReason.loggedOut;
            if (shouldReconnect) startBot();
        } else if (connection === 'open') {
            console.log(chalk.green.bold("✅ Bot terhubung dan siap menerima pesan!"));
        }
    });
    
    sock.ev.on('creds.update', saveCreds);
    
    sock.ev.on('messages.upsert', async ({ messages }) => {
        const msg = messages[0];
        if (!msg.message || msg.key.fromMe) return;
        
        const from = msg.key.remoteJid;
        const text = msg.message.conversation || msg.message.extendedTextMessage?.text || '';
        const senderName = msg.pushName || "Cuy";
        
        // Abaikan chat di grup, kecuali jika disebut (opsional)
        if (from.endsWith('@g.us')) return;
        
        // Semua pesan (perintah atau chat biasa) dilempar ke handleCommand
        await handleCommand(sock, msg, from, text, senderName);
    });
};

startBot().catch(err => console.error(chalk.bgRed.white("KESALAHAN FATAL:"), err));