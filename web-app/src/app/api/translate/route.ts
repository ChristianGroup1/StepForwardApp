import { NextRequest, NextResponse } from "next/server";

/**
 * Simple translation API endpoint.
 * Uses a free translation service (LibreTranslate-compatible API or MyMemory).
 * Falls back to returning original text if translation fails.
 */
export async function POST(request: NextRequest) {
  try {
    const { text, targetLang } = await request.json();

    if (!text || !targetLang) {
      return NextResponse.json({ error: "Missing text or targetLang" }, { status: 400 });
    }

    // Use MyMemory free translation API (no key needed, 5000 chars/day free)
    const sourceLang = targetLang === "en" ? "ar" : "en";
    const response = await fetch(
      `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text.slice(0, 500))}&langpair=${sourceLang}|${targetLang}`
    );

    if (!response.ok) {
      return NextResponse.json({ translatedText: text });
    }

    const data = await response.json();
    const translatedText = data?.responseData?.translatedText || text;

    return NextResponse.json({ translatedText });
  } catch {
    return NextResponse.json({ error: "Translation failed" }, { status: 500 });
  }
}
