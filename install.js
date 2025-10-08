// install.js - Versi 2.3 - Perbaikan error 'ora'

const { execSync } = require('child_process');
const fs = require('fs');
const chalk = require('chalk');

// Daftar modul tetap lengkap
const MODULES = [
    'express', 'socket.io', '@whiskeysockets/baileys', '@google/genai',
    'dotenv', 'chalk@4', 'qrcode-terminal', 'figlet', 'ora', 'yt-search',
    'ytdl-core', 'google-it', 'axios'
];

const ENV_EXAMPLE = `# --- Konfigurasi Utama ---\nGEMINI_API_KEY=\nGEMINI_MODEL=gemini-1.5-flash\nPHONE_NUMBER=\n\n# --- Kunci API untuk Fitur Tambahan ---\nUNSPLASH_API_KEY=\nWEATHER_API_KEY=\n`;

const runCommand = (command) => {
    try {
        execSync(command, { stdio: 'inherit' });
    } catch (error) {
        console.error(`❌ Gagal menjalankan perintah: ${command}`);
        process.exit(1);
    }
};

// Menggunakan async () agar tetap konsisten, tapi tanpa import ora
(async () => {
    console.log(chalk.cyan.bold("🔥 Memulai Proses Instalasi & Penyiapan Bot..."));
    console.log("-------------------------------------------------");
    
    try {
        console.log('⏳ Mengecek package.json...');
        if (!fs.existsSync('package.json')) {
            execSync('npm init -y', { stdio: 'pipe' });
            console.log('✅ package.json berhasil dibuat.');
        } else {
            console.log('✅ package.json sudah ada.');
        }
        
        console.log(`⏳ Menginstal ${MODULES.length} modul... Ini mungkin butuh beberapa saat.`);
        runCommand(`npm install ${MODULES.join(' ')}`);
        console.log(chalk.green('✅ Semua modul Node.js berhasil diinstal!'));
        
        console.log('⏳ Mengecek file konfigurasi .env...');
        if (!fs.existsSync('.env')) {
            fs.writeFileSync('.env', ENV_EXAMPLE);
            console.log('✅ File .env (dengan template lengkap) berhasil dibuat.');
        } else {
            console.log('✅ File .env sudah ada.');
        }
        
        console.log("-------------------------------------------------");
        console.log(chalk.green.bold("✅ Penyiapan Selesai!"));
        console.log(chalk.yellow("Lanjutkan ke Menu 2 untuk konfigurasi jika diperlukan."));
        
    } catch (error) {
        console.log(chalk.red(`\n❌ Instalasi Gagal: ${error.message}`));
        process.exit(1);
    }
})();