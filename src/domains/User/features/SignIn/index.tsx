import React, { useEffect } from "react";
import * as User from "src/domains/User";
import { useLazyLoadableDataWithParams } from "src/toolkit/LoadableData";
import { Layout } from "./Layout";
import { notReachable } from "src/toolkit/notReachable";
import { fetchCurrentUserPullRequests } from "src/domains/PullRequest";
import { noop } from "src/toolkit/noop";
import { PullRequestItem } from "src/domains/PullRequest";
import { useLiveRef } from "src/toolkit/useLiveRef";

type Props = {
  onMsg: (msg: Msg) => void;
};

export type Msg = {
  type: "credentials_created";
  credentials: User.Credential;
  pullRequests: PullRequestItem[];
};

export const SignIn = ({ onMsg }: Props) => {
  const [state, setState] = useLazyLoadableDataWithParams(
    fetchCurrentUserPullRequests
  );

  const onMsgLive = useLiveRef(onMsg);

  useEffect(() => {
    switch (state.type) {
      case "not_asked":
      case "loading":
      case "error":
        break;
      case "loaded":
        onMsgLive.current({
          type: "credentials_created",
          credentials: state.params.credentials,
          pullRequests: state.data,
        });
        break;
      default:
        /* istanbul ignore next */
        return notReachable(state);
    }
  }, [onMsgLive, state]);

  switch (state.type) {
    case "not_asked":
      return (
        <Layout
          isLoading={false}
          onMsg={(msg) => {
            switch (msg.type) {
              case "on_submit":
                setState({
                  type: "loading",
                  params: { credentials: msg.credentials },
                });
                break;
              default:
                /* istanbul ignore next */
                return notReachable(msg.type);
            }
          }}
        />
      );
    case "loading":
      return <Layout isLoading={true} onMsg={noop} />;
    case "loaded":
      return null;
    case "error":
      return <>{state.error.message}</>;
    default:
      /* istanbul ignore next */
      return notReachable(state);
  }
};
