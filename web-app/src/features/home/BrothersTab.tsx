"use client";

import { useEffect, useState, useMemo } from "react";
import { getBrothers, searchBrothers } from "@/lib/firestore-service";
import { BrothersModel } from "@/lib/types";
import { useAuth } from "@/lib/auth-context";
import LoadingSpinner from "@/components/LoadingSpinner";
import EmptyState from "@/components/EmptyState";
import { governments } from "@/lib/constants";
import Image from "next/image";

export default function BrothersTab() {
  const { userData } = useAuth();
  const [brothers, setBrothers] = useState<BrothersModel[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchText, setSearchText] = useState("");
  const [selectedGov, setSelectedGov] = useState<string | null>(null);
  const [searching, setSearching] = useState(false);

  useEffect(() => {
    async function fetchData() {
      try {
        const data = await getBrothers();
        setBrothers(data);
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
      const results = await searchBrothers(searchText);
      setBrothers(results);
    } catch (err) {
      console.error(err);
    } finally {
      setSearching(false);
    }
  };

  const filteredBrothers = useMemo(() => {
    if (!selectedGov) return brothers;
    return brothers.filter((b) => b.government === selectedGov);
  }, [brothers, selectedGov]);

  // Check user approval
  if (!loading && userData && !userData.isApproved) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-16 text-center">
        <Image src="/wating_approval.png" alt="في انتظار الموافقة" width={200} height={200} className="mx-auto mb-6" />
        <h2 className="text-xl font-bold text-[#21406c] mb-2">في انتظار الموافقة</h2>
        <p className="text-gray-500">حسابك في انتظار الموافقة من المسؤولين. يرجى الانتظار.</p>
      </div>
    );
  }

  if (loading) return <LoadingSpinner size="lg" />;

  return (
    <div className="px-4 md:px-8 py-6 max-w-7xl mx-auto">
      <h1 className="text-2xl font-bold text-[#21406c] mb-4">الخدام</h1>

      {/* Search */}
      <div className="flex gap-2 mb-4 max-w-xl">
        <input
          type="text"
          placeholder="ابحث عن خادم..."
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
          {searching ? "..." : "بحث"}
        </button>
      </div>

      {/* Government filter */}
      <div className="flex flex-wrap gap-2 mb-6">
        <button
          onClick={() => setSelectedGov(null)}
          className={`px-3 py-1.5 rounded-full text-sm font-medium transition-all ${
            !selectedGov ? "bg-[#21406c] text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200"
          }`}
        >
          الكل
        </button>
        {governments.slice(0, 8).map((gov) => (
          <button
            key={gov}
            onClick={() => setSelectedGov(gov === selectedGov ? null : gov)}
            className={`px-3 py-1.5 rounded-full text-sm font-medium transition-all ${
              selectedGov === gov ? "bg-[#21406c] text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200"
            }`}
          >
            {gov}
          </button>
        ))}
      </div>

      {filteredBrothers.length === 0 ? (
        <EmptyState title="لا يوجد خدام" subtitle="جرب البحث بكلمات مختلفة" />
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredBrothers.map((brother) => (
            <div
              key={brother.id}
              className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 hover:shadow-md transition-all"
            >
              <div className="flex items-start gap-4">
                {brother.coverUrl ? (
                  <img
                    src={brother.coverUrl}
                    alt={brother.name}
                    className="w-16 h-16 rounded-full object-cover flex-shrink-0"
                  />
                ) : (
                  <div className="w-16 h-16 rounded-full bg-[#21406c]/10 flex items-center justify-center flex-shrink-0">
                    <span className="text-xl font-bold text-[#21406c]">{brother.name.charAt(0)}</span>
                  </div>
                )}
                <div className="flex-1 min-w-0">
                  <h3 className="font-bold text-[#21406c] mb-1">{brother.name}</h3>
                  <p className="text-sm text-gray-500">{brother.churchName}</p>
                  <p className="text-sm text-gray-400">{brother.government} {brother.city ? `- ${brother.city}` : ""}</p>
                  {brother.tags?.length > 0 && (
                    <div className="flex flex-wrap gap-1 mt-2">
                      {brother.tags.map((tag, i) => (
                        <span key={i} className="text-xs bg-[#ffc856]/20 text-[#21406c] px-2 py-0.5 rounded-full">
                          {tag}
                        </span>
                      ))}
                    </div>
                  )}
                </div>
              </div>
              {brother.phoneNumber && (
                <div className="mt-3 pt-3 border-t border-gray-100">
                  <a
                    href={`tel:${brother.phoneNumber}`}
                    className="text-sm text-[#21406c] hover:underline flex items-center gap-1"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                    </svg>
                    {brother.phoneNumber}
                  </a>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
