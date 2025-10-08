// install-test.js - Installer Khusus untuk Server Uji Coba Lokal

const { execSync } = require('child_process');
const chalk = require('chalk');

// Dependensi HANYA untuk server uji coba
const MODULES = [
  'express',
  'socket.io',
  'chalk@4' // Diperlukan oleh server.js untuk log berwarna
];

console.log(chalk.cyan.bold("🔥 Memulai Instalasi Dependensi untuk Server Uji Coba..."));
console.log("----------------------------------------------------------");

try {
  console.log(`⏳ Menginstal modul: ${MODULES.join(', ')}...`);
  execSync(`npm install ${MODULES.join(' ')}`, { stdio: 'inherit' });
  console.log(chalk.green("✅ Dependensi untuk server uji coba berhasil diinstal!"));
  console.log("----------------------------------------------------------");
} catch (error) {
  console.error(chalk.red(`\n❌ Gagal menginstal dependensi uji coba: ${error.message}`));
  process.exit(1);
}