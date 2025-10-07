# --- gemini_assistant.py ---
# VERSI "JALUR BAWAH TANAH" - Menggunakan requests

import requests # Library untuk "menelepon" server
import json

# Variabel global untuk model, diisi saat inisialisasi
GEMINI_API_KEY = None
GEMINI_API_URL = None

def initialize_gemini(api_key):
    """Menyimpan API key dan menyiapkan URL."""
    global GEMINI_API_KEY, GEMINI_API_URL
    if not api_key:
        print("❌ Kunci API Gemini kosong.")
        return False
        
    GEMINI_API_KEY = api_key
    GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={GEMINI_API_KEY}"
    print("✅ Koneksi manual ke Gemini AI siap.")
    return True # Kita anggap selalu berhasil jika key ada

def ask_gemini(model, pertanyaan): # Parameter 'model' tidak kita pakai lagi, tapi biarkan agar tidak merusak ui_handler
    """Mengirim permintaan ke Gemini API menggunakan requests."""
    print("🤖 Berpikir (mode manual)...")
    if not GEMINI_API_URL:
        return "❌ Gemini belum diinisialisasi dengan benar."

    # Siapkan data yang akan dikirim sesuai format Google
    payload = {
        "contents": [{
            "parts": [{
                "text": pertanyaan
            }]
        }]
    }
    headers = {
        "Content-Type": "application/json"
    }

    try:
        # Kirim permintaan POST ke server Google
        response = requests.post(GEMINI_API_URL, headers=headers, json=payload, timeout=60)
        response.raise_for_status() # Akan error jika status code bukan 2xx

        # Ambil jawaban dari respons JSON yang kompleks
        data = response.json()
        jawaban = data['candidates'][0]['content']['parts'][0]['text']
        return jawaban

    except requests.exceptions.RequestException as e:
        # Tangani jika ada error jaringan atau API
        error_data = e.response.json() if e.response else None
        error_message = error_data.get('error', {}).get('message', str(e)) if error_data else str(e)
        return f"❌ Gagal menghubungi Gemini. Cek koneksi internet atau Kunci API.\n   Detail: {error_message}"
    except (KeyError, IndexError):
        # Tangani jika format jawaban dari Google aneh
        return "❌ Gagal mem-parsing jawaban dari Gemini. Mungkin ada perubahan di pihak Google."

