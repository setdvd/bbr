import React from "react";
import { ExclamationTriangle } from "@revolut/icons";
import { Tooltip } from "@revolut/ui-kit";
import { DiffStat } from "../index";
import { notReachable } from "src/toolkit/notReachable";

type Props = {
  diffStats: DiffStat[];
};

export const MergeConflictStatus = ({ diffStats }: Props) => {
  const hasConflict = diffStats.find((diff) => {
    switch (diff.status) {
      case "merge conflict":
        return true;
      case "local deleted":
      case "added":
      case "removed":
      case "modified":
      case "renamed":
        return false;
      /* istanbul ignore next */
      default:
        return notReachable(diff.status);
    }
  });

  return hasConflict ? (
    <Tooltip message="merge conflict" placement={"bottom-start"}>
      <ExclamationTriangle size={16} color={"warning"} />
    </Tooltip>
  ) : (
    <Tooltip message="no conflict" placement={"bottom-start"}>
      <ExclamationTriangle size={16} color={"grey-80"} />
    </Tooltip>
  );
};
