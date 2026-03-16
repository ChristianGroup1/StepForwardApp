'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';

const PACKAGE   = 'com.stepforward';
const PLAY_URL  = `https://play.google.com/store/apps/details?id=${PACKAGE}`;
const STORE_URL = 'https://apps.apple.com/app/id6742620580';

type Platform = 'android' | 'ios' | 'other';

export default function GamePage() {
  const { id: gameId } = useParams<{ id: string }>();

  const [appLink, setAppLink]     = useState('');
  const [platform, setPlatform]   = useState<Platform>('other');
  const [showStores, setShowStores] = useState(false);

  useEffect(() => {
    if (!gameId) return;

    const ua       = navigator.userAgent;
    const android  = /android/i.test(ua);
    const ios      = /iphone|ipad|ipod/i.test(ua);
    const plat: Platform = android ? 'android' : ios ? 'ios' : 'other';
    setPlatform(plat);

    /*
     * Android Chrome: intent:// URI is the most reliable way to open an app
     * from the browser. It includes a built-in Play Store fallback via
     * S.browser_fallback_url so users without the app are sent to the store.
     *
     * iOS Safari / all others: fall back to the stepforward:// custom scheme.
     */
    const link = android
      ? `intent://game/${gameId}#Intent;scheme=stepforward;package=${PACKAGE};S.browser_fallback_url=${encodeURIComponent(PLAY_URL)};end`
      : `stepforward://game/${gameId}`;

    setAppLink(link);

    // Auto-open the app 250 ms after mount.
    const openTimer  = setTimeout(() => { window.location.href = link; }, 250);
    // Show store badges after 2 s (in case the app is not installed).
    const storeTimer = setTimeout(() => setShowStores(true), 2000);

    return () => {
      clearTimeout(openTimer);
      clearTimeout(storeTimer);
    };
  }, [gameId]);

  if (!gameId) {
    return (
      <div style={s.page}>
        <div style={s.card}>
          <div style={s.logo}>🎮</div>
          <h1 style={s.title}>Invalid link</h1>
          <p  style={s.desc}>This link does not contain a valid game ID.</p>
        </div>
      </div>
    );
  }

  return (
    <div style={s.page}>
      <div style={s.card}>
        <div style={s.logo}>🎮</div>
        <h1 style={s.title}>Opening game…</h1>
        <p  style={s.desc}>Tap the button below if the app does not open automatically.</p>

        <a href={appLink || '#'} style={s.btn}>Open in Step Forward</a>

        {showStores && (
          <div style={s.stores}>
            {platform !== 'ios' && (
              <a href={PLAY_URL}  style={s.btnStore}>📱 Google Play</a>
            )}
            {platform !== 'android' && (
              <a href={STORE_URL} style={s.btnStore}>🍎 App Store</a>
            )}
          </div>
        )}

        <p style={s.hint}>App not installed? Download it from the store above.</p>
      </div>
    </div>
  );
}

/* ── styles ─────────────────────────────────────────────────────────────── */
const s: Record<string, React.CSSProperties> = {
  page: {
    fontFamily: "'Cairo', 'Segoe UI', Tahoma, sans-serif",
    background: '#f0f4ff',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: '100vh',
    padding: '24px',
    boxSizing: 'border-box',
  },
  card: {
    background: '#fff',
    borderRadius: '20px',
    padding: '40px 32px 32px',
    textAlign: 'center',
    maxWidth: '380px',
    width: '100%',
    boxShadow: '0 8px 32px rgba(26, 115, 232, 0.12)',
  },
  logo:     { fontSize: '56px', marginBottom: '20px' },
  title:    { fontSize: '22px', fontWeight: 700, color: '#1a1a2e', marginBottom: '10px' },
  desc:     { fontSize: '15px', color: '#666', lineHeight: 1.65, marginBottom: '28px' },
  btn: {
    display: 'block',
    background: '#1a73e8',
    color: '#fff',
    borderRadius: '12px',
    padding: '15px 24px',
    fontSize: '16px',
    fontWeight: 700,
    textDecoration: 'none',
    cursor: 'pointer',
  },
  stores:   { marginTop: '20px' },
  btnStore: {
    display: 'inline-block',
    background: 'transparent',
    border: '2px solid #1a73e8',
    color: '#1a73e8',
    borderRadius: '10px',
    padding: '10px 20px',
    fontSize: '14px',
    fontWeight: 600,
    textDecoration: 'none',
    margin: '6px 4px 0',
    cursor: 'pointer',
  },
  hint: { marginTop: '16px', fontSize: '13px', color: '#999' },
};
