export type Commit = {
  hash: string;
  links: {
    statuses: { href: string };
  };
};

export type CommitStatus = {
  state: "SUCCESSFUL" | "INPROGRESS" | "FAILED" | "STOPPED";
  url: string;
  key: string;
};
