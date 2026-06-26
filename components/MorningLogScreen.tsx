"use client";

import { useMemo, useState } from "react";
import type { MorningLog } from "@/lib/types";
import { toDateKey } from "@/lib/date";
import { Card, PrimaryButton, RangeField } from "./ui";

const rangeFields: { key: keyof Omit<MorningLog, "id" | "date" | "memo">; label: string }[] = [
  { key: "jawFatigue", label: "顎のだるさ" },
  { key: "masseterTension", label: "エラの張り感" },
  { key: "toothFatigue", label: "歯の疲れ" },
  { key: "headache", label: "頭痛" },
  { key: "shoulderStiffness", label: "肩こり" },
  { key: "sleepQuality", label: "睡眠の質" }
];

function emptyLog(): MorningLog {
  return {
    id: crypto.randomUUID(),
    date: toDateKey(),
    jawFatigue: 0,
    masseterTension: 0,
    toothFatigue: 0,
    headache: 0,
    shoulderStiffness: 0,
    sleepQuality: 5,
    memo: ""
  };
}

export function MorningLogScreen({
  logs,
  onSave
}: {
  logs: MorningLog[];
  onSave: (log: MorningLog) => void;
}) {
  const todaysLog = useMemo(
    () => logs.find((log) => log.date === toDateKey()),
    [logs]
  );
  const [draft, setDraft] = useState<MorningLog>(todaysLog ?? emptyLog());
  const [saved, setSaved] = useState(false);

  function updateNumber(key: keyof Omit<MorningLog, "id" | "date" | "memo">, value: number) {
    setDraft((current) => ({ ...current, [key]: value }));
  }

  function save() {
    onSave({ ...draft, date: toDateKey() });
    setSaved(true);
  }

  return (
    <div className="space-y-5">
      <Card>
        <p className="text-sm font-bold text-calm-700">朝の症状ログ</p>
        <h2 className="mt-2 text-2xl font-bold text-slate-950">起きた時の状態</h2>
        <p className="mt-2 text-sm leading-6 text-slate-500">
          0〜10でざっくり記録します。同じ基準で続けることを優先します。
        </p>
      </Card>

      <div className="space-y-3">
        {rangeFields.map((field) => (
          <RangeField
            key={field.key}
            label={field.label}
            value={draft[field.key]}
            onChange={(value) => updateNumber(field.key, value)}
          />
        ))}
      </div>

      <label className="block rounded-2xl border border-slate-100 bg-white p-4">
        <span className="text-sm font-bold text-slate-700">自由メモ</span>
        <textarea
          value={draft.memo}
          onChange={(event) => setDraft((current) => ({ ...current, memo: event.target.value }))}
          rows={4}
          placeholder="例：朝から奥歯が重い。睡眠は浅め。"
          className="mt-3 w-full resize-none rounded-2xl border border-slate-200 bg-slate-50 p-3 text-sm outline-none focus:border-calm-500 focus:bg-white"
        />
      </label>

      <PrimaryButton onClick={save}>朝ログを保存する</PrimaryButton>

      {saved ? (
        <p className="rounded-2xl bg-calm-50 p-4 text-sm font-bold text-calm-700">
          今日の朝ログを保存しました。
        </p>
      ) : null}
    </div>
  );
}
