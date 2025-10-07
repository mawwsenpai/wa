// install.js
const { execSync } = require('child_process');
const fs = require('fs');

const MODULES = ['@whiskeysockets/baileys', '@google/genai', 'dotenv', 'chalk'];
const ENV_EXAMPLE = `GEMINI_API_KEY=\nGEMINI_MODEL=gemini-1.5-flash\nPHONE_NUMBER=`;

console.log("\n🔥 Memulai Instalasi Dependencies...");
console.log("-------------------------------------");

try {
    if (!fs.existsSync('package.json')) {
        console.log("⏳ package.json tidak ditemukan, membuat file baru...");
        execSync('npm init -y', { stdio: 'pipe' });
    }
    
    console.log(`⏳ Menginstal modul: ${MODULES.join(', ')}...`);
    execSync(`npm install ${MODULES.join(' ')}`, { stdio: 'inherit' });
    
    if (!fs.existsSync('.env')) {
        console.log("⏳ Membuat file konfigurasi .env...");
        fs.writeFileSync('.env', ENV_EXAMPLE);
    }
    
    console.log("-------------------------------------");
    console.log("✅ Instalasi Selesai! Lanjutkan ke Menu 2.");
    
} catch (error) {
    console.error("\n❌ GAGAL menginstal modules!");
    console.error("Pastikan koneksi internet stabil.");
    process.exit(1);
}