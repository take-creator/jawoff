"use client";

import { Card, MetricCard, Notice, PrimaryButton } from "./ui";
import type { CheckLog, MorningLog, ReminderLog } from "@/lib/types";
import { formatTime, isToday } from "@/lib/date";

export function HomeScreen({
  checkLogs,
  morningLogs,
  reminderLogs,
  onCheck,
  onMorning
}: {
  checkLogs: CheckLog[];
  morningLogs: MorningLog[];
  reminderLogs: ReminderLog[];
  onCheck: () => void;
  onMorning: () => void;
}) {
  const todayChecks = checkLogs.filter((log) => isToday(log.timestamp));
  const todayReminders = reminderLogs.filter((log) => isToday(log.timestamp));
  const todayMorning = [...morningLogs].reverse().find((log) => isToday(`${log.date}T00:00:00`));
  const latestCheck = todayChecks.at(-1);

  return (
    <div className="space-y-5">
      <Card className="bg-gradient-to-br from-white to-calm-50">
        <p className="text-sm font-bold text-calm-700">今日の状態</p>
        <h2 className="mt-2 text-2xl font-bold leading-tight text-slate-950">
          唇は閉じる、歯は離す、舌は上顎
        </h2>
        <p className="mt-3 text-sm leading-6 text-slate-600">
          気づいた時に短く確認します。できていない日があっても、記録を続けることを優先しましょう。
        </p>
        <div className="mt-5">
          <PrimaryButton onClick={onCheck}>今チェックする</PrimaryButton>
        </div>
      </Card>

      <div className="grid grid-cols-2 gap-3">
        <MetricCard label="リマインダー達成" value={todayReminders.length} sub="今日の表示回数" />
        <MetricCard label="セルフチェック" value={todayChecks.length} sub="今日の記録数" />
        <MetricCard label="顎の疲労スコア" value={todayMorning?.jawFatigue ?? "-"} sub="朝ログ 0〜10" />
        <MetricCard label="最後の記録" value={latestCheck ? formatTime(latestCheck.timestamp) : "-"} sub="現在時刻で保存" />
      </div>

      {!todayMorning ? (
        <Card>
          <p className="text-sm font-bold text-slate-900">朝の症状ログが未記録です</p>
          <p className="mt-2 text-sm leading-6 text-slate-500">
            顎のだるさや睡眠の質を残すと、グラフで変化を見やすくなります。
          </p>
          <button
            type="button"
            onClick={onMorning}
            className="mt-4 w-full rounded-2xl border border-calm-500 px-4 py-3 text-sm font-bold text-calm-700"
          >
            朝ログをつける
          </button>
        </Card>
      ) : null}

      <Notice />
    </div>
  );
}
