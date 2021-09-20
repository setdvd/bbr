import React, { useEffect, useState } from "react";
import {
  fetchFullPullRequest,
  merge,
  PullRequest,
  PullRequestItem,
} from "src/domains/PullRequest";
import { Item as PRItem } from "src/domains/PullRequest/components";
import {
  useLazyLoadableDataWithParams,
  useLoadableDataWithParams,
} from "src/toolkit/LoadableData";
import { DiffStat } from "src/domains/DiffStat";
import { fetchDiffStats } from "src/domains/DiffStat/api";
import { notReachable } from "src/toolkit/notReachable";
import {
  Item as UIItem,
  Chain,
  Link,
  Toggle,
  Button,
  Switch,
  StatusPopup,
  Box,
  Tooltip,
} from "@revolut/ui-kit";
import { MergeConflictStatus } from "src/domains/DiffStat/components";
import { Credential } from "src/domains/User";
import { ApproveStatus } from "src/domains/PullRequest/components";
import { Settings } from "../../../Settings";
import { fetchCommits } from "src/domains/Commit/api";
import { BuildStatus } from "src/domains/Commit/components";
import { Commit, CommitStatus } from "../../../Commit";
import { noop } from "src/toolkit/noop";

type Props = {
  pullRequest: PullRequestItem;
  credentials: Credential;
  settings: Settings;
};

type Data = {
  diffStats: DiffStat[];
  pullRequest: PullRequest;
  commit: {
    commit: Commit;
    statuses: CommitStatus[];
  };
};

type FetchParams = {
  pullRequestItem: PullRequestItem;
  credentials: Credential;
};

const fetch = async ({
  pullRequestItem,
  credentials,
}: FetchParams): Promise<Data> => {
  const [diffStats, pullRequest, commit] = await Promise.all([
    fetchDiffStats({ pullRequestItem, credentials }),
    fetchFullPullRequest({ pullRequestItem, credentials }),
    fetchCommits({ pullRequestItem, credentials }),
  ]);

  return {
    diffStats,
    pullRequest,
    commit,
  };
};

type NotificationState =
  | "conflict"
  | "changes_requested"
  | "build_failed"
  | "waiting_for_build_or_approvals"
  | "ready_to_merge"
  | "merged";

