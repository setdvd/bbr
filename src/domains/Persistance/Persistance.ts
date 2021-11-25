import { PullRequestTagsHash } from "src/domains/PullRequestTagsHash";

export const LOCAL_STORAGE_KEY = "persistance";

export type Persistance = {
  pullRequestTagsHash: PullRequestTagsHash;
};
