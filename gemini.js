// gemini.js (Final) - Professional & Stable Version

// --- SECTION 1: INITIALIZATION & DEPENDENCY CHECK ---

require('dotenv').config();
const path = require('path');

let GoogleGenerativeAI, HarmCategory, HarmBlockThreshold;
try {
  // Dynamically import the module to handle potential errors gracefully
  const genAIModule = require('@google/genai');
  GoogleGenerativeAI = genAIModule.GoogleGenerativeAI;
  HarmCategory = genAIModule.HarmCategory;
  HarmBlockThreshold = genAIModule.HarmBlockThreshold;
} catch (error) {
  // This error will be caught and explained if the script is run directly
}

const chalk = require('chalk');

// --- SECTION 2: CORE AI FUNCTION ---

/**
 * Generates a response from the Gemini API based on a user's prompt.
 * This function is exported and used by other parts of the bot (e.g., script.js).
 * @param {string} prompt - The user's input text.
 * @returns {Promise<string>} The AI's text response.
 */
async function getGeminiResponse(prompt) {
  // Pre-flight check before making an API call
  if (!GoogleGenerativeAI || !process.env.GEMINI_API_KEY) {
    console.error(chalk.red('[AI-CORE] Error: Gemini library or API key is not configured.'));
    return "🤖 Maaf, sistem AI sedang dalam perbaikan. Silakan coba lagi nanti.";
  }
  
  try {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const modelName = process.env.GEMINI_MODEL || "gemini-1.5-flash-latest";
    
    // Advanced safety settings to reduce the chance of the AI refusing to answer
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

// --- SECTION 3: STANDALONE STATUS CHECK FUNCTION ---

/**
 * Performs a diagnostic check on the Gemini API connection.
 * This function is only executed when the script is run directly from the command line.
 */
async function checkGeminiStatus() {
  console.log(chalk.cyan("======================================="));
  console.log(chalk.cyan.bold(" Menganalisis Status API Gemini..."));
  console.log(chalk.cyan("=======================================\n"));
  
  // 1. Check if the library was loaded
  if (!GoogleGenerativeAI) {
    console.error(chalk.red.bold("❌ ANALISIS GAGAL: Library '@google/genai' tidak ditemukan."));
    console.error(chalk.yellow("-> Jalankan 'Menu 1 (Install / Update Modules)' dari main.sh\n"));
    return;
  }
  console.log(chalk.green("✅ Library '@google/genai' berhasil dimuat."));
  
  // 2. Check for the .env file and API Key
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey.length < 10) {
    console.error(chalk.red.bold("\n❌ ANALISIS GAGAL: GEMINI_API_KEY tidak valid."));
    console.error(chalk.yellow("-> Pastikan file '.env' ada dan API Key sudah diisi dengan benar melalui 'Menu 2'.\n"));
    return;
  }
  console.log(chalk.green("✅ File '.env' dan API Key ditemukan."));
  console.log(`   (Menggunakan Key yang berakhiran: ...${apiKey.slice(-4)})`);
  
  // 3. Perform a live API call test
  const modelName = process.env.GEMINI_MODEL || "gemini-1.5-flash-latest";
  console.log(chalk.cyan(`\n⏳ Melakukan tes koneksi ke server Google dengan model "${modelName}"...`));
  
  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: modelName });
    await model.countTokens("hello"); // A lightweight call to test connectivity
    
    console.log(chalk.green.bold("\n✅ KESIMPULAN: KONEKSI BERHASIL!"));
    console.log(chalk.white("   Server Gemini merespons dengan baik menggunakan konfigurasi Anda."));
  } catch (error) {
    console.error(chalk.red.bold("\n❌ KESIMPULAN: KONEKSI GAGAL!"));
    if (error.message.includes('API key not valid')) {
      console.error(chalk.yellow("   -> Penyebab: API Key yang Anda gunakan salah atau sudah tidak aktif."));
    } else if (error.message.includes('permission')) {
      console.error(chalk.yellow(`   -> Penyebab: Model "${modelName}" tidak tersedia untuk API Key Anda.`));
    } else {
      console.error(chalk.yellow("   -> Penyebab: Server Gemini sedang gangguan atau ada masalah jaringan di HP Anda."));
    }
  } finally {
    console.log(chalk.cyan("\n======================================="));
  }
}

// --- SECTION 4: EXPORT & DIRECT EXECUTION LOGIC ---

// Export the core function for other scripts to use
module.exports = { getGeminiResponse };

// This special block checks if the file is being run directly.
// If yes (`node gemini.js`), it runs the status check.
// If no (being `require`d), it does nothing.
if (require.main === module) {
  checkGeminiStatus();
}