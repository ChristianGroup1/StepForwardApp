import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "إنشاء حساب جديد",
  description:
    "انضم إلى مجتمع خطوة للأمام - سجل الآن واكتشف ألعاب الخدمة وتواصل مع خدام الكنيسة.",
};

export default function SignupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
