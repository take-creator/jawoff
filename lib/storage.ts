import type { CheckLog, MorningLog, ReminderLog, Settings } from "./types";

export const defaultSettings: Settings = {
  reminderInterval: 60,
  notificationEnabled: false
};

export const storageDefaults = {
  checkLogs: [] as CheckLog[],
  morningLogs: [] as MorningLog[],
  settings: defaultSettings,
  reminderLogs: [] as ReminderLog[]
};
