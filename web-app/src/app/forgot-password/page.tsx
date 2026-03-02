"use client";

import { useState, FormEvent } from "react";
import Image from "next/image";
import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import Button from "@/components/Button";
import TextField from "@/components/TextField";

export default function ForgotPasswordPage() {
  const { resetPassword } = useAuth();
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState("");
  const [countdown, setCountdown] = useState(0);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");
    if (!email) {
      setError("يرجى إدخال البريد الإلكتروني");
      return;
    }
    setLoading(true);
    try {
      await resetPassword(email);
      setSent(true);
      setCountdown(60);
      const timer = setInterval(() => {
        setCountdown((prev) => {
          if (prev <= 1) {
            clearInterval(timer);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "حدث خطأ أثناء إرسال رابط إعادة تعيين كلمة المرور";
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex">
      {/* Branded side panel - desktop only */}
      <div className="hidden lg:flex lg:w-1/2 xl:w-2/5 bg-gradient-to-b from-[#21406c] to-[#415a81] items-center justify-center p-12">
        <div className="text-center text-white max-w-sm">
          <Image
            src="/step_forward_logo.png"
            alt="Step Forward"
            width={160}
            height={160}
            className="mx-auto mb-6 brightness-0 invert"
          />
          <h1 className="text-3xl font-bold mb-3">خطوة للأمام</h1>
          <p className="text-white/80 text-lg">مجتمع خدام الكنيسة</p>
        </div>
      </div>

      {/* Form side */}
      <div className="flex-1 flex items-center justify-center bg-gray-50 px-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-8 lg:hidden">
            <Image
              src="/step_forward_logo.png"
              alt="Step Forward"
              width={100}
              height={100}
              className="mx-auto mb-4"
            />
            <h1 className="text-2xl font-bold text-[#21406c]">نسيت كلمة المرور</h1>
            <p className="text-gray-500 mt-1">أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور</p>
          </div>

          <div className="hidden lg:block mb-8">
            <h2 className="text-2xl font-bold text-[#21406c]">نسيت كلمة المرور</h2>
            <p className="text-gray-500 mt-1">أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور</p>
          </div>

        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          {error && (
            <div className="bg-red-50 text-red-600 p-3 rounded-xl mb-4 text-sm text-center">{error}</div>
          )}

          {sent && (
            <div className="bg-green-50 text-green-600 p-3 rounded-xl mb-4 text-sm text-center">
              تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <TextField
              label="البريد الإلكتروني"
              type="email"
              placeholder="example@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              dir="ltr"
            />

            <Button type="submit" fullWidth loading={loading} disabled={countdown > 0}>
              {countdown > 0 ? `إعادة الإرسال بعد ${countdown} ثانية` : "إرسال رابط إعادة التعيين"}
            </Button>
          </form>

          <p className="text-center mt-6 text-sm text-gray-500">
            <Link href="/login" className="text-[#21406c] font-semibold hover:underline">
              العودة لتسجيل الدخول
            </Link>
          </p>
        </div>
      </div>
      </div>
    </div>
  );
}
