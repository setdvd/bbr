import { defaultSettings } from "src/domains/Settings";
import { Persistance, LOCAL_STORAGE_KEY } from "../Persistance";

export const loadPersistance = (): Persistance => {
  const defaultData: Persistance = {
    pullRequestTagsHash: { type: "pr_tags_hash", hash: {} }, // TODO call constructor here
    settings: defaultSettings,
  };

  try {
    const data = localStorage.getItem(LOCAL_STORAGE_KEY);
    const parsedData = data ? JSON.parse(data) : {};
    return { ...defaultData, ...parsedData };
  } catch (e) {
    return defaultData;
  }
};
