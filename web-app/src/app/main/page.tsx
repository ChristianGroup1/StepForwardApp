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
    <div className="min-h-screen bg-white flex flex-col">
      {/* Content area */}
      <main className="flex-1 overflow-auto pb-20">
        {activeTab === "home" && (
          <HomeTab onNavigateGames={() => setActiveTab("games")} onNavigateBrothers={() => setActiveTab("brothers")} />
        )}
        {activeTab === "games" && <GamesTab />}
        {activeTab === "brothers" && <BrothersTab />}
        {activeTab === "more" && <MoreTab />}
      </main>

      {/* Bottom Navigation */}
      <nav className="fixed bottom-0 left-0 right-0 bg-gradient-to-t from-[#21406c] to-[#415a81] rounded-t-3xl shadow-lg z-50">
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
