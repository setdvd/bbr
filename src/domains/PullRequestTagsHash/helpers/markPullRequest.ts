import { PullRequestItem } from "src/domains/PullRequest";
import { PullRequestTagsHash } from "../PullRequestTagsHash";

export const markAsChecked = (
  hash: PullRequestTagsHash,
  pr: PullRequestItem
): PullRequestTagsHash => ({
  type: "pr_tags_hash",
  hash: {
    ...hash.hash,
    [pr.id]: { type: "checked", date: Date.now() },
  },
});

export const markAsUnchecked = (
  hash: PullRequestTagsHash,
  pr: PullRequestItem
): PullRequestTagsHash => ({
  type: "pr_tags_hash",
  hash: {
    ...hash.hash,
    [pr.id]: { type: "unchecked" },
  },
});

export const markAsIgnored = (
  hash: PullRequestTagsHash,
  pr: PullRequestItem
): PullRequestTagsHash => ({
  type: "pr_tags_hash",
  hash: {
    ...hash.hash,
    [pr.id]: { type: "ignored" },
  },
});
