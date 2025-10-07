# --- gemini_assistant.py ---

import requests
import json

# Variabel global untuk menyimpan API key
GEMINI_API_KEY = None

def initialize_gemini(api_key):
    """Hanya menyimpan API key untuk digunakan nanti."""
    global GEMINI_API_KEY
    if not api_key:
        print("   -> ❌ Kunci API Gemini kosong.")
        return False
        
    GEMINI_API_KEY = api_key
    print("   -> ✅ Koneksi manual ke Gemini AI siap digunakan.")
    return True

def ask_gemini(pertanyaan):
    """Mengirim permintaan ke Gemini API menggunakan requests secara manual."""
    if not GEMINI_API_KEY:
        return "❌ Gemini belum diinisialisasi dengan benar."

    api_url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={GEMINI_API_KEY}"
    payload = {"contents": [{"parts": [{"text": pertanyaan}]}]}
    headers = {"Content-Type": "application/json"}

    try:
        # Kirim permintaan POST ke server Google
        response = requests.post(api_url, headers=headers, json=payload, timeout=60)
        response.raise_for_status() # Akan error jika status code bukan 200 (OK)

        # Ambil jawaban dari respons JSON
        data = response.json()
        return data['candidates'][0]['content']['parts'][0]['text']

    except requests.exceptions.RequestException as e:
        # Menangani jika ada error jaringan atau API Key salah
        return f"❌ Gagal menghubungi Gemini. Cek koneksi atau Kunci API. Detail: {str(e)}"
    except (KeyError, IndexError):
        # Menangani jika format jawaban dari Google tidak sesuai harapan
        return "❌ Gagal mem-parsing jawaban dari Gemini."
