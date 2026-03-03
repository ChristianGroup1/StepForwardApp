"use client";

import { useEffect } from "react";
import { useI18n } from "@/lib/i18n";

export function RootShell({ children }: { children: React.ReactNode }) {
  const { locale, dir } = useI18n();

  useEffect(() => {
    document.documentElement.lang = locale;
    document.documentElement.dir = dir;
  }, [locale, dir]);

  return <>{children}</>;
}

