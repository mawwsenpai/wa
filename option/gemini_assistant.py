# --- gemini_assistant.py ---
import google.generativeai as genai

def initialize_gemini(api_key):
    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-pro')
        print("✅ Koneksi ke Gemini AI berhasil.")
        return model
    except Exception as e:
        print(f"❌ Gagal mengkonfigurasi Gemini API. Mungkin Kunci API salah. Error: {e}")
        return None

def ask_gemini(model, pertanyaan):
    print("🤖 Berpikir...")
    try:
        response = model.generate_content(pertanyaan)
        return response.text
    except Exception as e:
        return f"❌ Terjadi error saat menghubungi Gemini: {e}"
