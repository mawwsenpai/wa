// install.js - Versi 2.0 - Installer Komprehensif

const { execSync } = require('child_process');
const fs = require('fs');

// Daftar modul yang lebih lengkap untuk fitur masa depan
const MODULES = [
    // Kebutuhan Inti
    '@whiskeysockets/baileys',
    '@google/genai',
    'dotenv',
    'chalk@4',
    // Untuk Tampilan & UI
    'qrcode-terminal',
    'figlet',
    'ora',
    // Untuk Fitur Tambahan
    'yt-search', // Untuk mencari video YouTube
    'ytdl-core', // Untuk mengunduh audio/video dari YouTube
    'google-it', // Untuk melakukan pencarian Google
    'axios' // Untuk request HTTP (misal: cek IP, info cuaca, dll)
];

const ENV_EXAMPLE = `GEMINI_API_KEY=\nGEMINI_MODEL=gemini-1.5-flash\nPHONE_NUMBER=`;

// Fungsi untuk menjalankan perintah dengan output yang bersih
const runCommand = (command) => {
    try {
        execSync(command, { stdio: 'inherit' });
    } catch (error) {
        console.error(`❌ Gagal menjalankan perintah: ${command}`);
        process.exit(1);
    }
};

(async () => {
    console.log(chalk.cyan.bold("🔥 Memulai Proses Instalasi & Penyiapan Bot..."));
    console.log("-------------------------------------------------");
    
    // Impor ora secara dinamis karena dia ESM
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
            spinner.succeed('File .env berhasil dibuat.');
        } else {
            spinner.succeed('File .env sudah ada.');
        }
        
        console.log("-------------------------------------------------");
        console.log(chalk.green.bold("✅ Penyiapan Selesai! Fondasi bot Anda sudah siap."));
        console.log(chalk.yellow("Lanjutkan ke Menu 2 untuk konfigurasi."));
        
    } catch (error) {
        spinner.fail(chalk.red(`Instalasi Gagal: ${error.message}`));
        process.exit(1);
    }
})();