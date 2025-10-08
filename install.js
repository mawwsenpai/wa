// install.js - Versi 2.2 - Menambahkan Express & Socket.IO

const { execSync } = require('child_process');
const fs = require('fs');
const chalk = require('chalk');

const MODULES = [
    // Kebutuhan Inti Bot & Server
    '@whiskeysockets/baileys',
    '@google/genai',
    'dotenv',
    'chalk@4',
    'express', // <-- DITAMBAHKAN
    'socket.io', // <-- DITAMBAHKAN
    // Untuk Tampilan & UI
    'qrcode-terminal',
    'figlet',
    'ora',
    // Untuk Fitur Tambahan
    'yt-search',
    'ytdl-core',
    'google-it',
    'axios'
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

(async () => {
    console.log(chalk.cyan.bold("🔥 Memulai Proses Instalasi & Pembaruan Bot..."));
    console.log("-------------------------------------------------");
    const { default: ora } = await import('ora');
    const spinner = ora({ text: 'Mempersiapkan...', spinner: 'dots' });
    
    try {
        spinner.start('Mengecek package.json...');
        if (!fs.existsSync('package.json')) {
            execSync('npm init -y', { stdio: 'pipe' });
            spinner.succeed('package.json berhasil dibuat.');
        } else {
            spinner.succeed('package.json sudah ada.');
        }
        
        spinner.start(`Menginstal ${MODULES.length} modul... Ini mungkin butuh beberapa saat.`);
        runCommand(`npm install ${MODULES.join(' ')}`);
        spinner.succeed(chalk.green('Semua modul Node.js berhasil diinstal!'));
        
        spinner.start('Mengecek file konfigurasi .env...');
        if (!fs.existsSync('.env')) {
            fs.writeFileSync('.env', ENV_EXAMPLE);
            spinner.succeed('File .env (dengan template lengkap) berhasil dibuat.');
        } else {
            spinner.succeed('File .env sudah ada.');
        }
        
        console.log("-------------------------------------------------");
        console.log(chalk.green.bold("✅ Penyiapan Selesai!"));
        
    } catch (error) {
        spinner.fail(chalk.red(`Instalasi Gagal: ${error.message}`));
        process.exit(1);
    }
})();