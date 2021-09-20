type Link = {
  href: string;
};

type Links = {
  self: Link;
  html: Link;
  commits: Link;
  approve: Link;
  diff: Link;
  diffstat: Link;
  comments: Link;
  activity: Link;
  merge: Link;
  decline: Link;
  "request-changes": Link;
  statuses: Link;
};

export type PullRequestItem = {
  id: string;

  title: string;

  links: Links;
};

export type PullRequest = {
  id: string;
  participants: Participant[];
  author: { account_id: string };
  state: "MERGED" | "SUPERSEDED" | "OPEN" | "DECLINED";
  links: Links;
};

export type Participant = {
  type: "participant";
  state: "approved" | "changes_requested" | "no_actions_yet";
  user: {
    account_id: string;
  };
};
