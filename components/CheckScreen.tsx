"use client";

import { useState } from "react";
import type { CheckLog } from "@/lib/types";
import { formatTime } from "@/lib/date";
import { Card, PrimaryButton } from "./ui";

type CheckDraft = Omit<CheckLog, "id" | "timestamp">;

const items: { key: keyof CheckDraft; label: string; help: string }[] = [
  { key: "teethTouching", label: "今、上下の歯が触れていた", help: "軽く触れているだけでもオン" },
  { key: "jawTension", label: "顎に力が入っていた", help: "噛む力やこわばり" },
  { key: "tonguePosition", label: "舌は上顎についていた", help: "リラックスした置き場所" },
  { key: "shoulderTension", label: "肩・首に力が入っていた", help: "姿勢や緊張も一緒に確認" },
  { key: "stress", label: "ストレスを感じていた", help: "集中・焦り・考えごと" }
];

const initialDraft: CheckDraft = {
  teethTouching: false,
  jawTension: false,
  tonguePosition: true,
  shoulderTension: false,
  stress: false
};

export function CheckScreen({
  onSave
}: {
  onSave: (log: CheckLog) => void;
}) {
  const [draft, setDraft] = useState<CheckDraft>(initialDraft);
  const [savedAt, setSavedAt] = useState<string | null>(null);

  function save() {
    const timestamp = new Date().toISOString();
    onSave({
      id: crypto.randomUUID(),
      timestamp,
      ...draft
    });
    setSavedAt(timestamp);
    setDraft(initialDraft);
  }

  return (
    <div className="space-y-5">
      <Card>
        <p className="text-sm font-bold text-calm-700">食いしばりチェック</p>
        <h2 className="mt-2 text-2xl font-bold text-slate-950">今の状態を確認</h2>
        <p className="mt-2 text-sm leading-6 text-slate-500">
          正解を探す画面ではありません。気づく回数を増やすための短い記録です。
        </p>
      </Card>

      <div className="space-y-3">
        {items.map((item) => {
          const active = draft[item.key];
          return (
            <button
              key={item.key}
              type="button"
              onClick={() => setDraft((current) => ({ ...current, [item.key]: !active }))}
              className={`w-full rounded-2xl border p-4 text-left transition ${
                active
                  ? "border-calm-500 bg-calm-50"
                  : "border-slate-100 bg-white"
              }`}
            >
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="text-sm font-bold text-slate-900">{item.label}</p>
                  <p className="mt-1 text-xs text-slate-500">{item.help}</p>
                </div>
                <span
                  className={`grid h-7 w-12 place-items-center rounded-full text-xs font-bold ${
                    active ? "bg-calm-500 text-white" : "bg-slate-100 text-slate-500"
                  }`}
                >
                  {active ? "ON" : "OFF"}
                </span>
              </div>
            </button>
          );
        })}
      </div>

      <PrimaryButton onClick={save}>現在時刻で記録する</PrimaryButton>

      {savedAt ? (
        <Card className="border-calm-100 bg-calm-50">
          <p className="text-sm font-bold text-calm-700">{formatTime(savedAt)} に記録しました</p>
          <ul className="mt-3 space-y-2 text-sm leading-6 text-slate-700">
            <li>唇は閉じる、歯は離す、舌は上顎</li>
            <li>深呼吸3回</li>
            <li>顎・肩の力を抜く</li>
          </ul>
        </Card>
      ) : null}
    </div>
  );
}
