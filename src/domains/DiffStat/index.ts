export type DiffStat = {
  status: "merge conflict" | "added" | "removed" | "modified" | "renamed";
  linesAdded: number;
};
