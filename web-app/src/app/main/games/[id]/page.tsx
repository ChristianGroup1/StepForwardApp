"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import DOMPurify from "dompurify";
import { getGameById } from "@/lib/firestore-service";
import { GameModel } from "@/lib/types";
import { useAuth } from "@/lib/auth-context";
import { useI18n } from "@/lib/i18n";
import LoadingSpinner from "@/components/LoadingSpinner";

function extractYouTubeId(url: string): string | null {
  const match = url.match(/(?:youtu\.be\/|youtube\.com\/(?:watch\?v=|embed\/|v\/|shorts\/))([a-zA-Z0-9_-]{11})/);
  return match ? match[1] : null;
}

async function translateText(text: string, targetLang: string): Promise<string> {
  try {
    const res = await fetch("/api/translate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text, targetLang }),
    });
    const data = await res.json();
    return data.translatedText || text;
  } catch {
    return text;
  }
}

interface TranslatedGame {
  explanation: string;
  tools: string;
  laws: string;
  target: string;
}

export default function GameDetailsPage() {
  const params = useParams();
  const router = useRouter();
  const { userData, toggleFavorite } = useAuth();
  const { t, locale } = useI18n();
  const [game, setGame] = useState<GameModel | null>(null);
  const [loading, setLoading] = useState(true);
  const [translating, setTranslating] = useState(false);
  const [translated, setTranslated] = useState<TranslatedGame | null>(null);
  const [showTranslation, setShowTranslation] = useState(false);

  useEffect(() => {
    async function fetchGame() {
      try {
        const id = params.id as string;
        const data = await getGameById(id);
        setGame(data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    fetchGame();
  }, [params.id]);

  const handleTranslate = async () => {
    if (!game) return;
    if (translated) {
      setShowTranslation(!showTranslation);
      return;
    }

    setTranslating(true);
    try {
      const targetLang = locale === "ar" ? "en" : "ar";
      const [explanation, tools, laws, target] = await Promise.all([
        translateText(game.explanation, targetLang),
        translateText(game.tools, targetLang),
        game.laws ? translateText(game.laws, targetLang) : Promise.resolve(""),
        translateText(game.target, targetLang),
      ]);
      setTranslated({ explanation, tools, laws, target });
      setShowTranslation(true);
    } catch {
      // Translation failed, ignore
    } finally {
      setTranslating(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!game) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-gray-500">{t("gameNotFound")}</p>
      </div>
    );
  }

  const videoId = game.videoLink ? extractYouTubeId(game.videoLink) : null;
  const isFav = userData?.favorites?.includes(game.id);

  // Choose displayed content (original or translated)
  const displayExplanation = showTranslation && translated ? translated.explanation : game.explanation;
  const displayTools = showTranslation && translated ? translated.tools : game.tools;
  const displayLaws = showTranslation && translated ? translated.laws : game.laws;
  const displayTarget = showTranslation && translated ? translated.target : game.target;

  return (
    <div className="min-h-screen bg-white">
      {/* Header image */}
      {game.coverUrl && (
        <div className="relative h-64 sm:h-80">
          <img src={game.coverUrl} alt={game.name} className="w-full h-full object-cover" />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
          <div className="absolute bottom-0 left-0 right-0 p-6">
            <h1 className="text-2xl font-bold text-white">{game.name}</h1>
          </div>
          <button
            onClick={() => router.back()}
            className="absolute top-4 right-4 bg-white/80 backdrop-blur-sm rounded-full p-2 hover:bg-white transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>
      )}

      <div className="max-w-4xl mx-auto px-4 md:px-8 py-6">
        {!game.coverUrl && (
          <div className="flex items-center gap-3 mb-6">
            <button onClick={() => router.back()} className="text-gray-500 hover:text-gray-700">
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </button>
            <h1 className="text-2xl font-bold text-[#21406c]">{game.name}</h1>
          </div>
        )}

        {/* Action buttons row */}
        <div className="flex flex-wrap gap-3 mb-6">
          {/* Favorite button */}
          <button
            onClick={() => toggleFavorite(game.id)}
            className={`flex items-center gap-2 px-4 py-2 rounded-xl transition-all ${
              isFav
                ? "bg-red-50 text-red-600 border border-red-200"
                : "bg-gray-50 text-gray-600 border border-gray-200 hover:bg-gray-100"
            }`}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="h-5 w-5"
              fill={isFav ? "currentColor" : "none"}
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth={2}
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
              />
            </svg>
            {isFav ? t("removeFromFavorites") : t("addToFavorites")}
          </button>

          {/* Translate button */}
          <button
            onClick={handleTranslate}
            disabled={translating}
            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-blue-50 text-blue-700 border border-blue-200 hover:bg-blue-100 transition-all disabled:opacity-50"
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            {translating
              ? t("translating")
              : showTranslation
              ? t("showOriginal")
              : locale === "ar"
              ? t("translateToEnglish")
              : t("translateToArabic")}
          </button>
        </div>

        {/* Age Tags */}
        {game.tags?.length > 0 && (
          <section className="mb-6">
            <h2 className="text-lg font-bold text-[#21406c] mb-3">{t("gameAgeTags")}</h2>
            <div className="flex flex-wrap gap-2">
              {game.tags.map((tag, i) => (
                <span key={i} className="bg-[#ffc856]/20 text-[#21406c] px-3 py-1 rounded-full text-sm font-medium">
                  {tag}
                </span>
              ))}
            </div>
          </section>
        )}

        <hr className="my-6 border-gray-100" />

        {/* Video */}
        {videoId && (
          <>
            <section className="mb-6">
              <h2 className="text-lg font-bold text-[#21406c] mb-3">{t("gameVideo")}</h2>
              <div className="rounded-xl overflow-hidden aspect-video">
                <iframe
                  src={`https://www.youtube.com/embed/${videoId}`}
                  title={game.name}
                  className="w-full h-full"
                  allowFullScreen
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                />
              </div>
            </section>
            <hr className="my-6 border-gray-100" />
          </>
        )}

        {/* Explanation */}
        <section className="mb-6">
          <h2 className="text-lg font-bold text-[#21406c] mb-3">{t("gameExplanation")}</h2>
          <p className="text-gray-700 leading-relaxed whitespace-pre-wrap">{displayExplanation}</p>
        </section>

        <hr className="my-6 border-gray-100" />

        {/* Tools */}
        <section className="mb-6">
          <h2 className="text-lg font-bold text-[#21406c] mb-3">{t("gameTools")}</h2>
          <p className="text-gray-700 leading-relaxed whitespace-pre-wrap">{displayTools}</p>
        </section>

        {/* Laws */}
        {displayLaws && (
          <>
            <hr className="my-6 border-gray-100" />
            <section className="mb-6">
              <h2 className="text-lg font-bold text-[#21406c] mb-3">{t("gameLaws")}</h2>
              <p className="text-gray-700 leading-relaxed whitespace-pre-wrap">{displayLaws}</p>
            </section>
          </>
        )}

        {/* Target */}
        <hr className="my-6 border-gray-100" />
        <section className="mb-6">
          <h2 className="text-lg font-bold text-[#21406c] mb-3">{t("gameTarget")}</h2>
          <div className="text-gray-700 leading-relaxed" dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(displayTarget) }} />
        </section>
      </div>
    </div>
  );
}
