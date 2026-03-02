"use client";

import { useRouter } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import { useAuth } from "@/lib/auth-context";

export default function MoreTab() {
  const { userData, logout } = useAuth();
  const router = useRouter();

  const handleLogout = async () => {
    try {
      await logout();
      router.push("/login");
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="px-4 md:px-8 py-6 max-w-4xl mx-auto">
      {/* User Header */}
      <div className="bg-gradient-to-l from-[#21406c] to-[#415a81] rounded-2xl p-6 text-white mb-6">
        <div className="flex items-center gap-4">
          <div className="w-16 h-16 rounded-full bg-white/20 flex items-center justify-center overflow-hidden">
            <Image
              src="/male_profile_image.png"
              alt="Profile"
              width={64}
              height={64}
              className="rounded-full"
            />
          </div>
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
        <h3 className="text-lg font-bold text-[#21406c] mb-4">المعلومات الشخصية</h3>
        <div className="space-y-3">
          <InfoItem label="الاسم" value={`${userData?.firstName} ${userData?.lastName}`} />
          <InfoItem label="البريد الإلكتروني" value={userData?.email || ""} />
          <InfoItem label="رقم الهاتف" value={userData?.phoneNumber || "—"} />
          <InfoItem label="المحافظة" value={userData?.government || "—"} />
          <InfoItem label="الكنيسة" value={userData?.churchName || "—"} />
          <InfoItem
            label="حالة الحساب"
            value={userData?.isApproved ? "معتمد ✓" : "في انتظار الموافقة"}
            valueClass={userData?.isApproved ? "text-green-600" : "text-yellow-600"}
          />
        </div>
      </div>

      {/* Actions */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <Link
          href="/main/update-profile"
          className="flex items-center justify-between p-4 hover:bg-gray-50 transition-colors border-b border-gray-100"
        >
          <div className="flex items-center gap-3">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-[#21406c]" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
            <span className="font-medium text-gray-700">تعديل الملف الشخصي</span>
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
            <span className="font-medium text-gray-700">الألعاب المفضلة</span>
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
            <span className="font-medium">تسجيل الخروج</span>
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
