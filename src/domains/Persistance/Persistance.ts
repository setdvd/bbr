import { PullRequestTagsHash } from "src/domains/PullRequestTagsHash";
import { Settings } from "src/domains/Settings";

export const LOCAL_STORAGE_KEY = "persistance";

export type Persistance = {
  pullRequestTagsHash: PullRequestTagsHash;
  settings: Settings;
};
