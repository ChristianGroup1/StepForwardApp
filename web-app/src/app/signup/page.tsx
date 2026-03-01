"use client";

import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import Button from "@/components/Button";
import TextField from "@/components/TextField";
import SelectField from "@/components/SelectField";
import { governments } from "@/lib/constants";

export default function SignUpPage() {
  const { signUp } = useAuth();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [government, setGovernment] = useState("");
  const [churchName, setChurchName] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");

    if (!firstName || !lastName || !email || !phone || !government || !churchName || !password) {
      setError("يرجى ملء جميع الحقول المطلوبة");
      return;
    }

    if (password !== confirmPassword) {
      setError("كلمتا المرور غير متطابقتين");
      return;
    }

    if (password.length < 6) {
      setError("كلمة المرور يجب أن تكون 6 أحرف على الأقل");
      return;
    }

    setLoading(true);
    try {
      await signUp(email, password, {
        firstName,
        lastName,
        email,
        phoneNumber: phone,
        government,
        churchName,
        isApproved: false,
        favorites: [],
      });
      router.push("/main");
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "حدث خطأ أثناء إنشاء الحساب";
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
          <h1 className="text-2xl font-bold text-[#21406c]">إنشاء حساب جديد</h1>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          {error && (
            <div className="bg-red-50 text-red-600 p-3 rounded-xl mb-4 text-sm text-center">{error}</div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <TextField
                label="الاسم الأول"
                placeholder="الاسم الأول"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
              />
              <TextField
                label="الاسم الأخير"
                placeholder="الاسم الأخير"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
              />
            </div>

            <TextField
              label="البريد الإلكتروني"
              type="email"
              placeholder="example@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              dir="ltr"
            />

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

            <TextField
              label="كلمة المرور"
              isPassword
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              dir="ltr"
            />

            <TextField
              label="تأكيد كلمة المرور"
              isPassword
              placeholder="••••••••"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              dir="ltr"
            />

            <Button type="submit" fullWidth loading={loading}>
              إنشاء الحساب
            </Button>
          </form>

          <p className="text-center mt-6 text-sm text-gray-500">
            لديك حساب بالفعل؟{" "}
            <Link href="/login" className="text-[#21406c] font-semibold hover:underline">
              تسجيل الدخول
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
