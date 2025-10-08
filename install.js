// install.js - Versi 4.1 - Anti-Gagal (Tanpa dependensi eksternal)

const { execSync } = require('child_process');
const fs = require('fs');

// Daftar LENGKAP semua modul yang dibutuhkan oleh proyek ini
const MODULES = [
    // Kebutuhan Server & Bot
    'express',
    'socket.io',
    '@whiskeysockets/baileys',
    '@google/genai@0.2.0', // Versi lama yang kompatibel
    'dotenv',
    'chalk@4', // Tetap diinstal untuk skrip lain
    'axios',
    'yt-search',
    'ytdl-core',
    'google-it',
    'figlet',
    'ora',
    'qrcode-terminal'
];

const ENV_EXAMPLE = `# --- Konfigurasi Utama ---\nGEMINI_API_KEY=\nGEMINI_MODEL=gemini-1.5-flash\nPHONE_NUMBER=\n\n# --- Kunci API untuk Fitur Tambahan ---\nUNSPLASH_API_KEY=\nWEATHER_API_KEY=\n`;

// --- MULAI PROSES INSTALASI ---
console.log("🔥 Memulai Proses Instalasi & Penyiapan Universal...");
console.log("----------------------------------------------------------");

try {
    console.log('⏳ Mengecek package.json...');
    if (!fs.existsSync('package.json')) {
        execSync('npm init -y', { stdio: 'pipe' });
        console.log('✅ package.json berhasil dibuat.');
    } else {
        console.log('✅ package.json sudah ada.');
    }
    
    console.log(`⏳ Menginstal ${MODULES.length} modul... Ini mungkin butuh beberapa saat.`);
    execSync(`npm install ${MODULES.join(' ')}`, { stdio: 'inherit' });
    console.log('✅ Semua modul berhasil diinstal!');
    
    console.log('⏳ Mengecek file konfigurasi .env...');
    if (!fs.existsSync('.env')) {
        fs.writeFileSync('.env', ENV_EXAMPLE);
        console.log('✅ File .env (dengan template lengkap) berhasil dibuat.');
    } else {
        console.log('✅ File .env sudah ada.');
    }
    
    console.log("----------------------------------------------------------");
    console.log("✅ Penyiapan Selesai!");
    
} catch (error) {
    console.error(`\n❌ Gagal menginstal dependensi: ${error.message}`);
    process.exit(1);
}