import { MergeStrategy } from "src/domains/MergeStrategy";

export type Settings = {
  numberOfApproves: number;
  numberOfBuilds: number;
  openTasks: boolean;
  pollIntervalMinutes: number;
  mergeStrategy: MergeStrategy;
  reviewByUserUUID: string;
  reviewInWorkspace: string;
  reviewInRepo: string;
};

export const defaultSettings: Settings = {
  numberOfApproves: 1,
  numberOfBuilds: 2,
  openTasks: true,
  pollIntervalMinutes: 10,
  mergeStrategy: "merge",
  reviewByUserUUID: "",
  reviewInRepo: "",
  reviewInWorkspace: "",
};
