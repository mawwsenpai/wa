// index.js - Otak Simulator untuk Uji Coba Tampilan

const form = document.getElementById('chat-form');
const input = document.getElementById('message-input');
const messagesContainer = document.getElementById('chat-messages');

// Variabel untuk menyimpan status pengguna dalam simulasi
let userState = null;
let tempUser = {};

// Fungsi untuk menampilkan gelembung chat di layar
function addMessage(text, sender) {
  const bubble = document.createElement('div');
  bubble.classList.add('message-bubble', sender);
  bubble.innerHTML = text.replace(/\n/g, '<br>');
  messagesContainer.appendChild(bubble);
  messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Fungsi untuk memproses input pengguna dan memberikan balasan simulasi
function simulateBotResponse(userText) {
  const text = userText.toLowerCase();
  
  // Jeda singkat agar terasa seperti balasan asli
  setTimeout(() => {
    // --- SIMULASI ALUR REGISTRASI ---
    if (text === '.menu' && !userState) {
      addMessage("Silakan pilih:\n- Free\n- Prem", 'bot');
      userState = 'menunggu_pilihan_awal';
      return;
    }
    if (userState === 'menunggu_pilihan_awal' && text === 'free') {
      addMessage("Anda memilih mode Free.\n\nSilakan masukkan Username Anda:", 'bot');
      userState = 'memasukkan_username';
      return;
    }
    if (userState === 'memasukkan_username') {
      tempUser.username = userText;
      addMessage(`Username "${tempUser.username}" diterima.\n\nSekarang masukkan Sandi Anda:`, 'bot');
      userState = 'memasukkan_sandi';
      return;
    }
    if (userState === 'memasukkan_sandi') {
      const welcomeMessage = `🎉 Registrasi Berhasil! 🎉\n\nHallo ${tempUser.username}!\nStatus: Free\n\n--- MENU FITUR ---\n.poto [query]\n.cuaca [nama kota]`;
      addMessage(welcomeMessage, 'bot');
      userState = null; // Selesai, reset status
      tempUser = {};
      return;
    }
    
    // --- SIMULASI FITUR DENGAN API ---
    if (text.startsWith('.poto')) {
      const query = userText.substring(6);
      addMessage(`🔎 [SIMULASI] Sedang mencari gambar "${query}"...`, 'bot');
      setTimeout(() => addMessage(`✅ [SIMULASI] Ini gambar "${query}" yang kutemukan!`, 'bot'), 1500);
      return;
    }
    if (text.startsWith('.cuaca')) {
      const city = userText.substring(7);
      addMessage(`🌤️ [SIMULASI] Mengecek cuaca untuk "${city}"...`, 'bot');
      setTimeout(() => addMessage(`[SIMULASI] Cuaca di ${city}: Cerah, 30°C.`, 'bot'), 1000);
      return;
    }
    
    // --- SIMULASI CHAT AI BIASA ---
    addMessage(`(Simulasi AI): Anda bilang "${userText}". Balasan ini tanpa API Gemini.`, 'bot');
    
  }, 500);
}

// Event listener untuk form input
form.addEventListener('submit', (e) => {
  e.preventDefault();
  const messageText = input.value.trim();
  if (messageText) {
    addMessage(messageText, 'user');
    simulateBotResponse(messageText);
    input.value = '';
  }
});