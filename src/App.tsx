import { useEffect, useState } from "react";
import * as User from "src/domains/User";
import { notReachable } from "src/toolkit/notReachable";
import { SignIn } from "src/domains/User/features/SignIn";
import { PullRequestItem } from "src/domains/PullRequest";
import {
  markAsChecked,
  markAsIgnored,
  markAsUnchecked,
} from "src/domains/PullRequestTagsHash";
import {
  Persistance,
  loadPersistance,
  savePersistance,
} from "src/domains/Persistance";
import { MyPRs } from "src/domains/PullRequest/features/MyPRs";

type State =
  | {
      type: "has_user";
      credentials: User.Credential;
      pullRequests: PullRequestItem[] | null;
    }
  | { type: "sign_in" };

export const App = () => {
  const [persistanceState, setPersistanceState] = useState<Persistance>(() =>
    loadPersistance()
  );

  useEffect(() => {
    savePersistance(persistanceState);
  }, [persistanceState]);

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
                setPersistanceState((current) => ({
                  ...current,
                  settings: msg.settings,
                }));
                break;

              case "mark_pr_as_checked_clicked":
                setPersistanceState((persistance) => ({
                  ...persistance,
                  pullRequestTagsHash: markAsChecked(
                    persistance.pullRequestTagsHash,
                    msg.pr
                  ),
                }));
                break;

              case "mark_pr_as_unchecked_clicked":
                setPersistanceState((persistance) => ({
                  ...persistance,
                  pullRequestTagsHash: markAsUnchecked(
                    persistance.pullRequestTagsHash,
                    msg.pr
                  ),
                }));
                break;

              case "mark_pr_as_ignored_clicked":
                setPersistanceState((persistance) => ({
                  ...persistance,
                  pullRequestTagsHash: markAsIgnored(
                    persistance.pullRequestTagsHash,
                    msg.pr
                  ),
                }));
                break;

              /* istanbul ignore next */
              default:
                return notReachable(msg);
            }
          }}
          pullRequestTagsHash={persistanceState.pullRequestTagsHash}
          settings={persistanceState.settings}
          initialPullRequests={state.pullRequests}
          credentials={state.credentials}
        />
      );
    default:
      /* istanbul ignore next */
      return notReachable(state);
  }
};
