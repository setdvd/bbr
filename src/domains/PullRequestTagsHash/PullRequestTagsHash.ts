type Tag =
  | { type: "checked"; date: number }
  | { type: "unchecked" }
  | { type: "ignored" };

export type PullRequestTagsHash = {
  type: "pr_tags_hash";
  hash: Record<string, Tag>;
};
