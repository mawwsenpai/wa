// script.js - Pusat Komando untuk Semua Perintah Bot

const fs = require('fs');
const chalk = require('chalk');

// --- DATABASE & STATE MANAGEMENT SEDERHANA ---
const DB_FILE = './users.json';
let userState = {}; // Untuk mengingat status setiap user
let users = {}; // Untuk menyimpan data user dari file JSON

const loadDatabase = () => {
  if (fs.existsSync(DB_FILE)) {
    const data = fs.readFileSync(DB_FILE);
    users = JSON.parse(data);
  }
};

const saveDatabase = () => {
  fs.writeFileSync(DB_FILE, JSON.stringify(users, null, 2));
};

// Panggil sekali saat file di-load
loadDatabase();

// --- FUNGSI UTAMA UNTUK MENANGANI PERINTAH ---
async function handleCommand(sock, from, text, senderName) {
  // Muat database setiap ada perintah untuk memastikan data selalu update
  loadDatabase();
  
  const currentState = userState[from];
  
  // Logika untuk pendaftaran dan menu
  if (text.toLowerCase() === '.menu') {
    await sock.sendMessage(from, { text: "Silakan pilih:\n\n- Autentikasi\n- Free\n- Prem" });
    userState[from] = 'menunggu_pilihan_awal';
    return;
  }
  
  if (currentState === 'menunggu_pilihan_awal' && text.toLowerCase() === 'free') {
    await sock.sendMessage(from, { text: "Anda memilih mode Free.\n\nSilakan masukkan Username Anda:" });
    userState[from] = 'memasukkan_username';
    return;
  }
  
  if (currentState === 'memasukkan_username') {
    const username = text;
    users[from] = { username: username };
    await sock.sendMessage(from, { text: `Username "${username}" diterima.\n\nSekarang masukkan Sandi Anda:` });
    userState[from] = 'memasukkan_sandi';
    return;
  }
  
  if (currentState === 'memasukkan_sandi') {
    const sandi = text;
    users[from].sandi = sandi;
    users[from].status = 'Free';
    
    saveDatabase();
    delete userState[from];
    
    const welcomeMessage = `🎉 Registrasi Berhasil! 🎉\n\nHallo ${users[from].username}!\nStatus: ${users[from].status}\nIP: Local\n\n--- MENU ---\n.google [apa yang dicari]\n.play [judul lagu]`;
    await sock.sendMessage(from, { text: welcomeMessage });
    return;
  }
  
  // Tambahkan perintah lain di sini, contoh:
  if (text.toLowerCase().startsWith('.google')) {
    const query = text.substring(8);
    await sock.sendMessage(from, { text: `Anda mencari di Google: "${query}"... (Fitur ini belum diimplementasikan)` });
    return;
  }
  
  // Jika perintah tidak dikenali
  await sock.sendMessage(from, { text: `Maaf, perintah "${text}" tidak dikenali.` });
}

// Ekspor fungsi agar bisa dipanggil dari main.js
module.exports = { handleCommand };