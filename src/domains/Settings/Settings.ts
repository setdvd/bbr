import { MergeStrategy } from "src/domains/MergeStrategy";

export type Settings = {
  numberOfApproves: number;
  numberOfBuilds: number;
  openTasks: boolean;
  pollIntervalMinutes: number;
  mergeStrategy: MergeStrategy;
};

export const defaultSettings: Settings = {
  numberOfApproves: 1,
  numberOfBuilds: 2,
  openTasks: true,
  pollIntervalMinutes: 10,
  mergeStrategy: "merge",
};

const STORAGE_KEY = "SETTINGS";

// TODO: add parsing and default for new settings (migration of local storage)
export const getSettings = (): Settings => {
  return (
    JSON.parse(localStorage.getItem(STORAGE_KEY) || "null") || defaultSettings
  );
};

export const saveSettings = (settings: Settings): void => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(settings));
};
