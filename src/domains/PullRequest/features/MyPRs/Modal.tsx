import { Modal as UIModal } from "@revolut/ui-kit";
import { notReachable } from "src/toolkit/notReachable";
import {
  SettingsPage,
  Msg as SettingsMsg,
} from "src/domains/Settings/features/SettingsPage";
import { Settings } from "src/domains/Settings";
import { ReviewPage } from "src/domains/PullRequest/features/ReviewPage";
import { Credential } from "src/domains/User";
import { PullRequestItem } from "src/domains/PullRequest";
import { PullRequestTagsHash } from "src/domains/PullRequestTagsHash";

type Props = {
  state: State;
  settings: Settings;
  credentials: Credential;
  pullRequestTagsHash: PullRequestTagsHash;
  onMsg: (msg: Msg) => void;
};

export type Msg =
  | { type: "close" }
  | SettingsMsg
  | { type: "mark_pr_as_checked_clicked"; pr: PullRequestItem }
  | { type: "mark_pr_as_unchecked_clicked"; pr: PullRequestItem }
  | { type: "mark_pr_as_ignored_clicked"; pr: PullRequestItem };

export type State =
  | { type: "modal_closed" }
  | { type: "settings" }
  | { type: "review_prs" };

export const Modal = ({
  state,
  settings,
  credentials,
  pullRequestTagsHash,
  onMsg,
}: Props) => {
  switch (state.type) {
    case "modal_closed":
      return null;
    case "settings":
      return (
        <UIModal useTransition={false} isOpen>
          <SettingsPage settings={settings} onMsg={onMsg} />
        </UIModal>
      );

    case "review_prs":
      return (
        <UIModal useTransition={false} isOpen>
          <ReviewPage
            settings={settings}
            credentials={credentials}
            pullRequestTagsHash={pullRequestTagsHash}
            onMsg={onMsg}
          />
        </UIModal>
      );

    /* istanbul ignore next */
    default:
      return notReachable(state);
  }
};
