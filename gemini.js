// gemini.js (Disempurnakan) - Professional & Stable Version
require('dotenv').config();
const chalk = require('chalk');

// Mengimpor modul dengan aman
let GoogleGenerativeAI, HarmCategory, HarmBlockThreshold;
try {
    const genAIModule = require('@google/genai');
    GoogleGenerativeAI = genAIModule.GoogleGenerativeAI;
    HarmCategory = genAIModule.HarmCategory;
    HarmBlockThreshold = genAIModule.HarmBlockThreshold;
} catch (e) {
    // Biarkan kosong, akan ditangani nanti jika library tidak ada
}

async function getGeminiResponse(prompt) {
    if (!GoogleGenerativeAI) {
        return "🤖 Maaf, library AI (@google/genai) tidak ditemukan. Coba jalankan Menu 1.";
    }
    if (!process.env.GEMINI_API_KEY) {
        return "🤖 Maaf, Kunci API Gemini belum diatur. Coba jalankan Menu 2.";
    }

    try {
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        const modelName = process.env.GEMINI_MODEL || "gemini-1.5-flash-latest";
        
        // Pengaturan keamanan yang lebih lengkap
        const safetySettings = [
            { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
            { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
            { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
            { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        ];

        const model = genAI.getGenerativeModel({ model: modelName, safetySettings });
        const result = await model.generateContent(prompt);
        const response = result.response;

        // PENYEMPURNAAN: Cek jika respons diblokir oleh filter keamanan
        if (!response || !response.text) {
             return "😥 Aduh, respons dari AI diblokir karena kebijakan keamanan. Coba ganti pertanyaannya ya.";
        }

        return response.text();

    } catch (error) {
        console.error(chalk.red(`[AI-CORE] Terjadi error: ${error.message}`));
        return "😥 Aduh, AI-nya lagi pusing nih. Coba tanya lagi nanti.";
    }
}

async function checkGeminiStatus() {
    console.log(chalk.cyan.bold("\n Menganalisis Status API Gemini...\n"));
    if (!GoogleGenerativeAI) {
        console.error(chalk.red.bold("❌ Gagal: Library '@google/genai' tidak ditemukan.\n-> Jalankan 'Menu 1' dari skrip utama.\n"));
        return;
    }
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey || apiKey.length < 10) {
        console.error(chalk.red.bold("❌ Gagal: GEMINI_API_KEY kosong atau tidak valid.\n-> Jalankan 'Menu 2' untuk mengatur API Key.\n"));
        return;
    }
    
    console.log(chalk.green(`✅ Library & API Key ditemukan (berakhiran ...${apiKey.slice(-4)})`));
    const modelName = process.env.GEMINI_MODEL || "gemini-1.5-flash-latest";
    console.log(chalk.cyan(`⏳ Melakukan tes koneksi dengan model "${modelName}"...`));

    try {
        const genAI = new GoogleGenerativeAI(apiKey);
        const model = genAI.getGenerativeModel({ model: modelName });
        // Menggunakan countTokens adalah cara ringan untuk mengetes API
        await model.countTokens("hello");
        console.log(chalk.green.bold("\n✅ KESIMPULAN: KONEKSI API GEMINI BERHASIL!"));
    } catch (error) {
        console.error(chalk.red.bold("\n❌ KESIMPULAN: KONEKSI GAGAL!"));
        if (error.message.includes('API key not valid')) {
            console.error(chalk.yellow("   -> Penyebab: API Key yang kamu masukkan salah atau sudah tidak aktif."));
        } else if (error.message.includes('permission') || error.message.includes('not found')) {
            console.error(chalk.yellow(`   -> Penyebab: Model "${modelName}" tidak tersedia atau tidak diizinkan untuk API Key Anda.`));
        } else {
            console.error(chalk.yellow(`   -> Penyebab: Kemungkinan server Gemini sedang gangguan atau ada masalah jaringan di tempatmu.`));
        }
    }
}

// Ekspor fungsi utama dan jalankan status check jika file ini dieksekusi langsung
module.exports = { getGeminiResponse };
if (require.main === module) {
    checkGeminiStatus();
}
