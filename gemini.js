// gemini.js (Final) - Professional & Stable Version
require('dotenv').config();
let GoogleGenerativeAI, HarmCategory, HarmBlockThreshold;
try { const genAIModule = require('@google/genai'); GoogleGenerativeAI = genAIModule.GoogleGenerativeAI; HarmCategory = genAIModule.HarmCategory; HarmBlockThreshold = genAIModule.HarmBlockThreshold; } catch (e) {}
const chalk = require('chalk');

async function getGeminiResponse(prompt) {
    if (!GoogleGenerativeAI || !process.env.GEMINI_API_KEY) { return "🤖 Maaf, sistem AI sedang dalam perbaikan."; }
    try {
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        const modelName = process.env.GEMINI_MODEL || "gemini-1.5-flash-latest";
        const safetySettings = [
            { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
            { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        ];
        const model = genAI.getGenerativeModel({ model: modelName, safetySettings });
        const result = await model.generateContent(prompt);
        return result.response.text();
    } catch (error) { console.error(chalk.red(`[AI-CORE] Error: ${error.message}`)); return "😥 Aduh, AI-nya lagi pusing."; }
}
async function checkGeminiStatus() {
    console.log(chalk.cyan.bold("\n Menganalisis Status API Gemini...\n"));
    if (!GoogleGenerativeAI) { console.error(chalk.red.bold("❌ Gagal: Library '@google/genai' tidak ditemukan.\n-> Jalankan 'Menu 1' dari main.sh\n")); return; }
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey || apiKey.length < 10) { console.error(chalk.red.bold("❌ Gagal: GEMINI_API_KEY tidak valid.\n-> Jalankan 'Menu 2' untuk mengatur API Key.\n")); return; }
    console.log(chalk.green(`✅ Library & API Key ditemukan (berakhiran ...${apiKey.slice(-4)})`));
    const modelName = process.env.GEMINI_MODEL || "gemini-1.5-flash-latest";
    console.log(chalk.cyan(`⏳ Tes koneksi dengan model "${modelName}"...`));
    try {
        const genAI = new GoogleGenerativeAI(apiKey);
        const model = genAI.getGenerativeModel({ model: modelName });
        await model.countTokens("hello");
        console.log(chalk.green.bold("\n✅ KESIMPULAN: KONEKSI BERHASIL!"));
    } catch (error) {
        console.error(chalk.red.bold("\n❌ KESIMPULAN: KONEKSI GAGAL!"));
        if (error.message.includes('API key not valid')) { console.error(chalk.yellow("   -> Penyebab: API Key salah atau tidak aktif.")); }
        else if (error.message.includes('permission')) { console.error(chalk.yellow(`   -> Penyebab: Model "${modelName}" tidak tersedia untuk API Key Anda.`)); }
        else { console.error(chalk.yellow("   -> Penyebab: Server Gemini gangguan atau ada masalah jaringan.")); }
    }
}
module.exports = { getGeminiResponse };
if (require.main === module) { checkGeminiStatus(); }