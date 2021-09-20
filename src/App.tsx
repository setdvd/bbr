import React, { useEffect, useState } from "react";
import * as User from "src/domains/User";
import { notReachable } from "src/toolkit/notReachable";
import { SignIn } from "src/domains/User/features/SignIn";
import { PullRequestItem } from "src/domains/PullRequest";
import { MyPRs } from "src/domains/PullRequest/features/MyPRs";
import { getSettings, saveSettings, Settings } from "src/domains/Settings";

type State =
  | {
      type: "has_user";
      credentials: User.Credential;
      pullRequests: PullRequestItem[] | null;
    }
  | { type: "sign_in" };

export const App = () => {
  const [settingsState, setSettingsState] = useState<Settings>(() =>
    getSettings()
  );

  useEffect(() => {
    saveSettings(settingsState);
  }, [settingsState]);

  const [state, setState] = useState<State>(() => {
    const credentials = User.getCredentials();
    return credentials
      ? { type: "has_user", credentials, pullRequests: null }
      : { type: "sign_in" };
  });

  useEffect(() => {
    switch (state.type) {
      case "sign_in":
        break;
      case "has_user":
        User.saveCredentials(state.credentials);
        break;
      /* istanbul ignore next */
      default:
        return notReachable(state);
    }
  }, [state]);

  switch (state.type) {
    case "sign_in":
      return (
        <SignIn
          onMsg={(msg) => {
            switch (msg.type) {
              case "credentials_created":
                console.log("got msg");
                setState({
                  type: "has_user",
                  credentials: msg.credentials,
                  pullRequests: msg.pullRequests,
                });
                break;
              default:
                /* istanbul ignore next */
                return notReachable(msg.type);
            }
          }}
        />
      );
    case "has_user":
      return (
        <MyPRs
          onMsg={(msg) => {
            switch (msg.type) {
              case "settings_change":
                setSettingsState(msg.settings);
                break;
              /* istanbul ignore next */
              default:
                return notReachable(msg.type);
            }
          }}
          settings={settingsState}
          initialPullRequests={state.pullRequests}
          credentials={state.credentials}
        />
      );
    default:
      /* istanbul ignore next */
      return notReachable(state);
  }
};
