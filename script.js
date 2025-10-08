// script.js - (Final) Pusat Fitur dengan Tampilan & Logika Lengkap
const fs = require('fs');
const chalk = require('chalk');
const axios = require('axios');
const ytSearch = require('yt-search');
const ytdl = require('ytdl-core');
const { downloadContentFromMessage } = require('@whiskeysockets/baileys');
const { getGeminiResponse } = require('./gemini.js');

const DB_FILE = './users.json';
let userState = {};
let users = {};
const startTime = new Date();

const loadDatabase = () => { if (fs.existsSync(DB_FILE)) { users = JSON.parse(fs.readFileSync(DB_FILE)); } };
const saveDatabase = () => { fs.writeFileSync(DB_FILE, JSON.stringify(users, null, 2)); };
loadDatabase();

function formatUptime(ms) { let s=Math.floor(ms/1000);let d=Math.floor(s/86400);s%=86400;let h=Math.floor(s/3600);s%=3600;let m=Math.floor(s/60);s%=60;return `${d}h, ${h}j, ${m}m, ${s}d`; }

async function handleCommand(sock, msg, from, text, senderName) {
    loadDatabase();
    const currentState = userState[from];
    const isRegistered = !!users[from];
    const command = text.toLowerCase().split(' ')[0];
    const query = text.substring(command.length).trim();

    if (command === '.menu') {
        if (isRegistered) {
            const menuText = `*🤖 BOT-WHATSAPP MENU 🤖*\n*MawwScript v8.0-Stabil*\n\nHalo, *${users[from].username}*!\n\n╭─「 *PENCARIAN* 」\n│ ◦ .poto <query>\n│ ◦ .google <query>\n│ ◦ .ytsearch <query>\n╰───⬣\n\n╭─「 *MEDIA & ALAT* 」\n│ ◦ .ytaudio <link>\n│ ◦ .sticker (reply gambar)\n│ ◦ .cuaca <kota>\n╰───⬣\n\n╭─「 *PROFIL* 」\n│ ◦ .me\n╰───⬣\n\n╭─「 *INFO* 」\n│ ◦ .owner\n╰───⬣`;
            await sock.sendMessage(from, { text: menuText });
        } else {
            await sock.sendMessage(from, { text: "Selamat Datang! Anda belum terdaftar.\n\nKetik *Daftar* untuk memulai." });
            userState[from] = 'menunggu_daftar';
        }
        return;
    }
    if (currentState === 'menunggu_daftar' && text.toLowerCase() === 'daftar') {
        await sock.sendMessage(from, { text: "Proses registrasi dimulai.\n\nSilakan masukkan *Username*:" });
        userState[from] = 'memasukkan_username';
        return;
    }
    if (currentState === 'memasukkan_username') {
        users[from] = { username: text, registeredAt: new Date() }; saveDatabase();
        await sock.sendMessage(from, { text: `Username "${text}" diterima.\nKetik *.menu* untuk melihat semua fitur.` });
        delete userState[from];
        return;
    }
    if (!isRegistered) { await sock.sendMessage(from, { text: "Anda belum terdaftar. Silakan ketik `.menu` untuk memulai." }); return; }

    switch (command) {
        case '.me':
            const user = users[from];
            const profileText = `*❖ PROFIL PENGGUNA ❖*\n*Status:* ${user.status || 'Free'} ✅ Terverifikasi\n\n👤 *Nama:* ${user.username}\n📱 *Nomor:* ${from.split('@')[0]}\n🕒 *Waktu Server:* ${new Date().toLocaleTimeString('id-ID',{timeZone:'Asia/Jakarta'})} WIB\n🔋 *Bot Aktif Selama:* ${formatUptime(new Date()-startTime)}`;
            await sock.sendMessage(from, { text: profileText });
            break;
        case '.poto':
            if (!query) return await sock.sendMessage(from, { text: 'Contoh: .poto kucing' }); await sock.sendMessage(from, { text: `🔎 Mencari gambar "${query}"...` });
            try { const r=await axios.get(`https://api.unsplash.com/search/photos`,{params:{query:query,per_page:5},headers:{Authorization:`Client-ID ${process.env.UNSPLASH_API_KEY}`}}); if(r.data.results.length>0){const i=r.data.results[Math.floor(Math.random()*r.data.results.length)];await sock.sendMessage(from, {image:{url:i.urls.regular},caption:`✅ Gambar dari Unsplash.`});} else {await sock.sendMessage(from,{text:`😥 Gambar tidak ditemukan.`});}} catch (e) {await sock.sendMessage(from, {text:'Gagal. Pastikan UNSPLASH_API_KEY benar.'});} break;
        case '.cuaca':
            if (!query) return await sock.sendMessage(from, { text: 'Contoh: .cuaca Jakarta' }); await sock.sendMessage(from, { text: `🌤️ Mengecek cuaca untuk "${query}"...` });
            try { const r=await axios.get(`http://api.weatherapi.com/v1/current.json?key=${process.env.WEATHER_API_KEY}&q=${query}&aqi=no`); const d=r.data; await sock.sendMessage(from,{text:`*Cuaca di ${d.location.name}*\n\n🌡️ Suhu: ${d.current.temp_c}°C\n📝 Kondisi: ${d.current.condition.text}\n💨 Angin: ${d.current.wind_kph} km/jam`}); } catch (e) { await sock.sendMessage(from,{text:'Gagal. Pastikan nama kota & WEATHER_API_KEY benar.'});} break;
        case '.ytsearch':
            if (!query) return await sock.sendMessage(from, { text: 'Contoh: .ytsearch lofi' }); await sock.sendMessage(from, { text: `🔎 Mencari video "${query}"...` });
            const v = await ytSearch(query); if(v.videos.length>0){let t=`✅ 5 video teratas:\n\n`;v.videos.slice(0,5).forEach((i,o)=>{t+=`${o+1}. *${i.title}* (${i.timestamp})\n   ${i.url}\n\n`;});await sock.sendMessage(from,{text:t});}else{await sock.sendMessage(from,{text:`😥 Video tidak ditemukan.`});} break;
        case '.ytaudio':
            if (!ytdl.validateURL(query)) return await sock.sendMessage(from, { text: '❌ URL YouTube tidak valid.' }); await sock.sendMessage(from, { text: `📥 Mengunduh audio...` });
            try { const i=await ytdl.getInfo(query); await sock.sendMessage(from, {audio:{url:query},mimetype:'audio/mp4',fileName:`${i.videoDetails.title}.mp3`}); } catch (e) { await sock.sendMessage(from,{text:'Gagal mengunduh audio.'});} break;
        case '.sticker':
            if(msg.message.extendedTextMessage?.contextInfo?.quotedMessage?.imageMessage||msg.message.imageMessage){await sock.sendMessage(from,{text:'Membuat stiker...'});const t=msg.message.imageMessage?msg.message:msg.message.extendedTextMessage.contextInfo.quotedMessage;const s=await downloadContentFromMessage(t.imageMessage,'image');let b=Buffer.from([]);for await(const c of s){b=Buffer.concat([b,c]);} await sock.sendMessage(from,{sticker:b});}else{await sock.sendMessage(from,{text:'Reply gambar dengan .sticker'});} break;
        case '.owner': await sock.sendMessage(from, { text: "*Kontak Developer*\n\n*Gmail:* your.email@gmail.com" }); break;
        default: const response = await getGeminiResponse(text); await sock.sendMessage(from, { text: response }); break;
    }
}
module.exports = { handleCommand };