const calculateState = ({
  diffStats,
  pullRequest,
  commit: { statuses },
  settings,
}: Omit<Data, "notificationState"> & {
  settings: Settings;
}): NotificationState => {
  if (pullRequest.state === "MERGED") {
    return "merged";
  }

  const hasConflict = !!diffStats.find((diff) => {
    switch (diff.status) {
      case "merge conflict":
        return true;
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

  if (hasConflict) {
    return "conflict";
  }

  const hasChangeRequested = pullRequest.participants.find((participant) => {
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

  if (hasChangeRequested) {
    return "changes_requested";
  }

  const isBuildFailed = statuses.find((build) => {
    switch (build.state) {
      case "FAILED":
      case "STOPPED":
        return true;
      case "SUCCESSFUL":
      case "INPROGRESS":
        return false;
      /* istanbul ignore next */
      default:
        return notReachable(build.state);
    }
  });
  if (isBuildFailed) {
    return "build_failed";
  }

  const isReadyToMerge =
    statuses.filter((status) => {
      switch (status.state) {
        case "SUCCESSFUL":
          return true;
        case "INPROGRESS":
        case "FAILED":
        case "STOPPED":
          return false;
        /* istanbul ignore next */
        default:
          return notReachable(status.state);
      }
    }).length >= settings.numberOfBuilds &&
    pullRequest.participants.filter((participant) => {
      switch (participant.state) {
        case "approved":
          return pullRequest.author.account_id !== participant.user.account_id;
        case "changes_requested":
        case "no_actions_yet":
          return false;
        /* istanbul ignore next */
        default:
          return notReachable(participant.state);
      }
    }).length >= settings.numberOfApproves;

  if (isReadyToMerge) {
    return "ready_to_merge";
  }

  return "waiting_for_build_or_approvals";
};

export const Item = ({ pullRequest, credentials, settings }: Props) => {
  const [state, setState] = useLoadableDataWithParams(fetch, {
    type: "loading",
    params: { pullRequestItem: pullRequest, credentials, settings },
  });

  useEffect(() => {
    if (state.params.pullRequestItem.id !== pullRequest.id) {
      setState({
        type: "loading",
        params: { pullRequestItem: pullRequest, credentials, settings },
      });
    }
  }, [
    credentials,
    pullRequest,
    setState,
    settings,
    state.params.pullRequestItem.id,
  ]);

  switch (state.type) {
    case "error": // FIXME:
    case "loading":
      return <PRItem pullRequest={pullRequest} />;
    case "loaded":
      return (
        <LoadedItem
          notificationState={calculateState({ ...state.data, settings })}
          data={state.data}
          pullRequest={pullRequest}
          credentials={credentials}
          settings={settings}
        />
      );

    /* istanbul ignore next */
    default:
      return notReachable(state);
  }
};

const LoadedItem = ({
  data,
  notificationState,
  pullRequest,
  settings,
  credentials,
}: { notificationState: NotificationState; data: Data } & Props) => {
  useEffect(() => {
    switch (notificationState) {
      case "conflict":
        new window.Notification("Conflict", {
          body: "pr has conflict",
          requireInteraction: true,
        });
        break;
      case "changes_requested":
        new window.Notification("Changes Requested", {
          body: "someone request changes to PR",
          requireInteraction: true,
        });
        break;
      case "build_failed":
        new window.Notification("Build Failed", {
          body: "some build are failed",
          requireInteraction: true,
        });
        break;
      case "waiting_for_build_or_approvals":
        break;
      case "ready_to_merge":
        new window.Notification("Ready to merge", {
          body: "PR ready to merge",
          requireInteraction: true,
        });
        break;
      case "merged":
        break;
      /* istanbul ignore next */
      default:
        return notReachable(notificationState);
    }
  }, [notificationState]);

  return (
    <UIItem use="label">
      <UIItem.Content>
        <UIItem.Title>
          <Link href={pullRequest.links.html.href} target={"_blank"}>
            {pullRequest.title}
          </Link>
        </UIItem.Title>
        <UIItem.Description>
          <Chain>
            <Chain.Item>
              <MergeConflictStatus diffStats={data.diffStats} />
            </Chain.Item>
            <Chain.Item>
              <ApproveStatus
                settings={settings}
                pullRequest={data.pullRequest}
              />
            </Chain.Item>
            <Chain.Item>
              <BuildStatus settings={settings} commit={data.commit} />
            </Chain.Item>
          </Chain>
        </UIItem.Description>
      </UIItem.Content>
      <UIItem.Side>
        <Box>
          <Merge
            notificationState={notificationState}
            pullRequest={data.pullRequest}
            credentials={credentials}
          />
        </Box>
      </UIItem.Side>
    </UIItem>
  );
};

const Merge = ({
  notificationState,
  pullRequest,
  credentials,
}: {
  notificationState: NotificationState;
  pullRequest: PullRequest;
  credentials: Credential;
}) => {
  const [isAutoMerge, setIsAutoMerge] = useState<boolean>(false);

  const [state, setState] = useLazyLoadableDataWithParams(merge);

  useEffect(() => {
    switch (notificationState) {
      case "conflict":
      case "changes_requested":
      case "build_failed":
      case "waiting_for_build_or_approvals":
      case "merged":
        break;
      case "ready_to_merge":
        setState((currentState) => {
          switch (currentState.type) {
            case "not_asked":
              return { type: "loading", params: { pullRequest, credentials } };
            case "loading":
            case "loaded":
            case "error":
              return currentState;
            /* istanbul ignore next */
            default:
              return notReachable(currentState);
          }
        });
        break;
      /* istanbul ignore next */
      default:
        return notReachable(notificationState);
    }
  }, [credentials, isAutoMerge, notificationState, pullRequest, setState]);

  switch (notificationState) {
    case "conflict":
    case "changes_requested":
    case "build_failed":
    case "waiting_for_build_or_approvals":
      return (
        <Toggle
          state={isAutoMerge}
          onChange={(newState) => setIsAutoMerge(newState)}
        >
          {({ state: stateInner, toggle }) => (
            <Tooltip
              delay={500}
              message="auto merge"
              placement={"bottom-start"}
            >
              <Switch onChange={() => toggle()} checked={isAutoMerge} />
            </Tooltip>
          )}
        </Toggle>
      );

    case "merged":
      return null;
    case "ready_to_merge":
      switch (state.type) {
        case "not_asked":
          return (
            <Button
              size="sm"
              onClick={() =>
                setState({
                  type: "loading",
                  params: {
                    pullRequest,
                    credentials,
                  },
                })
              }
            >
              Merge
            </Button>
          );
        case "loading":
          return <Button pending size="sm" onClick={noop} />;
        case "loaded":
          return (
            <StatusPopup
              variant="success"
              isOpen
              onExit={() => {
                // FIXME:
              }}
            >
              <StatusPopup.Title>Merged</StatusPopup.Title>
            </StatusPopup>
          );
        case "error":
          return (
            <StatusPopup
              variant="error"
              isOpen
              onExit={() => setState({ type: "not_asked" })}
            >
              <StatusPopup.Title>Merge failed</StatusPopup.Title>
              <StatusPopup.Description>
                {state.error.message}
              </StatusPopup.Description>
              <StatusPopup.Actions>
                <Button
                  elevated
                  onClick={() => {
                    setState({
                      type: "loading",
                      params: {
                        pullRequest,
                        credentials,
                      },
                    });
                  }}
                >
                  Retry
                </Button>
                <Button
                  elevated
                  variant={"secondary"}
                  onClick={() => {
                    setState({ type: "not_asked" });
                  }}
                >
                  Cancel
                </Button>
              </StatusPopup.Actions>
            </StatusPopup>
          );
        /* istanbul ignore next */
        default:
          return notReachable(state);
      }

    /* istanbul ignore next */
    default:
      return notReachable(notificationState);
  }
};
