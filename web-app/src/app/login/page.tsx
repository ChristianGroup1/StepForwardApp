"use client";

import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import { useAuth } from "@/lib/auth-context";
import Button from "@/components/Button";
import TextField from "@/components/TextField";

export default function LoginPage() {
  const { login, signInWithGoogle } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);
  const [error, setError] = useState("");

  const handleLogin = async (e: FormEvent) => {
    e.preventDefault();
    setError("");
    if (!email || !password) {
      setError("يرجى ملء جميع الحقول");
      return;
    }
    setLoading(true);
    try {
      await login(email, password);
      router.push("/main");
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "حدث خطأ أثناء تسجيل الدخول";
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignIn = async () => {
    setError("");
    setGoogleLoading(true);
    try {
      const result = await signInWithGoogle();
      if (result.isNewUser) {
        router.push(`/complete-profile?uid=${result.user.uid}&email=${result.user.email}&name=${result.user.displayName || ""}`);
      } else {
        router.push("/main");
      }
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : "حدث خطأ أثناء تسجيل الدخول بجوجل";
      setError(message);
    } finally {
      setGoogleLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <Image
            src="/step_forward_logo.png"
            alt="Step Forward"
            width={120}
            height={120}
            className="mx-auto mb-4"
          />
          <h1 className="text-2xl font-bold text-[#21406c]">خطوة للأمام</h1>
          <p className="text-gray-500 mt-1">تسجيل الدخول</p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          {error && (
            <div className="bg-red-50 text-red-600 p-3 rounded-xl mb-4 text-sm text-center">{error}</div>
          )}

          <form onSubmit={handleLogin} className="space-y-4">
            <TextField
              label="البريد الإلكتروني"
              type="email"
              placeholder="example@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              dir="ltr"
            />
            <TextField
              label="كلمة المرور"
              isPassword
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              dir="ltr"
            />

            <div className="text-start">
              <Link href="/forgot-password" className="text-sm text-[#21406c] hover:underline">
                نسيت كلمة المرور؟
              </Link>
            </div>

            <Button type="submit" fullWidth loading={loading}>
              تسجيل الدخول
            </Button>
          </form>

          <div className="my-6 flex items-center gap-3">
            <div className="flex-1 h-px bg-gray-200" />
            <span className="text-sm text-gray-400">أو</span>
            <div className="flex-1 h-px bg-gray-200" />
          </div>

          <Button
            variant="outline"
            fullWidth
            loading={googleLoading}
            onClick={handleGoogleSignIn}
            className="flex items-center justify-center gap-3"
          >
            <Image src="/google_icon.svg" alt="Google" width={20} height={20} />
            تسجيل الدخول بجوجل
          </Button>

          <p className="text-center mt-6 text-sm text-gray-500">
            ليس لديك حساب؟{" "}
            <Link href="/signup" className="text-[#21406c] font-semibold hover:underline">
              إنشاء حساب
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
