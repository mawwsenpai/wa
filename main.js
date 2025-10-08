// main.js - Manajer & Router Pesan
require('dotenv').config();
const { makeWASocket, useMultiFileAuthState, DisconnectReason, fetchLatestBaileysVersion } = require('@whiskeysockets/baileys');
const chalk = require('chalk');

// Impor logika dari file lain
const { handleCommand } = require('./script.js');
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
            if (shouldReconnect) startBot();
        } else if (connection === 'open') {
            console.log(chalk.green.bold("✅ Bot terhubung dan siap menerima pesan!"));
        }
    });
    
    sock.ev.on('creds.update', saveCreds);
    
    sock.ev.on('messages.upsert', async ({ messages }) => {
        const msg = messages[0];
        if (!msg.message || msg.key.fromMe || msg.key.remoteJid.endsWith('@g.us')) return;
        
        const from = msg.key.remoteJid;
        const text = msg.message.conversation || msg.message.extendedTextMessage?.text || '';
        const senderName = msg.pushName || "Cuy";
        
        // --- INI ADALAH LOGIKA ROUTER-NYA ---
        // Jika pesan dimulai dengan titik (.), anggap sebagai perintah
        if (text.startsWith('.')) {
            console.log(chalk.blue(`[PERINTAH] Dari: ${senderName} | Isi: "${text}"`));
            // Teruskan ke script.js untuk ditangani
            await handleCommand(sock, from, text, senderName);
        } else {
            // Jika tidak, anggap sebagai chat biasa
            console.log(chalk.yellow(`[CHAT BIASA] Dari: ${senderName} | Isi: "${text}"`));
            // Teruskan ke gemini.js untuk direspon oleh AI
            const response = await getGeminiResponse(text);
            await sock.sendMessage(from, { text: response });
        }
    });
};

startBot().catch(err => console.error(chalk.bgRed.white("KESALAHAN FATAL:"), err));