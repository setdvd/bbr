import React from "react";
import { NotEligible } from "@revolut/icons";
import { Tooltip, Badge } from "@revolut/ui-kit";
import { PullRequest } from "../PullRequest";
import { Settings } from "../../Settings";
import { notReachable } from "src/toolkit/notReachable";

type Props = {
  pullRequest: PullRequest;
  settings: Settings;
};

type CombinedState =
  | { type: "request_changes" }
  | { type: "approved"; count: number };

const calculateState = (pullRequest: PullRequest): CombinedState => {
  const hasRequestChanges = pullRequest.participants.find((participant) => {
    switch (participant.state) {
      case "changes_requested":
        return true;
      case "approved":
      case "no_actions_yet":
        return false;
      /* istanbul ignore next */
      default:
        return notReachable(participant.state);
    }
  });

  if (hasRequestChanges) {
    return { type: "request_changes" };
  }

  const count = pullRequest.participants.reduce((memo, participant) => {
    switch (participant.state) {
      case "approved":
        return pullRequest.author.account_id === participant.user.account_id
          ? memo
          : memo + 1;
      case "changes_requested":
      case "no_actions_yet":
        return memo;
      /* istanbul ignore next */
      default:
        return notReachable(participant.state);
    }
  }, 0);

  return { type: "approved", count };
};

export const ApproveStatus = ({ settings, pullRequest }: Props) => {
  const state = calculateState(pullRequest);

  switch (state.type) {
    case "request_changes":
      return (
        <Tooltip message="request changes" placement={"bottom-start"}>
          <NotEligible size={16} color={"warning"} />
        </Tooltip>
      );
    case "approved":
      const color =
        state.count >= settings.numberOfApproves ? "green" : "grey-80";
      return (
        <Tooltip message="approve count" placement={"bottom-start"}>
          <Badge size={16} fontSize={10} bg={color}>
            {state.count}
          </Badge>
        </Tooltip>
      );
    /* istanbul ignore next */
    default:
      return notReachable(state);
  }
};
