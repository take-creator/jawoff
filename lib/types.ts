export type CheckLog = {
  id: string;
  timestamp: string;
  teethTouching: boolean;
  jawTension: boolean;
  tonguePosition: boolean;
  shoulderTension: boolean;
  stress: boolean;
};

export type MorningLog = {
  id: string;
  date: string;
  jawFatigue: number;
  masseterTension: number;
  toothFatigue: number;
  headache: number;
  shoulderStiffness: number;
  sleepQuality: number;
  memo: string;
};

export type Settings = {
  reminderInterval: 30 | 60 | 120;
  notificationEnabled: boolean;
};

export type ReminderLog = {
  id: string;
  timestamp: string;
};

export type ScreenKey = "home" | "check" | "morning" | "charts" | "settings" | "learn";
