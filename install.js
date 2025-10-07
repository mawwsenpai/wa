 // install.js
const { execSync } = require('child_process');
const fs = require('fs');

// MENAMBAHKAN 'qrcode-terminal' untuk rendering QR yang lebih baik
const MODULES = ['@whiskeysockets/baileys', '@google/genai', 'dotenv', 'chalk@4', 'qrcode-terminal'];
const ENV_EXAMPLE = `GEMINI_API_KEY=\nGEMINI_MODEL=gemini-1.5-flash\nPHONE_NUMBER=`;

console.log("\n🔥 Memulai Instalasi & Pembaruan Dependencies...");
console.log("------------------------------------------------");

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
    
    console.log("------------------------------------------------");
    console.log("✅ Instalasi Selesai! Semua dependensi sudah siap.");
    
} catch (error) {
    console.error("\n❌ GAGAL menginstal modules!");
    console.error("Pastikan koneksi internet stabil.");
    process.exit(1);
}