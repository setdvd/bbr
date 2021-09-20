import React, { useState } from "react";
import { PullRequestItem } from "../../PullRequest";
import * as User from "src/domains/User";
import { Settings } from "src/domains/Settings";
import { Modal, State as ModalState } from "./Modal";
import { Layout } from "./Layout";
import { notReachable } from "src/toolkit/notReachable";

type Props = {
  initialPullRequests: PullRequestItem[] | null;
  credentials: User.Credential;
  settings: Settings;
  onMsg: (msg: Msg) => void;
};

export type Msg = { type: "settings_change"; settings: Settings };

export const MyPRs = ({
  initialPullRequests,
  credentials,
  settings,
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
            /* istanbul ignore next */
            default:
              return notReachable(msg.type);
          }
        }}
      />
      <Modal
        state={state}
        settings={settings}
        onMsg={(msg) => {
          switch (msg.type) {
            case "close":
              setState({ type: "modal_closed" });
              break;
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
