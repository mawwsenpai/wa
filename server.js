// server.js - Server Uji Coba Lokal untuk Bot

const express = require('express');
const http = require('http');
const { Server } = require("socket.io");
const chalk = require('chalk');

// Impor logika bot kita
const { handleCommand } = require('./script.js');
const { getGeminiResponse } = require('./gemini.js');

const app = express();
const server = http.createServer(app);
const io = new Server(server);
const PORT = 3000;

// Sajikan file index.html saat server diakses
app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

console.log(chalk.cyan.bold("🔥 Server Uji Coba Lokal Siap..."));

// Logika saat ada koneksi dari browser
io.on('connection', (socket) => {
  console.log(chalk.green('✅ Browser terhubung!'));
  
  // Saat menerima pesan dari browser
  socket.on('chat message', async (msg) => {
    console.log(chalk.blue(`[USER] -> ${msg}`));
    
    // "sock" palsu untuk dilempar ke handleCommand
    // Tugasnya adalah mengirim balasan kembali ke browser
    const fakeSock = {
      sendMessage: (from, message) => {
        console.log(chalk.yellow(`[BOT] -> ${message.text}`));
        socket.emit('bot reply', message.text); // Kirim balasan ke browser
      }
    };
    
    // Cek apakah ini perintah atau chat biasa (logika router dari main.js)
    if (msg.startsWith('.')) {
      // "from" dan "senderName" bisa kita buat palsu untuk tes
      await handleCommand(fakeSock, 'user_local', msg, 'Developer');
    } else {
      const response = await getGeminiResponse(msg);
      fakeSock.sendMessage('user_local', { text: response });
    }
  });
  
  socket.on('disconnect', () => {
    console.log(chalk.red('Browser terputus.'));
  });
});

server.listen(PORT, () => {
  console.log(chalk.green.bold(`🚀 Server berjalan di http://localhost:${PORT}`));
  console.log('Buka alamat tersebut di browser Anda untuk memulai uji coba.');
});