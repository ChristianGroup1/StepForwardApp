"use client";

import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { uploadIdImage } from "@/lib/storage-service";
import { useI18n } from "@/lib/i18n";
import Button from "@/components/Button";
import ImageUploadField from "@/components/ImageUploadField";

export default function UploadIdPage() {
  const { user, userData, updateUserProfile } = useAuth();
  const router = useRouter();
  const { t } = useI18n();
  const [frontIdFile, setFrontIdFile] = useState<File | null>(null);
  const [backIdFile, setBackIdFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");

    if (!frontIdFile || !backIdFile) {
      setError("يرجى رفع صورة وجه البطاقة وظهر البطاقة");
      return;
    }

    if (!user) {
      setError("يجب تسجيل الدخول أولاً");
      return;
    }

    setLoading(true);
    try {
      const [frontIdUrl, backIdUrl] = await Promise.all([
        uploadIdImage(frontIdFile, user.uid, "front"),
        uploadIdImage(backIdFile, user.uid, "back"),
      ]);

      await updateUserProfile({ frontId: frontIdUrl, backId: backIdUrl });
      setSuccess(true);
      setTimeout(() => router.push("/main"), 1500);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "حدث خطأ أثناء رفع الصور";
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-lg mx-auto px-4 md:px-8 py-6">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => router.back()} className="text-gray-500 hover:text-gray-700">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
          <h1 className="text-xl font-bold text-[#21406c]">{t("uploadIdAction")}</h1>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <p className="text-sm text-gray-600 mb-4">{t("uploadIdMessage")}</p>

          {error && (
            <div className="bg-red-50 text-red-600 p-3 rounded-xl mb-4 text-sm text-center">{error}</div>
          )}
          {success && (
            <div className="bg-green-50 text-green-600 p-3 rounded-xl mb-4 text-sm text-center">
              تم رفع الصور بنجاح! جارٍ إعادة التوجيه...
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <ImageUploadField
              label={t("idFront")}
              value={frontIdFile}
              onChange={setFrontIdFile}
              previewUrl={userData?.frontId}
            />
            <ImageUploadField
              label={t("idBack")}
              value={backIdFile}
              onChange={setBackIdFile}
              previewUrl={userData?.backId}
            />
            <Button type="submit" fullWidth loading={loading}>
              {t("uploadIdAction")}
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
}
