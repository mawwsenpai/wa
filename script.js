// script.js - Versi Final - Tampilan & Logika Lengkap

const fs = require('fs');
const chalk = require('chalk');
const axios = require('axios');
const ytSearch = require('yt-search');
const ytdl = require('ytdl-core');
const { downloadContentFromMessage } = require('@whiskeysockets/baileys');

// --- DATABASE & STATE MANAGEMENT ---
const DB_FILE = './users.json';
let userState = {};
let users = {};
const startTime = new Date(); // Catat waktu bot mulai berjalan

const loadDatabase = () => {
  if (fs.existsSync(DB_FILE)) {
    users = JSON.parse(fs.readFileSync(DB_FILE));
  }
};

const saveDatabase = () => {
  fs.writeFileSync(DB_FILE, JSON.stringify(users, null, 2));
};

loadDatabase();

// --- FUNGSI BANTUAN ---
function formatUptime(milliseconds) {
  let totalSeconds = Math.floor(milliseconds / 1000);
  let days = Math.floor(totalSeconds / 86400);
  totalSeconds %= 86400;
  let hours = Math.floor(totalSeconds / 3600);
  totalSeconds %= 3600;
  let minutes = Math.floor(totalSeconds / 60);
  let seconds = totalSeconds % 60;
  return `${days} hari, ${hours} jam, ${minutes} menit, ${seconds} detik`;
}

