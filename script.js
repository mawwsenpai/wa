// script.js - Versi 3.0 - Penuh Fitur

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

const loadDatabase = () => {
  if (fs.existsSync(DB_FILE)) {
    users = JSON.parse(fs.readFileSync(DB_FILE));
  }
};

const saveDatabase = () => {
  fs.writeFileSync(DB_FILE, JSON.stringify(users, null, 2));
};

loadDatabase();

// --- FUNGSI UTAMA PENANGAN PERINTAH ---
async function handleCommand(sock, msg, from, text, senderName) {
  loadDatabase();
  const currentState = userState[from];
  
  // ====================================================================
  // --- BLOK PENDAFTARAN PENGGUNA ---
  // ====================================================================
  if (text.toLowerCase() === '.menu') {
    await sock.sendMessage(from, { text: "Selamat Datang!\n\nSilakan pilih:\n- Free\n- Prem" });
    userState[from] = 'menunggu_pilihan_awal';
    return;
  }
  if (currentState === 'menunggu_pilihan_awal' && text.toLowerCase() === 'free') {
    await sock.sendMessage(from, { text: "Mode Free.\nMasukkan Username Anda:" });
    userState[from] = 'memasukkan_username';
    return;
  }
  if (currentState === 'memasukkan_username') {
    users[from] = { username: text };
    await sock.sendMessage(from, { text: `Username "${text}" diterima.\nSekarang masukkan Sandi:` });
    userState[from] = 'memasukkan_sandi';
    return;
  }
  if (currentState === 'memasukkan_sandi') {
    users[from].sandi = text;
    await sock.sendMessage(from, { text: `Sandi diterima.\nMasukkan IP:PORT proxy (opsional, ketik 'skip' untuk melewati):` });
    userState[from] = 'memasukkan_proxy';
    return;
  }
  if (currentState === 'memasukkan_proxy') {
    const proxy = text.toLowerCase() === 'skip' ? null : text;
    users[from].proxy = proxy;
    users[from].status = 'Free';
    saveDatabase();
    delete userState[from];
    
    const welcomeMessage = `🎉 Registrasi Berhasil! 🎉\n\nHallo ${users[from].username}!\nStatus: ${users[from].status}\nProxy: ${users[from].proxy || 'Tidak diatur'}\n\n--- MENU FITUR ---\n.poto [query]\n.ytsearch [query]\n.ytaudio [link youtube]\n.cuaca [nama kota]\n.sticker (reply gambar)`;
    await sock.sendMessage(from, { text: welcomeMessage });
    return;
  }
  
  // Cek apakah user sudah terdaftar sebelum menggunakan fitur lain
  if (!users[from]) {
    await sock.sendMessage(from, { text: "Anda belum terdaftar. Silakan ketik `.menu` untuk memulai." });
    return;
  }
  
  // ====================================================================
  // --- BLOK FITUR-FITUR BOT ---
  // ====================================================================
  
  // Fitur Pencarian Gambar Unsplash
  if (text.toLowerCase().startsWith('.poto')) {
    const query = text.substring(6).trim();
    if (!query) return await sock.sendMessage(from, { text: 'Contoh: .poto kucing lucu' });
    await sock.sendMessage(from, { text: `🔎 Mencari gambar "${query}" di Unsplash...` });
    
    try {
      const userProxy = users[from].proxy ? {
        host: users[from].proxy.split(':')[0],
        port: parseInt(users[from].proxy.split(':')[1])
      } : null;
      
      const response = await axios.get(`https://api.unsplash.com/search/photos`, {
        params: { query: query, per_page: 5 },
        headers: { Authorization: `Client-ID ${process.env.UNSPLASH_API_KEY}` },
        proxy: userProxy
      });
      
      if (response.data.results.length > 0) {
        const randomImage = response.data.results[Math.floor(Math.random() * response.data.results.length)];
        await sock.sendMessage(from, {
          image: { url: randomImage.urls.regular },
          caption: `✅ Gambar "${query}" oleh ${randomImage.user.name} dari Unsplash.`
        });
      } else {
        await sock.sendMessage(from, { text: `😥 Gambar untuk "${query}" tidak ditemukan.` });
      }
    } catch (error) {
      console.error(error);
      await sock.sendMessage(from, { text: 'Gagal mengambil gambar. Pastikan UNSPLASH_API_KEY sudah benar.' });
    }
    return;
  }
  
  // Fitur Pencarian YouTube
  if (text.toLowerCase().startsWith('.ytsearch')) {
    const query = text.substring(10).trim();
    if (!query) return await sock.sendMessage(from, { text: 'Contoh: .ytsearch lofi hip hop' });
    await sock.sendMessage(from, { text: `🔎 Mencari video "${query}" di YouTube...` });
    const videos = await ytSearch(query);
    if (videos.videos.length > 0) {
      let reply = `✅ Ditemukan ${videos.videos.length} video untuk "${query}":\n\n`;
      videos.videos.slice(0, 5).forEach((v, i) => {
        reply += `${i + 1}. *${v.title}* (${v.timestamp})\n   Link: ${v.url}\n\n`;
      });
      await sock.sendMessage(from, { text: reply });
    } else {
      await sock.sendMessage(from, { text: `😥 Video untuk "${query}" tidak ditemukan.` });
    }
    return;
  }
  
  // Fitur Download Audio YouTube
  if (text.toLowerCase().startsWith('.ytaudio')) {
    const url = text.substring(9).trim();
    if (!ytdl.validateURL(url)) return await sock.sendMessage(from, { text: '❌ URL YouTube tidak valid.' });
    await sock.sendMessage(from, { text: `📥 Mengunduh audio dari YouTube... Mohon tunggu.` });
    try {
      const info = await ytdl.getInfo(url);
      const audioStream = ytdl(url, { filter: 'audioonly', quality: 'highestaudio' });
      await sock.sendMessage(from, {
        audio: audioStream,
        mimetype: 'audio/mp4',
        ptt: false, // ptt: true untuk voice note
        fileName: `${info.videoDetails.title}.mp3`
      });
    } catch (error) {
      console.error(error);
      await sock.sendMessage(from, { text: 'Gagal mengunduh audio.' });
    }
    return;
  }
  
  // Fitur Stiker Maker
  if (text.toLowerCase() === '.sticker') {
    if (msg.message.extendedTextMessage?.contextInfo?.quotedMessage?.imageMessage || msg.message.imageMessage) {
      await sock.sendMessage(from, { text: 'Membuat stiker...' });
      try {
        const messageType = msg.message.imageMessage ? msg : msg.message.extendedTextMessage.contextInfo.quotedMessage;
        const stream = await downloadContentFromMessage(messageType, 'image');
        let buffer = Buffer.from([]);
        for await (const chunk of stream) {
          buffer = Buffer.concat([buffer, chunk]);
        }
        await sock.sendMessage(from, { sticker: buffer });
      } catch (error) {
        console.error(error);
        await sock.sendMessage(from, { text: 'Gagal membuat stiker.' });
      }
    } else {
      await sock.sendMessage(from, { text: 'Reply sebuah gambar dengan perintah .sticker' });
    }
    return;
  }
  
  // Fitur Info Cuaca
  if (text.toLowerCase().startsWith('.cuaca')) {
    const city = text.substring(7).trim();
    if (!city) return await sock.sendMessage(from, { text: 'Contoh: .cuaca Jakarta' });
    await sock.sendMessage(from, { text: `🌤️ Mengecek cuaca untuk "${city}"...` });
    try {
      const response = await axios.get(`http://api.weatherapi.com/v1/current.json?key=${process.env.WEATHER_API_KEY}&q=${city}&aqi=no`);
      const data = response.data;
      const reply = `*Cuaca di ${data.location.name}, ${data.location.country}*\n\n` +
        `🌡️ Suhu: ${data.current.temp_c}°C\n` +
        `🤔 Terasa seperti: ${data.current.feelslike_c}°C\n` +
        `📝 Kondisi: ${data.current.condition.text}\n` +
        `💧 Kelembapan: ${data.current.humidity}%\n` +
        `💨 Angin: ${data.current.wind_kph} km/jam`;
      await sock.sendMessage(from, { text: reply });
    } catch (error) {
      await sock.sendMessage(from, { text: 'Gagal mendapatkan data cuaca. Pastikan nama kota dan WEATHER_API_KEY benar.' });
    }
    return;
  }
  
  // Jika perintah tidak dikenali, lempar ke Gemini AI
  console.log(chalk.yellow(`[CHAT BIASA] Dari: ${senderName} | Isi: "${text}"`));
  const response = await getGeminiResponse(text);
  await sock.sendMessage(from, { text: response });
}

module.exports = { handleCommand };