// gemini.js - Versi 2.0 - Perbaikan Final untuk Kompatibilitas

require('dotenv').config();

// --- PERUBAHAN DI SINI ---
// Kode Lama: const { GoogleGenerativeAI } = require("@google/genai");
// Kita ubah menjadi dua baris agar lebih aman
const genAI_module = require("@google/genai");
const GoogleGenerativeAI = genAI_module.GoogleGenerativeAI;
// --- AKHIR PERUBAHAN ---

const chalk = require('chalk');

// Validasi API Key
if (!process.env.GEMINI_API_KEY) {
  throw new Error("GEMINI_API_KEY tidak ditemukan di file .env");
}

// Cek apakah GoogleGenerativeAI berhasil dimuat
if (typeof GoogleGenerativeAI !== 'function') {
  throw new TypeError("Gagal memuat GoogleGenerativeAI. Pastikan library @google/genai terinstal dengan benar.");
}

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: process.env.GEMINI_MODEL || "gemini-1.5-flash" });

async function getGeminiResponse(prompt) {
  try {
    console.log(chalk.blue(`[AI] Memproses prompt: "${prompt}"`));
    const result = await model.generateContent(prompt);
    return result.response.text();
  } catch (error) {
    console.error(chalk.red(`[AI] Error: ${error.message}`));
    return "Maaf, terjadi kesalahan saat saya mencoba berpikir. 😥";
  }
}

module.exports = { getGeminiResponse };