// --- FUNGSI UTAMA PENANGAN PERINTAH ---
async function handleCommand(sock, msg, from, text, senderName) {
  loadDatabase();
  const currentState = userState[from];
  const isRegistered = !!users[from];
  const command = text.toLowerCase().split(' ')[0];
  const query = text.substring(command.length).trim();
  
  // ====================================================================
  // --- BLOK PENDAFTARAN & MENU UTAMA ---
  // ====================================================================
  if (command === '.menu') {
    if (isRegistered) {
      const menuText = `*🤖 BOT-WHATSAPP MENU 🤖*
*MawwScript v6.1-Stabil*

Halo, *${users[from].username}*!

╭─「 *PENCARIAN* 」
│ ◦ .poto <query>
│ ◦ .google <query>
│ ◦ .ytsearch <query>
╰───⬣

╭─「 *MEDIA & ALAT* 」
│ ◦ .ytaudio <link>
│ ◦ .sticker (reply gambar)
│ ◦ .cuaca <kota>
╰───⬣

╭─「 *PROFIL ANDA* 」
│ ◦ .me
╰───⬣

╭─「 *GAME* (Segera Hadir) 」
│ ◦ .tebakgambar 
│ ◦ .tebaklagu
╰───⬣

╭─「 *INFO* 」
│ ◦ .owner
╰───⬣
`;
      await sock.sendMessage(from, { text: menuText });
    } else {
      await sock.sendMessage(from, { text: "Selamat Datang! Anda belum terdaftar.\n\nKetik *Daftar* untuk memulai proses registrasi." });
      userState[from] = 'menunggu_daftar';
    }
    return;
  }
  
  if (currentState === 'menunggu_daftar' && text.toLowerCase() === 'daftar') {
    await sock.sendMessage(from, { text: "Proses registrasi dimulai.\n\nSilakan masukkan *Username* yang Anda inginkan:" });
    userState[from] = 'memasukkan_username';
    return;
  }
  if (currentState === 'memasukkan_username') {
    users[from] = { username: text, registeredAt: new Date() };
    await sock.sendMessage(from, { text: `Username "${text}" diterima.\n\nSekarang masukkan *Sandi*:` });
    userState[from] = 'memasukkan_sandi';
    return;
  }
  if (currentState === 'memasukkan_sandi') {
    users[from].sandi = text;
    users[from].status = 'Free';
    saveDatabase();
    delete userState[from];
    const welcomeMessage = `🎉 *Registrasi Berhasil!* 🎉\n\nSelamat bergabung, *${users[from].username}*!\nKetik *.menu* untuk melihat semua fitur yang tersedia.`;
    await sock.sendMessage(from, { text: welcomeMessage });
    return;
  }
  
  // Blokir perintah lain jika belum terdaftar
  if (!isRegistered) {
    await sock.sendMessage(from, { text: "Anda belum terdaftar. Silakan ketik `.menu` untuk memulai." });
    return;
  }
  
  // ====================================================================
  // --- BLOK FITUR-FITUR BOT (Untuk User Terdaftar) ---
  // ====================================================================
  
  switch (command) {
    case '.me':
    case '.profile':
      const user = users[from];
      const profileText = `*❖ PROFIL PENGGUNA ❖*
*Status:* ${user.status} ✅ Terverifikasi

👤 *Nama:* ${user.username}
📱 *Nomor:* ${from.split('@')[0]}
🕒 *Waktu Server:* ${new Date().toLocaleTimeString('id-ID', { timeZone: 'Asia/Jakarta' })} WIB
🔋 *Bot Aktif Selama:* ${formatUptime(new Date() - startTime)}
`;
      await sock.sendMessage(from, { text: profileText });
      break;
      
    case '.poto':
      if (!query) return await sock.sendMessage(from, { text: 'Contoh: .poto kucing lucu' });
      await sock.sendMessage(from, { text: `🔎 Mencari gambar "${query}" di Unsplash...` });
      try {
        const response = await axios.get(`https://api.unsplash.com/search/photos`, {
          params: { query: query, per_page: 5 },
          headers: { Authorization: `Client-ID ${process.env.UNSPLASH_API_KEY}` }
        });
        if (response.data.results.length > 0) {
          const randomImage = response.data.results[Math.floor(Math.random() * response.data.results.length)];
          await sock.sendMessage(from, { image: { url: randomImage.urls.regular }, caption: `✅ Gambar "${query}" dari Unsplash.` });
        } else { await sock.sendMessage(from, { text: `😥 Gambar untuk "${query}" tidak ditemukan.` }); }
      } catch (error) { await sock.sendMessage(from, { text: 'Gagal mengambil gambar. Pastikan UNSPLASH_API_KEY sudah benar.' }); }
      break;
      
    case '.cuaca':
      if (!query) return await sock.sendMessage(from, { text: 'Contoh: .cuaca Jakarta' });
      await sock.sendMessage(from, { text: `🌤️ Mengecek cuaca untuk "${query}"...` });
      try {
        const response = await axios.get(`http://api.weatherapi.com/v1/current.json?key=${process.env.WEATHER_API_KEY}&q=${query}&aqi=no`);
        const data = response.data;
        const reply = `*Cuaca di ${data.location.name}*\n\n🌡️ Suhu: ${data.current.temp_c}°C\n📝 Kondisi: ${data.current.condition.text}\n💧 Kelembapan: ${data.current.humidity}%\n💨 Angin: ${data.current.wind_kph} km/jam`;
        await sock.sendMessage(from, { text: reply });
      } catch (error) { await sock.sendMessage(from, { text: 'Gagal mendapatkan data cuaca. Pastikan nama kota dan WEATHER_API_KEY benar.' }); }
      break;
      
    case '.ytsearch':
      if (!query) return await sock.sendMessage(from, { text: 'Contoh: .ytsearch lofi hip hop' });
      await sock.sendMessage(from, { text: `🔎 Mencari video "${query}" di YouTube...` });
      const videos = await ytSearch(query);
      if (videos.videos.length > 0) {
        let reply = `✅ Ditemukan 5 video teratas untuk "${query}":\n\n`;
        videos.videos.slice(0, 5).forEach((v, i) => { reply += `${i + 1}. *${v.title}* (${v.timestamp})\n   Link: ${v.url}\n\n`; });
        await sock.sendMessage(from, { text: reply });
      } else { await sock.sendMessage(from, { text: `😥 Video untuk "${query}" tidak ditemukan.` }); }
      break;
      
    case '.ytaudio':
      if (!ytdl.validateURL(query)) return await sock.sendMessage(from, { text: '❌ URL YouTube tidak valid.' });
      await sock.sendMessage(from, { text: `📥 Mengunduh audio... Mohon tunggu.` });
      try {
        const info = await ytdl.getInfo(query);
        await sock.sendMessage(from, { audio: { url: query }, mimetype: 'audio/mp4', fileName: `${info.videoDetails.title}.mp3` });
      } catch (error) { await sock.sendMessage(from, { text: 'Gagal mengunduh audio.' }); }
      break;
      
    case '.sticker':
      if (msg.message.extendedTextMessage?.contextInfo?.quotedMessage?.imageMessage || msg.message.imageMessage) {
        await sock.sendMessage(from, { text: 'Membuat stiker...' });
        try {
          const messageType = msg.message.imageMessage ? msg.message : msg.message.extendedTextMessage.contextInfo.quotedMessage;
          const stream = await downloadContentFromMessage(messageType.imageMessage, 'image');
          let buffer = Buffer.from([]);
          for await (const chunk of stream) { buffer = Buffer.concat([buffer, chunk]); }
          await sock.sendMessage(from, { sticker: buffer });
        } catch (error) { await sock.sendMessage(from, { text: 'Gagal membuat stiker.' }); }
      } else { await sock.sendMessage(from, { text: 'Reply sebuah gambar dengan perintah .sticker' }); }
      break;
      
    case '.owner':
      await sock.sendMessage(from, { text: "*Kontak Developer*\n\n*Gmail:* your.email@gmail.com\n*WhatsApp:* wa.me/62..." });
      break;
      
    default:
      // Jika perintah tidak dikenali, lempar ke AI
      console.log(chalk.yellow(`[CHAT BIASA] Dari: ${senderName} | Isi: "${text}"`));
      const response = await getGeminiResponse(text);
      await sock.sendMessage(from, { text: response });
      break;
  }
}

module.exports = { handleCommand };