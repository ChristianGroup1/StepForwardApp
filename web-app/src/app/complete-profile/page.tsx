"use client";

import { useState, FormEvent, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Image from "next/image";
import { useAuth } from "@/lib/auth-context";
import { uploadIdImage } from "@/lib/storage-service";
import Button from "@/components/Button";
import TextField from "@/components/TextField";
import SelectField from "@/components/SelectField";
import ImageUploadField from "@/components/ImageUploadField";
import { governments } from "@/lib/constants";
import LoadingSpinner from "@/components/LoadingSpinner";

function CompleteProfileForm() {
  const { completeGoogleSignUp, updateUserProfile } = useAuth();
  const router = useRouter();
  const params = useSearchParams();
  const uid = params.get("uid") || "";
  const emailParam = params.get("email") || "";
  const nameParam = params.get("name") || "";

  const nameParts = nameParam.split(" ");
  const [firstName, setFirstName] = useState(nameParts[0] || "");
  const [lastName, setLastName] = useState(nameParts.slice(1).join(" ") || "");
  const [phone, setPhone] = useState("");
  const [government, setGovernment] = useState("");
  const [churchName, setChurchName] = useState("");
  const [frontIdFile, setFrontIdFile] = useState<File | null>(null);
  const [backIdFile, setBackIdFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");

    if (!firstName || !lastName || !phone || !government || !churchName) {
      setError("يرجى ملء جميع الحقول المطلوبة");
      return;
    }

    if (!frontIdFile || !backIdFile) {
      setError("يرجى رفع صورة وجه البطاقة وظهر البطاقة");
      return;
    }

    setLoading(true);
    try {
      // Upload ID images
      const [frontIdUrl, backIdUrl] = await Promise.all([
        uploadIdImage(frontIdFile, uid, "front"),
        uploadIdImage(backIdFile, uid, "back"),
      ]);

      await completeGoogleSignUp({
        id: uid,
        firstName,
        lastName,
        email: emailParam,
        phoneNumber: phone,
        government,
        churchName,
        isApproved: false,
        frontId: frontIdUrl,
        backId: backIdUrl,
        favorites: [],
      });

      // Update with ID URLs
      await updateUserProfile({ frontId: frontIdUrl, backId: backIdUrl });

      router.push("/main");
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "حدث خطأ أثناء إكمال الملف الشخصي";
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4 py-8">
      <div className="w-full max-w-md">
        <div className="text-center mb-6">
          <Image
            src="/step_forward_logo.png"
            alt="Step Forward"
            width={80}
            height={80}
            className="mx-auto mb-3"
          />
          <h1 className="text-2xl font-bold text-[#21406c]">استكمال الملف الشخصي</h1>
          <p className="text-gray-500 mt-1">أكمل بياناتك للمتابعة</p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          {error && (
            <div className="bg-red-50 text-red-600 p-3 rounded-xl mb-4 text-sm text-center">{error}</div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <TextField
                label="الاسم الأول"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
              />
              <TextField
                label="الاسم الأخير"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
              />
            </div>

            <TextField label="البريد الإلكتروني" value={emailParam} disabled dir="ltr" />

            <TextField
              label="رقم الهاتف"
              type="tel"
              placeholder="01xxxxxxxxx"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              dir="ltr"
            />

            <SelectField
              label="المحافظة"
              placeholder="اختر المحافظة"
              value={government}
              onChange={(e) => setGovernment(e.target.value)}
              options={governments.map((g) => ({ value: g, label: g }))}
            />

            <TextField
              label="اسم الكنيسة"
              placeholder="اسم الكنيسة"
              value={churchName}
              onChange={(e) => setChurchName(e.target.value)}
            />

            {/* ID Verification Images */}
            <div className="pt-2">
              <p className="text-sm font-semibold text-[#21406c] mb-3">صور البطاقة للتحقق من الهوية</p>
              <div className="space-y-3">
                <ImageUploadField
                  label="وجه البطاقة"
                  value={frontIdFile}
                  onChange={setFrontIdFile}
                />
                <ImageUploadField
                  label="ظهر البطاقة"
                  value={backIdFile}
                  onChange={setBackIdFile}
                />
              </div>
            </div>

            <Button type="submit" fullWidth loading={loading}>
              إكمال التسجيل
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default function CompleteProfilePage() {
  return (
    <Suspense fallback={<LoadingSpinner size="lg" />}>
      <CompleteProfileForm />
    </Suspense>
  );
}
