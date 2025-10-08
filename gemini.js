// gemini.js (Final) - Professional & Stable Version

// --- SECTION 1: INISIALISASI & CEK DEPENDENSI ---

require('dotenv').config();

let GoogleGenerativeAI, HarmCategory, HarmBlockThreshold;
try {
  const genAIModule = require('@google/genai');
  GoogleGenerativeAI = genAIModule.GoogleGenerativeAI;
  HarmCategory = genAIModule.HarmCategory;
  HarmBlockThreshold = genAIModule.HarmBlockThreshold;
} catch (error) {
  // Error ini akan ditangani jika skrip dijalankan langsung
}

const chalk = require('chalk');

// --- SECTION 2: FUNGSI INTI AI ---

/**
 * Menghasilkan respons dari API Gemini berdasarkan prompt pengguna.
 * Fungsi ini diekspor dan digunakan oleh script.js.
 * @param {string} prompt - Teks masukan dari pengguna.
 * @returns {Promise<string>} Respons teks dari AI.
 */
async function getGeminiResponse(prompt) {
  if (!GoogleGenerativeAI || !process.env.GEMINI_API_KEY) {
    console.error(chalk.red('[AI-CORE] Error: Library Gemini atau API key tidak dikonfigurasi.'));
    return "🤖 Maaf, sistem AI sedang dalam perbaikan. Silakan coba lagi nanti.";
  }
  
  try {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const modelName = process.env.GEMINI_MODEL || "gemini-1.5-flash-latest";
    const safetySettings = [
      { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
      { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
      { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
      { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
    ];
    
    const model = genAI.getGenerativeModel({ model: modelName, safetySettings });
    const result = await model.generateContent(prompt);
    
    return result.response.text();
  } catch (error) {
    console.error(chalk.red(`[AI-CORE] Gemini API Error: ${error.message}`));
    return "😥 Aduh, AI-nya lagi pusing. Coba tanya lagi beberapa saat ya.";
  }
}

// --- SECTION 3: FUNGSI CEK STATUS MANDIRI ---

/**
 * Melakukan pemeriksaan diagnostik pada koneksi API Gemini.
 * Fungsi ini hanya dijalankan saat skrip dieksekusi langsung dari command line.
 */
async function checkGeminiStatus() {
  console.log(chalk.cyan("======================================="));
  console.log(chalk.cyan.bold(" Menganalisis Status API Gemini..."));
  console.log(chalk.cyan("=======================================\n"));
  
  if (!GoogleGenerativeAI) {
    console.error(chalk.red.bold("❌ ANALISIS GAGAL: Library '@google/genai' tidak ditemukan."));
    console.error(chalk.yellow("-> Jalankan 'Menu 1 (Instalasi Bersih)' dari main.sh\n"));
    return;
  }
  console.log(chalk.green("✅ Library '@google/genai' berhasil dimuat."));
  
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey.length < 10) {
    console.error(chalk.red.bold("\n❌ ANALISIS GAGAL: GEMINI_API_KEY tidak valid."));
    console.error(chalk.yellow("-> Pastikan file '.env' ada dan API Key diisi melalui 'Menu 2'.\n"));
    return;
  }
  console.log(chalk.green("✅ File '.env' dan API Key ditemukan."));
  console.log(`   (Menggunakan Key yang berakhiran: ...${apiKey.slice(-4)})`);
  
  const modelName = process.env.GEMINI_MODEL || "gemini-1.5-flash-latest";
  console.log(chalk.cyan(`\n⏳ Melakukan tes koneksi ke server Google dengan model "${modelName}"...`));
  
  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: modelName });
    await model.countTokens("hello");
    console.log(chalk.green.bold("\n✅ KESIMPULAN: KONEKSI BERHASIL!"));
    console.log(chalk.white("   Server Gemini merespons dengan baik menggunakan konfigurasi Anda."));
  } catch (error) {
    console.error(chalk.red.bold("\n❌ KESIMPULAN: KONEKSI GAGAL!"));
    if (error.message.includes('API key not valid')) {
      console.error(chalk.yellow("   -> Penyebab: API Key yang Anda gunakan salah atau tidak aktif."));
    } else if (error.message.includes('permission')) {
      console.error(chalk.yellow(`   -> Penyebab: Model "${modelName}" tidak tersedia untuk API Key Anda.`));
    } else {
      console.error(chalk.yellow("   -> Penyebab: Server Gemini gangguan atau ada masalah jaringan."));
    }
  } finally {
    console.log(chalk.cyan("\n======================================="));
  }
}

// --- SECTION 4: EKSPOR & LOGIKA EKSEKUSI ---
module.exports = { getGeminiResponse };

if (require.main === module) {
  checkGeminiStatus();
}