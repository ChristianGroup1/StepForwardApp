"use client";

import { useState, useRef } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import { useI18n } from "@/lib/i18n";

export default function MoreTab() {
  const { userData, logout } = useAuth();
  const { t, locale, setLocale } = useI18n();
  const router = useRouter();
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleLogout = async () => {
    try {
      await logout();
      router.push("/login");
    } catch (err) {
      console.error(err);
    }
  };

  const handleLanguageToggle = () => {
    setLocale(locale === "ar" ? "en" : "ar");
  };

  const profileImage = "/male_profile_image.png";

  return (
    <div className="px-4 md:px-8 py-6 max-w-4xl mx-auto">
      {/* User Header */}
      <div className="bg-gradient-to-l from-[#21406c] to-[#415a81] rounded-2xl p-6 text-white mb-6">
        <div className="flex items-center gap-4">
          {/* Profile picture with المزيد menu */}
          <div className="relative">
            <button
              onClick={() => setShowProfileMenu(!showProfileMenu)}
              className="w-16 h-16 rounded-full bg-white/20 flex items-center justify-center overflow-hidden ring-2 ring-white/30 hover:ring-white/60 transition-all"
            >
              <Image
                src={profileImage}
                alt="Profile"
                width={64}
                height={64}
                className="rounded-full"
              />
            </button>
            {/* Small المزيد badge */}
            <span className="absolute -bottom-1 -end-1 bg-[#ffc856] text-[#21406c] text-[10px] font-bold px-1.5 py-0.5 rounded-full leading-none">
              {t("tabMore")}
            </span>

            {/* Profile picture dropdown */}
            {showProfileMenu && (
              <div className="absolute top-full mt-2 start-0 bg-white rounded-xl shadow-lg border border-gray-200 py-2 z-50 min-w-[160px]">
                <button
                  onClick={() => {
                    fileInputRef.current?.click();
                    setShowProfileMenu(false);
                  }}
                  className="w-full text-start px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 text-[#21406c]" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                  {t("uploadPhoto")}
                </button>
                <button
                  onClick={() => setShowProfileMenu(false)}
                  className="w-full text-start px-4 py-2 text-sm text-red-600 hover:bg-red-50 flex items-center gap-2"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                  </svg>
                  {t("removePhoto")}
                </button>
              </div>
            )}
          </div>
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={() => {
              // Profile picture upload would be handled here
            }}
          />
          <div>
            <h2 className="text-lg font-bold">
              {userData?.firstName} {userData?.lastName}
            </h2>
            <p className="text-sm text-white/70">{userData?.email}</p>
          </div>
        </div>
      </div>

      {/* User Info */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 mb-6">
        <h3 className="text-lg font-bold text-[#21406c] mb-4">{t("personalInfo")}</h3>
        <div className="space-y-3">
          <InfoItem label={t("labelName")} value={`${userData?.firstName} ${userData?.lastName}`} />
          <InfoItem label={t("labelEmail")} value={userData?.email || ""} />
          <InfoItem label={t("labelPhone")} value={userData?.phoneNumber || "—"} />
          <InfoItem label={t("labelGovernment")} value={userData?.government || "—"} />
          <InfoItem label={t("labelChurch")} value={userData?.churchName || "—"} />
          <InfoItem
            label={t("labelAccountStatus")}
            value={userData?.isApproved ? t("accountApproved") : t("accountPending")}
            valueClass={userData?.isApproved ? "text-green-600" : "text-yellow-600"}
          />
        </div>
      </div>

      {/* Actions */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        {/* Language toggle */}
        <button
          onClick={handleLanguageToggle}
          className="w-full flex items-center justify-between p-4 hover:bg-gray-50 transition-colors border-b border-gray-100"
        >
          <div className="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-[#21406c]" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span className="font-medium text-gray-700">{t("language")}</span>
          </div>
          <span className="text-sm text-[#21406c] font-semibold">
            {locale === "ar" ? "English" : "العربية"}
          </span>
        </button>

        <Link
          href="/main/update-profile"
          className="flex items-center justify-between p-4 hover:bg-gray-50 transition-colors border-b border-gray-100"
        >
          <div className="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-[#21406c]" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
            <span className="font-medium text-gray-700">{t("editProfile")}</span>
          </div>
          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-gray-400 rotate-180" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
          </svg>
        </Link>

        <Link
          href="/main/favorites"
          className="flex items-center justify-between p-4 hover:bg-gray-50 transition-colors border-b border-gray-100"
        >
          <div className="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-[#21406c]" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
            <span className="font-medium text-gray-700">{t("favoriteGames")}</span>
          </div>
          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-gray-400 rotate-180" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
          </svg>
        </Link>

        <button
          onClick={handleLogout}
          className="w-full flex items-center justify-between p-4 hover:bg-red-50 transition-colors text-red-600"
        >
          <div className="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
            <span className="font-medium">{t("logout")}</span>
          </div>
        </button>
      </div>
    </div>
  );
}

function InfoItem({ label, value, valueClass = "" }: { label: string; value: string; valueClass?: string }) {
  return (
    <div className="flex justify-between items-center py-2 border-b border-gray-50 last:border-0">
      <span className="text-sm text-gray-500">{label}</span>
      <span className={`text-sm font-medium ${valueClass || "text-gray-900"}`}>{value}</span>
    </div>
  );
}
