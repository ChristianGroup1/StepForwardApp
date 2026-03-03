import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "تسجيل الدخول",
  description:
    "سجل الدخول إلى حسابك في خطوة للأمام للوصول إلى ألعاب الخدمة والتواصل مع الخدام.",
};

export default function LoginLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
