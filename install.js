// install.js - Versi 2.1 - Installer dengan template .env lengkap

const { execSync } = require('child_process');
const fs = require('fs');
const chalk = require('chalk');

const MODULES = [
    '@whiskeysockets/baileys', '@google/genai', 'dotenv', 'chalk@4',
    'qrcode-terminal', 'figlet', 'ora', 'yt-search', 'ytdl-core',
    'google-it', 'axios'
];

// TEMPLATE .ENV SEKARANG LENGKAP DENGAN SEMUA KEBUTUHAN API KEY
const ENV_EXAMPLE = `# --- Konfigurasi Utama ---
GEMINI_API_KEY=
GEMINI_MODEL=gemini-1.5-flash
PHONE_NUMBER=

# --- Kunci API untuk Fitur Tambahan ---
UNSPLASH_API_KEY=
WEATHER_API_KEY=
`;

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
        
        spinner.start(`Menginstal ${MODULES.length} modul...`);
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
        console.log(chalk.green.bold("✅ Penyiapan Selesai! Fondasi bot Anda sudah siap."));
        console.log(chalk.yellow("Lanjutkan ke Menu 2 untuk konfigurasi."));
        
    } catch (error) {
        spinner.fail(chalk.red(`Instalasi Gagal: ${error.message}`));
        process.exit(1);
    }
})();