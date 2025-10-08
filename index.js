// index.js - Logika Frontend untuk Simulator/Uji Coba

// Ganti alamat ini dengan URL Ngrok Anda jika testing online
// Biarkan kosong jika testing di localhost
const SERVER_URL = ""; // Contoh: "https://random-name.ngrok-free.app"

const socket = SERVER_URL ? io(SERVER_URL) : io(); // Mulai koneksi

const form = document.getElementById('chat-form');
const input = document.getElementById('message-input');
const messagesContainer = document.getElementById('chat-messages');

// Fungsi untuk menambahkan gelembung pesan ke layar
function addMessage(text, sender) {
  const bubble = document.createElement('div');
  bubble.classList.add('message-bubble', sender);
  bubble.innerHTML = text.replace(/\n/g, '<br>'); // Agar karakter newline (\n) bisa tampil
  messagesContainer.appendChild(bubble);
  messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Saat form dikirim, kirim pesan ke server
form.addEventListener('submit', (e) => {
  e.preventDefault();
  const messageText = input.value.trim();
  if (messageText) {
    addMessage(messageText, 'user');
    socket.emit('chat message', messageText); // Kirim pesan ke server.js
    input.value = '';
  }
});

// Saat menerima balasan dari server
socket.on('bot reply', (msg) => {
  addMessage(msg, 'bot'); // Tampilkan balasan dari bot
});

// Memberi tahu user saat koneksi berhasil atau gagal
socket.on('connect', () => {
  console.log('Terhubung ke server!');
});

socket.on('connect_error', (err) => {
  console.error('Gagal terhubung ke server:', err);
  addMessage('Gagal terhubung ke server backend. Pastikan `node server.js` sudah berjalan.', 'bot');
});