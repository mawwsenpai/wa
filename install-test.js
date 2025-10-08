// install-test.js - Installer Lengkap untuk Server Uji Coba Lokal

const { execSync } = require('child_process');
const chalk = require('chalk');

// Dependensi LENGKAP yang dibutuhkan oleh server DAN logika bot (script.js, gemini.js)
const MODULES = [
  // Kebutuhan Server
  'express',
  'socket.io',
  // Kebutuhan Bot
  '@google/genai',
  'dotenv',
  'chalk@4',
  'axios',
  'yt-search',
  'ytdl-core',
  'google-it',
  'figlet',
  'ora'
];

console.log(chalk.cyan.bold("🔥 Memulai Instalasi Lengkap untuk Server Uji Coba..."));
console.log("----------------------------------------------------------");

try {
  console.log(`⏳ Menginstal ${MODULES.length} modul... Ini mungkin butuh beberapa saat.`);
  execSync(`npm install ${MODULES.join(' ')}`, { stdio: 'inherit' });
  console.log(chalk.green("✅ Semua dependensi untuk server uji coba berhasil diinstal!"));
  console.log("----------------------------------------------------------");
} catch (error) {
  console.error(chalk.red(`\n❌ Gagal menginstal dependensi: ${error.message}`));
  process.exit(1);
}