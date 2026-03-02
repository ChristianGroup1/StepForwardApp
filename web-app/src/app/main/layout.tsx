import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "الرئيسية",
  description:
    "لوحة التحكم الرئيسية - اكتشف الألعاب والخدام والكتب في خطوة للأمام.",
};

export default function MainLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
