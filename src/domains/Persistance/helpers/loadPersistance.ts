import { Persistance, LOCAL_STORAGE_KEY } from "../Persistance";

export const loadPersistance = (): Persistance => {
  const defaultData: Persistance = {
    pullRequestTagsHash: { type: "pr_tags_hash", hash: {} }, // TODO call constructor here
  };

  try {
    const data = localStorage.getItem(LOCAL_STORAGE_KEY);
    return data ? JSON.parse(data) : defaultData;
  } catch (e) {
    return defaultData;
  }
};
