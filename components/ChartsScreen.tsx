"use client";

import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis
} from "recharts";
import { useMemo, useState } from "react";
import type { CheckLog, MorningLog } from "@/lib/types";
import { getRecentDateKeys, shortDateLabel, toDateKey } from "@/lib/date";
import { Card } from "./ui";

export function ChartsScreen({
  checkLogs,
  morningLogs
}: {
  checkLogs: CheckLog[];
  morningLogs: MorningLog[];
}) {
  const [days, setDays] = useState<7 | 30>(7);
  const data = useMemo(() => {
    return getRecentDateKeys(days).map((date) => {
      const morning = morningLogs.find((log) => log.date === date);
      return {
        date,
        label: shortDateLabel(date),
        jawFatigue: morning?.jawFatigue ?? null,
        masseterTension: morning?.masseterTension ?? null,
        toothFatigue: morning?.toothFatigue ?? null,
        checkCount: checkLogs.filter((log) => toDateKey(new Date(log.timestamp)) === date).length
      };
    });
  }, [checkLogs, days, morningLogs]);

  return (
    <div className="space-y-5">
      <Card>
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-sm font-bold text-calm-700">グラフ</p>
            <h2 className="mt-2 text-2xl font-bold text-slate-950">推移を見る</h2>
          </div>
          <div className="flex rounded-2xl bg-slate-100 p-1">
            {[7, 30].map((value) => (
              <button
                key={value}
                type="button"
                onClick={() => setDays(value as 7 | 30)}
                className={`rounded-xl px-3 py-2 text-xs font-bold ${
                  days === value ? "bg-white text-calm-700 shadow-sm" : "text-slate-500"
                }`}
              >
                {value}日
              </button>
            ))}
          </div>
        </div>
      </Card>

      <ChartCard title="症状スコア" data={data} lines={[
        { key: "jawFatigue", name: "顎のだるさ", color: "#16a6a0" },
        { key: "masseterTension", name: "エラの張り感", color: "#2f80ed" },
        { key: "toothFatigue", name: "歯の疲れ", color: "#f59e0b" }
      ]} />

      <ChartCard title="チェック回数" data={data} lines={[
        { key: "checkCount", name: "チェック回数", color: "#0d7474" }
      ]} />
    </div>
  );
}

function ChartCard({
  title,
  data,
  lines
}: {
  title: string;
  data: Record<string, string | number | null>[];
  lines: { key: string; name: string; color: string }[];
}) {
  return (
    <Card>
      <h3 className="text-sm font-bold text-slate-900">{title}</h3>
      <div className="mt-4 h-64 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={{ top: 8, right: 8, left: -24, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
            <XAxis dataKey="label" tick={{ fontSize: 11 }} stroke="#94a3b8" />
            <YAxis tick={{ fontSize: 11 }} stroke="#94a3b8" allowDecimals={false} />
            <Tooltip
              contentStyle={{
                borderRadius: 16,
                border: "1px solid #e2e8f0",
                boxShadow: "0 10px 30px rgba(15, 23, 42, 0.08)"
              }}
            />
            {lines.map((line) => (
              <Line
                key={line.key}
                type="monotone"
                dataKey={line.key}
                name={line.name}
                stroke={line.color}
                strokeWidth={3}
                connectNulls
                dot={{ r: 3 }}
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      </div>
    </Card>
  );
}
