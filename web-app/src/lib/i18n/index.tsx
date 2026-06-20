"use client";

import React, { createContext, useContext, useState, useCallback, useSyncExternalStore } from "react";
import { ar, TranslationKeys } from "./ar";
import { en } from "./en";

export type Locale = "ar" | "en";

const translations: Record<Locale, Record<TranslationKeys, string>> = { ar, en };

interface I18nContextType {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  t: (key: TranslationKeys) => string;
  dir: "rtl" | "ltr";
}

const I18nContext = createContext<I18nContextType | undefined>(undefined);

const LOCALE_STORAGE_KEY = "stepforward_locale";

function getStoredLocale(): Locale {
  if (typeof window === "undefined") return "ar";
  const saved = localStorage.getItem(LOCALE_STORAGE_KEY) as Locale | null;
  return saved === "ar" || saved === "en" ? saved : "ar";
}

function subscribeToStorage(callback: () => void) {
  window.addEventListener("storage", callback);
  return () => window.removeEventListener("storage", callback);
}

export function I18nProvider({ children }: { children: React.ReactNode }) {
  const initialLocale = useSyncExternalStore(subscribeToStorage, getStoredLocale, () => "ar" as Locale);
  const [locale, setLocaleState] = useState<Locale>(initialLocale);

  const setLocale = useCallback((newLocale: Locale) => {
    setLocaleState(newLocale);
    localStorage.setItem(LOCALE_STORAGE_KEY, newLocale);
  }, []);

  const t = useCallback(
    (key: TranslationKeys) => translations[locale][key] || key,
    [locale]
  );

  const dir = locale === "ar" ? "rtl" : "ltr";

  return (
    <I18nContext.Provider value={{ locale, setLocale, t, dir }}>
      {children}
    </I18nContext.Provider>
  );
}

export function useI18n() {
  const context = useContext(I18nContext);
  if (!context) throw new Error("useI18n must be used within I18nProvider");
  return context;
}
