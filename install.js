// install.js - Versi 2.4 - Fokus pada Dependensi Bot Utama

const { execSync } = require('child_process');
const fs = require('fs');
const chalk = require('chalk');

// Daftar modul HANYA untuk bot WhatsApp
const MODULES = [
    '@whiskeysockets/baileys', '@google/genai', 'dotenv', 'chalk@4',
    'qrcode-terminal', 'figlet', 'ora', 'yt-search', 'ytdl-core',
    'google-it', 'axios'
];

const ENV_EXAMPLE = `# --- Konfigurasi Utama ---\nGEMINI_API_KEY=\nGEMINI_MODEL=gemini-1.5-flash\nPHONE_NUMBER=\n\n# --- Kunci API untuk Fitur Tambahan ---\nUNSPLASH_API_KEY=\nWEATHER_API_KEY=\n`;

(async () => {
    console.log(chalk.cyan.bold("🔥 Memulai Instalasi Dependensi untuk Bot Utama..."));
    console.log("-------------------------------------------------");
    try {
        console.log('⏳ Mengecek package.json...');
        if (!fs.existsSync('package.json')) {
            execSync('npm init -y', { stdio: 'pipe' });
            console.log('✅ package.json berhasil dibuat.');
        } else {
            console.log('✅ package.json sudah ada.');
        }
        console.log(`⏳ Menginstal ${MODULES.length} modul bot utama...`);
        execSync(`npm install ${MODULES.join(' ')}`, { stdio: 'inherit' });
        console.log(chalk.green('✅ Semua modul bot utama berhasil diinstal!'));
        console.log("-------------------------------------------------");
        console.log(chalk.green.bold("✅ Penyiapan Bot Utama Selesai!"));
    } catch (error) {
        console.log(chalk.red(`\n❌ Instalasi Gagal: ${error.message}`));
        process.exit(1);
    }
})();