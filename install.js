// install.js - Versi 5.0 - Dengan Analisis & Verifikasi

const { execSync } = require('child_process');
const fs = require('fs');

// Fungsi untuk log dengan warna (tanpa library eksternal)
const log = {
    info: (msg) => console.log(`\x1b[36m${msg}\x1b[0m`), // Cyan
    success: (msg) => console.log(`\x1b[32m${msg}\x1b[0m`), // Green
    warn: (msg) => console.log(`\x1b[33m${msg}\x1b[0m`), // Yellow
    error: (msg) => console.error(`\x1b[31m${msg}\x1b[0m`), // Red
};

const MODULES = [
    '@whiskeysockets/baileys', '@google/genai@0.2.0', 'dotenv', 'chalk@4',
    'express', 'socket.io', 'axios', 'yt-search', 'ytdl-core',
    'google-it', 'figlet', 'ora', 'qrcode-terminal'
];

const ENV_EXAMPLE = `# --- Konfigurasi Utama ---\nGEMINI_API_KEY=\nGEMINI_MODEL=gemini-1.5-flash\nPHONE_NUMBER=\n\n# --- Kunci API untuk Fitur Tambahan ---\nUNSPLASH_API_KEY=\nWEATHER_API_KEY=\n`;

// Fungsi utama
(async () => {
    log.info("🔥 Memulai Proses Instalasi dengan Analisis Detail...");
    console.log("----------------------------------------------------------");
    
    try {
        // --- LANGKAH 1: PEMBERSIHAN OTOMATIS ---
        log.warn("--- Langkah 1: Membersihkan Instalasi Lama ---");
        if (fs.existsSync('node_modules')) {
            console.log("⏳ Menghapus folder node_modules...");
            execSync('rm -rf node_modules');
            log.success("✅ Folder node_modules berhasil dihapus.");
        }
        if (fs.existsSync('package-lock.json')) {
            console.log("⏳ Menghapus file package-lock.json...");
            execSync('rm package-lock.json');
            log.success("✅ File package-lock.json berhasil dihapus.");
        }
        console.log("Pembersihan selesai, memastikan instalasi dari nol.");
        console.log("----------------------------------------------------------");
        
        
        // --- LANGKAH 2: INSTALASI MODUL ---
        log.warn("--- Langkah 2: Menginstal Semua Modul yang Dibutuhkan ---");
        console.log(`⏳ Menginstal ${MODULES.length} modul... Ini mungkin butuh beberapa saat.`);
        execSync(`npm install ${MODULES.join(' ')}`, { stdio: 'inherit' });
        log.success("✅ Proses instalasi modul selesai.");
        console.log("----------------------------------------------------------");
        
        
        // --- LANGKAH 3: VERIFIKASI & ANALISIS HASIL ---
        log.warn("--- Langkah 3: Menganalisis Hasil Instalasi ---");
        let allModulesFound = true;
        const modulesToVerify = [
            '@google/genai',
            '@whiskeysockets/baileys',
            'express',
            'socket.io',
            'axios',
            'yt-search'
        ];
        
        console.log("Memeriksa keberadaan file library penting...");
        modulesToVerify.forEach(moduleName => {
            const path = `./node_modules/${moduleName}`;
            if (fs.existsSync(path)) {
                log.success(`  ✅ Ditemukan: ${moduleName}`);
            } else {
                log.error(`  ❌ TIDAK DITEMUKAN: ${moduleName}`);
                allModulesFound = false;
            }
        });
        
        console.log("----------------------------------------------------------");
        
        if (allModulesFound) {
            log.success("✅ ANALISIS BERHASIL: Semua library penting berhasil diinstal.");
        } else {
            log.error("❌ ANALISIS GAGAL: Beberapa library penting tidak ditemukan setelah instalasi.");
            log.warn("Ini menandakan ada masalah dengan NPM atau Termux Anda. Coba restart Termux dan jalankan lagi.");
        }
        
    } catch (error) {
        log.error(`\n❌ Proses Gagal Total: ${error.message}`);
        process.exit(1);
    }
})();