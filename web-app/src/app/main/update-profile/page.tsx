"use client";

import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import Button from "@/components/Button";
import TextField from "@/components/TextField";
import SelectField from "@/components/SelectField";
import { governments } from "@/lib/constants";

export default function UpdateProfilePage() {
  const { userData, updateUserProfile } = useAuth();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const [firstName, setFirstName] = useState(userData?.firstName || "");
  const [lastName, setLastName] = useState(userData?.lastName || "");
  const [phone, setPhone] = useState(userData?.phoneNumber || "");
  const [government, setGovernment] = useState(userData?.government || "");
  const [churchName, setChurchName] = useState(userData?.churchName || "");

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");
    setSuccess(false);

    if (!firstName || !lastName) {
      setError("يرجى ملء الحقول المطلوبة");
      return;
    }

    setLoading(true);
    try {
      await updateUserProfile({
        firstName,
        lastName,
        phoneNumber: phone,
        government,
        churchName,
      });
      setSuccess(true);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "حدث خطأ أثناء تحديث البيانات";
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-md mx-auto px-4 py-6">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => router.back()} className="text-gray-500 hover:text-gray-700">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
          <h1 className="text-xl font-bold text-[#21406c]">تعديل الملف الشخصي</h1>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          {error && (
            <div className="bg-red-50 text-red-600 p-3 rounded-xl mb-4 text-sm text-center">{error}</div>
          )}
          {success && (
            <div className="bg-green-50 text-green-600 p-3 rounded-xl mb-4 text-sm text-center">
              تم تحديث البيانات بنجاح
            </div>
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

            <TextField label="البريد الإلكتروني" value={userData?.email || ""} disabled dir="ltr" />

            <TextField
              label="رقم الهاتف"
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              dir="ltr"
            />

            <SelectField
              label="المحافظة"
              value={government}
              onChange={(e) => setGovernment(e.target.value)}
              options={governments.map((g) => ({ value: g, label: g }))}
            />

            <TextField
              label="اسم الكنيسة"
              value={churchName}
              onChange={(e) => setChurchName(e.target.value)}
            />

            <Button type="submit" fullWidth loading={loading}>
              حفظ التغييرات
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
}
