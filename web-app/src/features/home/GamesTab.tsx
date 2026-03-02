"use client";

import { useEffect, useState, useMemo } from "react";
import Link from "next/link";
import { getGames, searchGames } from "@/lib/firestore-service";
import { GameModel } from "@/lib/types";
import { useAuth } from "@/lib/auth-context";
import { useI18n } from "@/lib/i18n";
import LoadingSpinner from "@/components/LoadingSpinner";
import EmptyState from "@/components/EmptyState";
import ApprovalBanner from "@/components/ApprovalBanner";

const ageTags = ["أطفال", "ابتدائي", "اعدادي", "ثانوي", "جامعة", "كبار"];

export default function GamesTab() {
  const { userData, toggleFavorite } = useAuth();
  const { t } = useI18n();
  const [games, setGames] = useState<GameModel[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchText, setSearchText] = useState("");
  const [selectedTag, setSelectedTag] = useState<string | null>(null);
  const [searching, setSearching] = useState(false);

  useEffect(() => {
    async function fetchData() {
      try {
        const data = await getGames();
        setGames(data);
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  const handleSearch = async () => {
    if (!searchText.trim()) return;
    setSearching(true);
    try {
      const results = await searchGames(searchText);
      setGames(results);
    } catch (err) {
      console.error(err);
    } finally {
      setSearching(false);
    }
  };

  const filteredGames = useMemo(() => {
    if (!selectedTag) return games;
    return games.filter((g) => g.tags?.some((t) => t.includes(selectedTag)));
  }, [games, selectedTag]);

  if (loading) return <LoadingSpinner size="lg" />;

  return (
    <div className="px-4 md:px-8 py-6 max-w-7xl mx-auto">
      <h1 className="text-2xl font-bold text-[#21406c] mb-4">{t("gamesTitle")}</h1>

      {/* Approval / ID upload banner */}
      {userData && !userData.isApproved && (
        <div className="mb-4">
          <ApprovalBanner />
        </div>
      )}

      {/* Search */}
      <div className="flex gap-2 mb-4 max-w-xl">
        <input
          type="text"
          placeholder={t("gamesSearchPlaceholder")}
          value={searchText}
          onChange={(e) => setSearchText(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && handleSearch()}
          className="flex-1 rounded-xl border border-gray-300 bg-white py-2.5 px-4 text-gray-900 placeholder-gray-400 focus:border-[#21406c] focus:ring-2 focus:ring-[#21406c]/20 focus:outline-none"
        />
        <button
          onClick={handleSearch}
          disabled={searching}
          className="bg-[#21406c] text-white px-5 rounded-xl hover:bg-[#415a81] transition-colors"
        >
          {searching ? "..." : t("search")}
        </button>
      </div>

      {/* Tags filter */}
      <div className="flex flex-wrap gap-2 mb-6">
        <button
          onClick={() => setSelectedTag(null)}
          className={`px-3 py-1.5 rounded-full text-sm font-medium transition-all ${
            !selectedTag ? "bg-[#21406c] text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200"
          }`}
        >
          {t("all")}
        </button>
        {ageTags.map((tag) => (
          <button
            key={tag}
            onClick={() => setSelectedTag(tag === selectedTag ? null : tag)}
            className={`px-3 py-1.5 rounded-full text-sm font-medium transition-all ${
              selectedTag === tag ? "bg-[#21406c] text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200"
            }`}
          >
            {tag}
          </button>
        ))}
      </div>

      {filteredGames.length === 0 ? (
        <EmptyState title={t("gamesEmpty")} subtitle={t("gamesEmptySubtitle")} />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filteredGames.map((game) => {
            const isFav = userData?.favorites?.includes(game.id);
            return (
              <div key={game.id} className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-all">
                <Link href={`/main/games/${game.id}`}>
                  {game.coverUrl && (
                    <div className="h-40 overflow-hidden">
                      <img src={game.coverUrl} alt={game.name} className="w-full h-full object-cover" />
                    </div>
                  )}
                  <div className="p-4">
                    <h3 className="font-bold text-[#21406c] mb-1">{game.name}</h3>
                    <p className="text-sm text-gray-500 line-clamp-2">{game.explanation}</p>
                    {game.tags?.length > 0 && (
                      <div className="flex flex-wrap gap-1 mt-2">
                        {game.tags.map((tag, i) => (
                          <span key={i} className="text-xs bg-[#ffc856]/20 text-[#21406c] px-2 py-0.5 rounded-full">
                            {tag}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                </Link>
                <div className="px-4 pb-3">
                  <button
                    onClick={() => toggleFavorite(game.id)}
                    className="text-sm flex items-center gap-1 text-gray-500 hover:text-red-500 transition-colors"
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
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
