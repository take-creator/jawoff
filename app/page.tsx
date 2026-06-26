"use client";

import { useEffect, useMemo, useState } from "react";
import { AppShell } from "@/components/AppShell";
import { ChartsScreen } from "@/components/ChartsScreen";
import { CheckScreen } from "@/components/CheckScreen";
import { HomeScreen } from "@/components/HomeScreen";
import { LearnScreen } from "@/components/LearnScreen";
import { MorningLogScreen } from "@/components/MorningLogScreen";
import { SettingsScreen } from "@/components/SettingsScreen";
import { useLocalStorage } from "@/hooks/useLocalStorage";
import { storageDefaults } from "@/lib/storage";
import type { CheckLog, MorningLog, ReminderLog, ScreenKey, Settings } from "@/lib/types";

export default function Page() {
  const [active, setActive] = useState<ScreenKey>("home");
  const [checkLogs, setCheckLogs] = useLocalStorage("checkLogs", storageDefaults.checkLogs);
  const [morningLogs, setMorningLogs] = useLocalStorage("morningLogs", storageDefaults.morningLogs);
  const [settings, setSettings] = useLocalStorage("settings", storageDefaults.settings);
  const [reminderLogs, setReminderLogs] = useLocalStorage("reminderLogs", storageDefaults.reminderLogs);
  const [notificationPermission, setNotificationPermission] = useState<NotificationPermission | "unsupported">("default");

  useEffect(() => {
    if (!("Notification" in window)) {
      setNotificationPermission("unsupported");
      return;
    }
    setNotificationPermission(Notification.permission);
  }, []);

  useEffect(() => {
    if (!settings.notificationEnabled || notificationPermission !== "granted") return;

    const interval = window.setInterval(() => {
      new Notification("歯、触れていませんか？", {
        body: "唇は閉じる、歯は離す、舌は上顎。深呼吸を3回。",
        icon: "/icon.svg"
      });
      setReminderLogs((current) => [
        ...current,
        { id: crypto.randomUUID(), timestamp: new Date().toISOString() }
      ]);
    }, settings.reminderInterval * 60 * 1000);

    return () => window.clearInterval(interval);
  }, [notificationPermission, settings.notificationEnabled, settings.reminderInterval, setReminderLogs]);

  const screen = useMemo(() => {
    const saveCheck = (log: CheckLog) => setCheckLogs((current) => [...current, log]);
    const saveMorning = (log: MorningLog) => {
      setMorningLogs((current) => {
        const others = current.filter((item) => item.date !== log.date);
        return [...others, log].sort((a, b) => a.date.localeCompare(b.date));
      });
    };
    const updateInterval = (reminderInterval: Settings["reminderInterval"]) => {
      setSettings((current) => ({ ...current, reminderInterval }));
    };
    const requestNotification = async () => {
      if (!("Notification" in window)) {
        setNotificationPermission("unsupported");
        return;
      }
      const result = await Notification.requestPermission();
      setNotificationPermission(result);
      setSettings((current) => ({ ...current, notificationEnabled: result === "granted" }));
    };

    if (active === "check") return <CheckScreen onSave={saveCheck} />;
    if (active === "morning") return <MorningLogScreen logs={morningLogs} onSave={saveMorning} />;
    if (active === "charts") return <ChartsScreen checkLogs={checkLogs} morningLogs={morningLogs} />;
    if (active === "settings") {
      return (
        <SettingsScreen
          settings={settings}
          notificationPermission={notificationPermission}
          onIntervalChange={updateInterval}
          onRequestNotification={requestNotification}
        />
      );
    }
    if (active === "learn") return <LearnScreen />;
    return (
      <HomeScreen
        checkLogs={checkLogs}
        morningLogs={morningLogs}
        reminderLogs={reminderLogs}
        onCheck={() => setActive("check")}
        onMorning={() => setActive("morning")}
      />
    );
  }, [
    active,
    checkLogs,
    morningLogs,
    notificationPermission,
    reminderLogs,
    settings,
    setCheckLogs,
    setMorningLogs,
    setReminderLogs,
    setSettings
  ]);

  return (
    <AppShell active={active} onChange={setActive}>
      {screen}
    </AppShell>
  );
}
