import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "استكمال الملف الشخصي",
  description: "أكمل بياناتك الشخصية للانضمام إلى مجتمع خطوة للأمام.",
};

export default function CompleteProfileLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return children;
}
