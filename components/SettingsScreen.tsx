"use client";

import type { Settings } from "@/lib/types";
import { Card, Notice } from "./ui";

export function SettingsScreen({
  settings,
  notificationPermission,
  onIntervalChange,
  onRequestNotification
}: {
  settings: Settings;
  notificationPermission: NotificationPermission | "unsupported";
  onIntervalChange: (value: Settings["reminderInterval"]) => void;
  onRequestNotification: () => void;
}) {
  return (
    <div className="space-y-5">
      <Card>
        <p className="text-sm font-bold text-calm-700">設定</p>
        <h2 className="mt-2 text-2xl font-bold text-slate-950">リマインダー</h2>
        <p className="mt-2 text-sm leading-6 text-slate-500">
          MVPではアプリを開いている間に通知します。表示文言は「歯、触れていませんか？」です。
        </p>
      </Card>

      <Card>
        <h3 className="text-sm font-bold text-slate-900">通知間隔</h3>
        <div className="mt-4 grid grid-cols-3 gap-2">
          {[
            { label: "30分", value: 30 },
            { label: "1時間", value: 60 },
            { label: "2時間", value: 120 }
          ].map((item) => (
            <button
              key={item.value}
              type="button"
              onClick={() => onIntervalChange(item.value as Settings["reminderInterval"])}
              className={`rounded-2xl px-3 py-4 text-sm font-bold ${
                settings.reminderInterval === item.value
                  ? "bg-calm-500 text-white"
                  : "bg-slate-50 text-slate-600"
              }`}
            >
              {item.label}
            </button>
          ))}
        </div>
      </Card>

      <Card>
        <h3 className="text-sm font-bold text-slate-900">ブラウザ通知</h3>
        <p className="mt-2 text-sm leading-6 text-slate-500">
          許可すると、アプリ起動中に設定した間隔でやさしく確認します。
        </p>
        <div className="mt-4 rounded-2xl bg-slate-50 p-4 text-sm text-slate-600">
          現在の状態: <span className="font-bold">{labelPermission(notificationPermission)}</span>
        </div>
        {notificationPermission !== "granted" ? (
          <button
            type="button"
            onClick={onRequestNotification}
            disabled={notificationPermission === "unsupported"}
            className="mt-4 w-full rounded-2xl border border-calm-500 px-4 py-3 text-sm font-bold text-calm-700 disabled:border-slate-200 disabled:text-slate-400"
          >
            通知を許可する
          </button>
        ) : (
          <p className="mt-4 rounded-2xl bg-calm-50 p-4 text-sm font-bold text-calm-700">
            通知が有効です。
          </p>
        )}
      </Card>

      <Notice />
    </div>
  );
}

function labelPermission(permission: NotificationPermission | "unsupported") {
  if (permission === "granted") return "許可済み";
  if (permission === "denied") return "ブロック中";
  if (permission === "default") return "未設定";
  return "このブラウザでは未対応";
}
