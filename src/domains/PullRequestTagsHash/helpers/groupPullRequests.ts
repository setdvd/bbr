import { PullRequestItem } from "src/domains/PullRequest";
import { notReachable } from "src/toolkit/notReachable";
import { PullRequestTagsHash } from "../PullRequestTagsHash";

type GroupedPRs = {
  unchecked: PullRequestItem[];
  checked: PullRequestItem[];
  ignored: PullRequestItem[];
};

export const groupPullRequests = (
  hash: PullRequestTagsHash,
  prs: PullRequestItem[]
): GroupedPRs => {
  const grouped: GroupedPRs = {
    checked: [],
    ignored: [],
    unchecked: [],
  };

  prs.forEach((pr) => {
    const tag = hash.hash[pr.id];

    if (!tag) {
      grouped.unchecked.push(pr);
      return;
    }

    switch (tag.type) {
      case "checked": {
        const prTimestamp = new Date(pr.updated_on).valueOf();
        if (tag.date >= prTimestamp) {
          grouped.checked.push(pr);
        } else {
          grouped.unchecked.push(pr);
        }
        break;
      }

      case "ignored":
        grouped.ignored.push(pr);
        break;

      case "unchecked":
        grouped.unchecked.push(pr);
        break;

      default:
        notReachable(tag);
    }
  });

  return grouped;
};
