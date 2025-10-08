// gemini.js - (Final) Otak AI dengan Perbaikan Kompatibilitas
require('dotenv').config();
const genAI_module = require("@google/genai");
const GoogleGenerativeAI = genAI_module.GoogleGenerativeAI;
const chalk = require('chalk');

if (!process.env.GEMINI_API_KEY) {
  throw new Error("GEMINI_API_KEY tidak ditemukan di file .env");
}
if (typeof GoogleGenerativeAI !== 'function') {
  throw new TypeError("Gagal memuat GoogleGenerativeAI. Coba jalankan Menu 1 dari main.sh");
}

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: process.env.GEMINI_MODEL || "gemini-1.5-flash" });

async function getGeminiResponse(prompt) {
  try {
    const result = await model.generateContent(prompt);
    return result.response.text();
  } catch (error) {
    console.error(chalk.red(`[AI] Error: ${error.message}`));
    return "Maaf, AI sedang istirahat sejenak. 😥";
  }
}

module.exports = { getGeminiResponse };