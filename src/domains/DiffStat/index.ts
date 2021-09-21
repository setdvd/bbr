export type DiffStat = {
  status:
    | "merge conflict"
    | "added"
    | "removed"
    | "modified"
    | "renamed"
    | "local deleted";
  linesAdded: number;
};
