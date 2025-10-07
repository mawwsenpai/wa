// install-config.js
const { execSync } = require('child_process');
const fs = require('fs');

const MODULES_TO_INSTALL = [
    '@whiskeysockets/baileys',
    '@google/genai'
];

console.log("\n🔥 [INSTALL] Memulai Instalasi Dependencies Node.js...");
console.log("-------------------------------------------------");

try {
    // 1. Cek apakah package.json ada
    if (!fs.existsSync('package.json')) {
        console.log("⏳ [NPM] package.json tidak ditemukan. Membuat sekarang...");
        execSync('npm init -y', { stdio: 'inherit' });
    }
    
    // 2. Hapus cache lama (untuk fix error MODULE_NOT_FOUND)
    console.log("⏳ [NPM] Membersihkan cache lama (node_modules)...");
    execSync('rm -rf node_modules package-lock.json', { stdio: 'inherit' });
    
    // 3. Install library utama
    console.log("⏳ [NPM] Menginstal modules utama: " + MODULES_TO_INSTALL.join(', ') + "...");
    execSync(`npm install ${MODULES_TO_INSTALL.join(' ')}`, { stdio: 'inherit' });
    
    console.log("-------------------------------------------------");
    console.log("✅ [INSTALL] Instalasi Modules Selesai!");
    console.log("Sekarang kamu bisa lanjutkan ke Menu 2 (Konfigurasi Nomor WA).");
    
} catch (error) {
    console.log("-------------------------------------------------");
    console.error("❌ [INSTALL] GAGAL menginstal modules!");
    console.error("Pastikan Node.js sudah terinstal dan koneksi internet kamu stabil.");
    process.exit(1);
}