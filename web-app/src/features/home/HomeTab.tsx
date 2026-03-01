"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { getGames, getBrothers, getBooks } from "@/lib/firestore-service";
import { GameModel, BrothersModel, BookModel } from "@/lib/types";
import { useAuth } from "@/lib/auth-context";
import LoadingSpinner from "@/components/LoadingSpinner";

function GameCard({ game }: { game: GameModel }) {
  return (
    <Link href={`/main/games/${game.id}`} className="block">
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-shadow">
        {game.coverUrl && (
          <div className="h-36 overflow-hidden">
            <img src={game.coverUrl} alt={game.name} className="w-full h-full object-cover" />
          </div>
        )}
        <div className="p-3">
          <h3 className="font-bold text-sm text-[#21406c] truncate">{game.name}</h3>
          {game.tags?.length > 0 && (
            <div className="flex flex-wrap gap-1 mt-2">
              {game.tags.slice(0, 3).map((tag, i) => (
                <span key={i} className="text-xs bg-[#ffc856]/20 text-[#21406c] px-2 py-0.5 rounded-full">
                  {tag}
                </span>
              ))}
            </div>
          )}
        </div>
      </div>
    </Link>
  );
}

function BrotherCard({ brother }: { brother: BrothersModel }) {
  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden p-3 flex items-center gap-3">
      {brother.coverUrl ? (
        <img src={brother.coverUrl} alt={brother.name} className="w-14 h-14 rounded-full object-cover" />
      ) : (
        <div className="w-14 h-14 rounded-full bg-[#21406c]/10 flex items-center justify-center">
          <span className="text-lg font-bold text-[#21406c]">{brother.name.charAt(0)}</span>
        </div>
      )}
      <div className="flex-1 min-w-0">
        <h3 className="font-bold text-sm text-[#21406c] truncate">{brother.name}</h3>
        <p className="text-xs text-gray-500 truncate">{brother.churchName}</p>
      </div>
    </div>
  );
}

function BookCard({ book }: { book: BookModel }) {
  return (
    <a href={book.url} target="_blank" rel="noopener noreferrer" className="block">
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-shadow">
        {book.coverUrl && (
          <div className="h-36 overflow-hidden">
            <img src={book.coverUrl} alt={book.name} className="w-full h-full object-cover" />
          </div>
        )}
        <div className="p-3">
          <h3 className="font-bold text-sm text-[#21406c] truncate">{book.name}</h3>
        </div>
      </div>
    </a>
  );
}

interface HomeTabProps {
  onNavigateGames: () => void;
  onNavigateBrothers: () => void;
}

export default function HomeTab({ onNavigateGames, onNavigateBrothers }: HomeTabProps) {
  const { userData } = useAuth();
  const [games, setGames] = useState<GameModel[]>([]);
  const [brothers, setBrothers] = useState<BrothersModel[]>([]);
  const [books, setBooks] = useState<BookModel[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const [g, b, bk] = await Promise.all([getGames(), getBrothers(), getBooks()]);
        setGames(g.filter((game) => game.isVisible !== false));
        setBrothers(b);
        setBooks(bk);
      } catch (err) {
        console.error("Error fetching data:", err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  if (loading) return <LoadingSpinner size="lg" />;

  return (
    <div className="max-w-4xl mx-auto px-4 py-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-xl font-bold text-[#21406c]">
            مرحباً {userData?.firstName} 👋
          </h1>
          <p className="text-sm text-gray-500">خطوة للأمام</p>
        </div>
        <Link href="/main/favorites">
          <div className="p-2 rounded-full hover:bg-gray-100 transition-colors">
            <Image src="/in_active_favorite.svg" alt="المفضلة" width={24} height={24} />
          </div>
        </Link>
      </div>

      {/* Slider/Banner */}
      <div className="mb-8 rounded-2xl overflow-hidden shadow-sm">
        <div className="bg-gradient-to-l from-[#21406c] to-[#415a81] p-8 text-white text-center">
          <Image src="/step_forward_logo.png" alt="Step Forward" width={80} height={80} className="mx-auto mb-3 brightness-0 invert" />
          <h2 className="text-xl font-bold">خطوة للأمام</h2>
          <p className="text-sm opacity-80 mt-1">مجتمع خدام الكنيسة</p>
        </div>
      </div>

      {/* Games Section */}
      <section className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-bold text-[#21406c]">الألعاب</h2>
          <button onClick={onNavigateGames} className="text-sm text-[#ffc856] font-semibold hover:underline">
            عرض الكل
          </button>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
          {games.slice(0, 6).map((game) => (
            <GameCard key={game.id} game={game} />
          ))}
        </div>
      </section>

      {/* Brothers Section */}
      <section className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-bold text-[#21406c]">الخدام</h2>
          <button onClick={onNavigateBrothers} className="text-sm text-[#ffc856] font-semibold hover:underline">
            عرض الكل
          </button>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {brothers.slice(0, 4).map((brother) => (
            <BrotherCard key={brother.id} brother={brother} />
          ))}
        </div>
      </section>

      {/* Books Section */}
      {books.length > 0 && (
        <section className="mb-8">
          <h2 className="text-lg font-bold text-[#21406c] mb-4">الكتب</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
            {books.slice(0, 6).map((book) => (
              <BookCard key={book.id} book={book} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
