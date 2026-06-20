import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "نسيت كلمة المرور",
  description:
    "إعادة تعيين كلمة المرور لحسابك في خطوة للأمام.",
};

export default function ForgotPasswordLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
