// gemini-config.js

const { GoogleGenAI } = require('@google/genai');

// --- Inisialisasi API ---
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-pro';

if (!GEMINI_API_KEY) {
  console.error("❌ ERROR GEMINI: GEMINI_API_KEY belum disetel! Harap jalankan Konfigurasi Gemini API.");
  process.exit(1);
}
const ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY });


// Fungsi Logika Balasan Utama
async function handleMessage(sock, m, from, text) {
  const lowerText = text.toLowerCase();
  
  // 1. Balasan Khusus (Prioritas Tinggi)
  let response = '';
  if (lowerText === 'hey') {
    response = 'Kamu siapa? 🤔';
  } else if (lowerText === 'maww') {
    response = 'oh sayangku 🥰';
  } else if (lowerText === 'lah') {
    response = 'Gajelas 😒';
  } else if (lowerText === 'masa lupa sih') {
    response = 'Kan udah kujelasin, kamu siapa?';
  }
  
  if (response) {
    await sock.sendMessage(from, { text: response });
    return;
  }
  
  // 2. Balasan Otomatis Menggunakan Gemini
  try {
    console.log(`[GEMINI] Meneruskan pesan ke AI menggunakan ${GEMINI_MODEL}...`);
    
    const result = await ai.models.generateContent({
      model: GEMINI_MODEL,
      contents: text,
    });
    
    const geminiResponse = result.text.trim();
    
    await sock.sendMessage(from, { text: geminiResponse });
    console.log(`[BOT BALAS AI] Balasan: ${geminiResponse.substring(0, 50)}...`);
    
  } catch (e) {
    console.error('❌ ERROR GEMINI RESPONSE:', e);
    await sock.sendMessage(from, { text: `Yah, ${GEMINI_MODEL} lagi ngambek nih. Coba lagi ya, Cuy! 😔` });
  }
}

// Export fungsi agar bisa dipakai main.js
module.exports = {
  handleMessage
};