import React, { useState } from "react";
import { PullRequestItem } from "../../PullRequest";
import * as User from "src/domains/User";
import { Settings } from "src/domains/Settings";
import { PullRequestTagsHash } from "src/domains/PullRequestTagsHash";
import { Modal, State as ModalState } from "./Modal";
import { Layout } from "./Layout";
import { notReachable } from "src/toolkit/notReachable";

type Props = {
  initialPullRequests: PullRequestItem[] | null;
  credentials: User.Credential;
  settings: Settings;
  pullRequestTagsHash: PullRequestTagsHash;
  onMsg: (msg: Msg) => void;
};

export type Msg =
  | { type: "settings_change"; settings: Settings }
  | { type: "mark_pr_as_checked_clicked"; pr: PullRequestItem }
  | { type: "mark_pr_as_unchecked_clicked"; pr: PullRequestItem }
  | { type: "mark_pr_as_ignored_clicked"; pr: PullRequestItem };

export const MyPRs = ({
  initialPullRequests,
  credentials,
  settings,
  pullRequestTagsHash,
  onMsg,
}: Props) => {
  const [state, setState] = useState<ModalState>({ type: "modal_closed" });

  return (
    <>
      <Layout
        initialPullRequests={initialPullRequests}
        credentials={credentials}
        settings={settings}
        onMsg={(msg) => {
          switch (msg.type) {
            case "settings_button_click":
              setState({ type: "settings" });
              break;

            case "my_prs_button_click":
              setState({ type: "review_prs" });
              break;

            /* istanbul ignore next */
            default:
              notReachable(msg);
              break;
          }
        }}
      />

      <Modal
        state={state}
        pullRequestTagsHash={pullRequestTagsHash}
        settings={settings}
        credentials={credentials}
        onMsg={(msg) => {
          switch (msg.type) {
            case "close":
              setState({ type: "modal_closed" });
              break;
            case "mark_pr_as_checked_clicked":
            case "mark_pr_as_unchecked_clicked":
            case "mark_pr_as_ignored_clicked":
            case "settings_change":
              onMsg(msg);
              break;
            /* istanbul ignore next */
            default:
              return notReachable(msg);
          }
        }}
      />
    </>
  );
};
