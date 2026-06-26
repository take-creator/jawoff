"use client";

import type { ReactNode } from "react";
import type { ScreenKey } from "@/lib/types";

const tabs: { key: ScreenKey; label: string; icon: string }[] = [
  { key: "home", label: "ホーム", icon: "H" },
  { key: "check", label: "チェック", icon: "✓" },
  { key: "morning", label: "朝ログ", icon: "M" },
  { key: "charts", label: "グラフ", icon: "G" },
  { key: "settings", label: "設定", icon: "S" },
  { key: "learn", label: "学習", icon: "i" }
];

export function AppShell({
  active,
  onChange,
  children
}: {
  active: ScreenKey;
  onChange: (screen: ScreenKey) => void;
  children: ReactNode;
}) {
  return (
    <main className="mx-auto min-h-screen max-w-md bg-[#f7fbfd] pb-24">
      <header className="sticky top-0 z-20 border-b border-slate-100 bg-white/90 px-5 py-4 backdrop-blur">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.22em] text-calm-700">JawOff</p>
            <h1 className="text-xl font-bold text-slate-950">歯を離す</h1>
          </div>
          <div className="rounded-full bg-calm-50 px-3 py-2 text-xs font-bold text-calm-700">
            TCHセルフケア
          </div>
        </div>
      </header>

      <div className="px-5 py-5">{children}</div>

      <nav className="fixed inset-x-0 bottom-0 z-30 mx-auto max-w-md border-t border-slate-100 bg-white/95 px-2 pb-[max(0.5rem,env(safe-area-inset-bottom))] pt-2 backdrop-blur">
        <div className="grid grid-cols-6 gap-1">
          {tabs.map((tab) => {
            const selected = active === tab.key;
            return (
              <button
                key={tab.key}
                type="button"
                onClick={() => onChange(tab.key)}
                className={`rounded-2xl px-1 py-2 text-center transition ${
                  selected ? "bg-calm-50 text-calm-700" : "text-slate-500"
                }`}
              >
                <span className="block text-lg leading-5">{tab.icon}</span>
                <span className="mt-1 block text-[10px] font-bold">{tab.label}</span>
              </button>
            );
          })}
        </div>
      </nav>
    </main>
  );
}
