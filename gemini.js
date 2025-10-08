// gemini.js - Versi 3.0 - Otak AI & Pengecek Status

require('dotenv').config();
const chalk = require('chalk');

// --- BAGIAN 1: FUNGSI-FUNGSI UTAMA ---

let GoogleGenerativeAI;
try {
  const genAI_module = require("@google/genai");
  GoogleGenerativeAI = genAI_module.GoogleGenerativeAI;
} catch (e) {
  // Error ini akan ditangani oleh checkGeminiStatus jika dijalankan langsung
}

/**
 * Fungsi untuk mendapatkan balasan chat dari AI.
 * Dipanggil oleh script.js.
 */
async function getGeminiResponse(prompt) {
  if (!process.env.GEMINI_API_KEY || !GoogleGenerativeAI) {
    return "Maaf, konfigurasi API Gemini belum diatur atau library gagal dimuat.";
  }
  try {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: process.env.GEMINI_MODEL || "gemini-1.5-flash" });
    const result = await model.generateContent(prompt);
    return result.response.text();
  } catch (error) {
    console.error(chalk.red(`[AI] Error: ${error.message}`));
    return "Maaf, AI sedang istirahat sejenak. 😥";
  }
}

/**
 * Fungsi untuk mengecek status koneksi ke API Gemini.
 * Dipanggil saat file ini dieksekusi langsung.
 */
async function checkGeminiStatus() {
  console.log(chalk.cyan("======================================="));
  console.log(chalk.cyan.bold(" Menganalisis Status Koneksi API Gemini..."));
  console.log(chalk.cyan("=======================================\n"));
  
  if (!GoogleGenerativeAI) {
    console.error(chalk.red.bold("❌ Gagal memuat library '@google/genai'."));
    console.error(chalk.yellow("Jalankan Menu 1 (Install / Update Modules) dari main.sh"));
    console.log(chalk.cyan("\n======================================="));
    process.exit(1);
  }
  
  const apiKey = process.env.GEMINI_API_KEY;
  const modelName = process.env.GEMINI_MODEL || "gemini-1.5-flash";
  
  if (!apiKey || apiKey.length < 10) {
    console.error(chalk.red.bold("❌ STATUS: GAGAL"));
    console.error(chalk.yellow("Penyebab: GEMINI_API_KEY tidak valid atau kosong di file .env"));
    console.log(chalk.cyan("\nJalankan Menu 2 untuk mengatur API Key Anda."));
    return;
  }
  
  console.log(`🔑 Menggunakan API Key: ...${apiKey.slice(-4)}`);
  console.log(`🤖 Menggunakan Model: ${modelName}\n`);
  console.log("⏳ Mencoba melakukan panggilan tes ke server Gemini...");
  
  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: modelName });
    await model.countTokens("test");
    console.log(chalk.green.bold("\n✅ STATUS: KONEKSI BERHASIL"));
    console.log(chalk.green("Server Gemini merespons dengan baik."));
  } catch (error) {
    console.error(chalk.red.bold("\n❌ STATUS: KONEKSI GAGAL"));
    if (error.message.includes('API key not valid')) {
      console.error(chalk.yellow("Penyebab: API Key yang Anda masukkan salah."));
    } else if (error.message.includes('permission')) {
      console.error(chalk.yellow(`Penyebab: Model '${modelName}' mungkin tidak tersedia untuk Anda.`));
    } else {
      console.error(chalk.yellow(`Penyebab: Server Gemini sedang gangguan atau ada masalah jaringan.`));
      console.error(chalk.gray(`Detail Error: ${error.message}`));
    }
  } finally {
    console.log(chalk.cyan("\n======================================="));
  }
}

// --- BAGIAN 2: EKSPOR & LOGIKA PINTAR ---

// Ekspor fungsi getGeminiResponse agar bisa digunakan oleh script.js
module.exports = { getGeminiResponse };

// "Logika Pintar": Cek apakah file ini dijalankan langsung atau dipanggil.
// Jika dijalankan langsung (node gemini.js), maka jalankan checkGeminiStatus.
if (require.main === module) {
  checkGeminiStatus();
}