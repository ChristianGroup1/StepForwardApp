import type { Metadata, Viewport } from "next";
import "./globals.css";
import { AuthProvider } from "@/lib/auth-context";

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://step-forward.app";

export const viewport: Viewport = {
  themeColor: "#21406c",
  width: "device-width",
  initialScale: 1,
};

export const metadata: Metadata = {
  title: {
    default: "Step Forward - خطوة للأمام",
    template: "%s | خطوة للأمام",
  },
  description:
    "خطوة للأمام - مجتمع خدام الكنيسة. اكتشف ألعاب الخدمة، تواصل مع الخدام، وتصفح الكتب والموارد المفيدة لخدمتك.",
  keywords: [
    "خطوة للأمام",
    "خدام الكنيسة",
    "ألعاب خدمة",
    "كنيسة",
    "Step Forward",
    "church servants",
  ],
  authors: [{ name: "Step Forward" }],
  metadataBase: new URL(siteUrl),
  openGraph: {
    type: "website",
    locale: "ar_EG",
    url: siteUrl,
    siteName: "خطوة للأمام - Step Forward",
    title: "Step Forward - خطوة للأمام",
    description:
      "مجتمع خدام الكنيسة. اكتشف ألعاب الخدمة، تواصل مع الخدام، وتصفح الكتب والموارد المفيدة.",
    images: [
      {
        url: "/step_forward_logo.png",
        width: 512,
        height: 512,
        alt: "Step Forward - خطوة للأمام",
      },
    ],
  },
  twitter: {
    card: "summary",
    title: "Step Forward - خطوة للأمام",
    description:
      "مجتمع خدام الكنيسة. اكتشف ألعاب الخدمة، تواصل مع الخدام، وتصفح الموارد المفيدة.",
    images: ["/step_forward_logo.png"],
  },
  icons: {
    icon: "/favicon.ico",
    apple: "/step_forward_logo.png",
  },
  manifest: "/manifest.json",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl">
      <head>
        <link
          href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  );
}
