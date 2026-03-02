"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import LoadingSpinner from "@/components/LoadingSpinner";
import HomeTab from "@/features/home/HomeTab";
import GamesTab from "@/features/home/GamesTab";
import BrothersTab from "@/features/home/BrothersTab";
import MoreTab from "@/features/home/MoreTab";
import Image from "next/image";
import Link from "next/link";

const tabs = [
  { id: "home", label: "الرئيسية", activeIcon: "/active_home.svg", inactiveIcon: "/in_active_home.svg" },
  { id: "games", label: "الألعاب", activeIcon: "/games_icon.svg", inactiveIcon: "/games_icon.svg" },
  { id: "brothers", label: "الخدام", activeIcon: "/people_icon.svg", inactiveIcon: "/people_icon.svg" },
  { id: "more", label: "المزيد", activeIcon: "/more_active.svg", inactiveIcon: "/more_inactive.svg" },
];

export default function MainPage() {
  const { user, userData, loading } = useAuth();
  const router = useRouter();
  const [activeTab, setActiveTab] = useState("home");

  useEffect(() => {
    if (!loading && (!user || !userData)) {
      router.replace("/login");
    }
  }, [user, userData, loading, router]);

  if (loading || !user || !userData) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      {/* Top Header Bar - visible on all screen sizes */}
      <header className="sticky top-0 z-50 bg-white border-b border-gray-200 shadow-sm">
        <div className="flex items-center justify-between px-4 md:px-6 h-16">
          <div className="flex items-center gap-3">
            <Image src="/step_forward_logo.png" alt="Step Forward" width={36} height={36} />
            <h1 className="text-lg font-bold text-[#21406c] hidden sm:block">خطوة للأمام</h1>
          </div>
          <div className="flex items-center gap-3">
            <Link href="/main/favorites" className="p-2 rounded-lg hover:bg-gray-100 transition-colors">
              <Image src="/in_active_favorite.svg" alt="المفضلة" width={22} height={22} />
            </Link>
            <div className="hidden md:flex items-center gap-2 text-sm text-gray-600">
              <div className="w-8 h-8 rounded-full bg-[#21406c]/10 flex items-center justify-center">
                <span className="text-xs font-bold text-[#21406c]">{userData?.firstName?.charAt(0)}</span>
              </div>
              <span className="font-medium">{userData?.firstName} {userData?.lastName}</span>
            </div>
          </div>
        </div>
      </header>

      <div className="flex flex-1 overflow-hidden">
        {/* Desktop Sidebar - hidden on mobile */}
        <aside className="hidden md:flex flex-col w-56 lg:w-64 bg-white border-l border-gray-200 shadow-sm flex-shrink-0">
          <nav className="flex-1 py-4 px-3 space-y-1">
            {tabs.map((tab) => {
              const isActive = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`w-full flex items-center gap-3 py-3 px-4 rounded-xl transition-all text-sm font-medium ${
                    isActive
                      ? "bg-[#21406c] text-white shadow-md"
                      : "text-gray-600 hover:bg-gray-100"
                  }`}
                >
                  <Image
                    src={isActive ? tab.activeIcon : tab.inactiveIcon}
                    alt={tab.label}
                    width={22}
                    height={22}
                    className={isActive ? "brightness-0 invert" : "opacity-70"}
                  />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </nav>

          {/* Sidebar footer */}
          <div className="p-4 border-t border-gray-100">
            <div className="flex items-center gap-3 px-2">
              <Image src="/male_profile_image.png" alt="Profile" width={36} height={36} className="rounded-full" />
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-[#21406c] truncate">{userData?.firstName} {userData?.lastName}</p>
                <p className="text-xs text-gray-400 truncate">{userData?.email}</p>
              </div>
            </div>
          </div>
        </aside>

        {/* Content area */}
        <main className="flex-1 overflow-auto pb-20 md:pb-6">
          {activeTab === "home" && (
            <HomeTab onNavigateGames={() => setActiveTab("games")} onNavigateBrothers={() => setActiveTab("brothers")} />
          )}
          {activeTab === "games" && <GamesTab />}
          {activeTab === "brothers" && <BrothersTab />}
          {activeTab === "more" && <MoreTab />}
        </main>
      </div>

      {/* Bottom Navigation - mobile only */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-gradient-to-t from-[#21406c] to-[#415a81] rounded-t-3xl shadow-lg z-50">
        <div className="max-w-lg mx-auto flex items-center justify-around py-2">
          {tabs.map((tab) => {
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex flex-col items-center gap-1 py-2 px-4 rounded-xl transition-all ${
                  isActive ? "bg-white/15" : "hover:bg-white/5"
                }`}
              >
                <Image
                  src={isActive ? tab.activeIcon : tab.inactiveIcon}
                  alt={tab.label}
                  width={24}
                  height={24}
                  className={isActive ? "brightness-0 invert" : "opacity-60 brightness-0 invert"}
                />
                <span className={`text-xs ${isActive ? "text-white font-semibold" : "text-white/60"}`}>
                  {tab.label}
                </span>
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
}
