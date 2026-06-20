"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { getUserFavoriteGames } from "@/lib/firestore-service";
import { GameModel } from "@/lib/types";
import { useAuth } from "@/lib/auth-context";
import LoadingSpinner from "@/components/LoadingSpinner";
import EmptyState from "@/components/EmptyState";

export default function FavoritesPage() {
  const { userData, toggleFavorite, refreshUserData } = useAuth();
  const router = useRouter();
  const [favorites, setFavorites] = useState<GameModel[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchFavorites() {
      try {
        if (userData?.favorites?.length) {
          const games = await getUserFavoriteGames(userData.favorites);
          setFavorites(games);
        }
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    }
    fetchFavorites();
  }, [userData?.favorites]);

  const handleRemove = async (gameId: string) => {
    await toggleFavorite(gameId);
    await refreshUserData();
    setFavorites((prev) => prev.filter((g) => g.id !== gameId));
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-5xl mx-auto px-4 md:px-8 py-6">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => router.back()} className="text-gray-500 hover:text-gray-700">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
          <h1 className="text-xl font-bold text-[#21406c]">الألعاب المفضلة</h1>
        </div>

        {loading ? (
          <LoadingSpinner />
        ) : favorites.length === 0 ? (
          <EmptyState
            title="لا توجد ألعاب مفضلة بعد"
            subtitle="يمكنك إضافة الألعاب إلى المفضلة من خلال الضغط على زر الإضافة في صفحة اللعبة."
          />
        ) : (
          <div className="space-y-3">
            {favorites.map((game) => (
              <div
                key={game.id}
                className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden flex hover:shadow-md transition-all"
              >
                <Link href={`/main/games/${game.id}`} className="flex-1 flex items-center gap-4 p-4">
                  {game.coverUrl && (
                    <img src={game.coverUrl} alt={game.name} className="w-20 h-20 rounded-xl object-cover" />
                  )}
                  <div className="flex-1 min-w-0">
                    <h3 className="font-bold text-[#21406c] mb-1">{game.name}</h3>
                    <p className="text-sm text-gray-500 line-clamp-2">{game.explanation}</p>
                  </div>
                </Link>
                <button
                  onClick={() => handleRemove(game.id)}
                  className="px-4 text-red-500 hover:bg-red-50 transition-colors flex items-center"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
