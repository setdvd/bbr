import { PullRequestItem } from "src/domains/PullRequest";
import * as User from "src/domains/User";
import { Settings } from "src/domains/Settings";
import { usePollableDataWithParams } from "src/toolkit/LoadableData";
import { fetchCurrentUserPullRequests } from "../../api";
import {
  Button,
  Group,
  Header,
  ItemSkeleton,
  Layout as UILayout,
  Subheader,
  TextButton,
  Text,
  Hint,
} from "@revolut/ui-kit";
import { Gear } from "@revolut/icons";
import { Item } from "../Item/";
import { notReachable } from "src/toolkit/notReachable";
import React from "react";

type Props = {
  initialPullRequests: PullRequestItem[] | null;
  credentials: User.Credential;
  settings: Settings;
  onMsg: (msg: Msg) => void;
};

type Msg = { type: "settings_button_click" };

// TODO: how to handle api errors here?

export const Layout = ({
  initialPullRequests,
  credentials,
  settings,
  onMsg,
}: Props) => {
  const [state, setState] = usePollableDataWithParams(
    fetchCurrentUserPullRequests,
    initialPullRequests
      ? { type: "loaded", params: { credentials }, data: initialPullRequests }
      : { type: "loading", params: { credentials } },
    settings.pollIntervalMinutes * 1000 * 60
  );

  switch (state.type) {
    case "loading":
    case "error":
      return (
        <UILayout>
          <UILayout.Main>
            <Header variant="main">
              <Header.Title>Overview</Header.Title>
            </Header>
            <Subheader>
              {(() => {
                switch (state.type) {
                  case "loading":
                    return <Text>loading</Text>;
                  case "error":
                    return <Text color={"error"}>{state.error.message}</Text>;
                }
              })()}
            </Subheader>
            <Group>
              <ItemSkeleton />
              <ItemSkeleton />
            </Group>
          </UILayout.Main>
        </UILayout>
      );
    case "loaded":
    case "reloading":
    case "subsequent_failed":
      return (
        <UILayout>
          <UILayout.Main>
            <Header variant="main">
              <Header.Title>Overview</Header.Title>
              <Header.Actions>
                <Button
                  variant="bar"
                  aria-label={"settings"}
                  onClick={() => {
                    onMsg({ type: "settings_button_click" });
                  }}
                  useIcon={Gear}
                />
              </Header.Actions>
            </Header>
            <Subheader>
              <Subheader.Side>
                {(() => {
                  switch (state.type) {
                    case "loaded":
                      return (
                        <TextButton
                          onClick={() =>
                            setState({
                              type: "reloading",
                              params: state.params,
                              data: state.data,
                            })
                          }
                        >
                          reload
                        </TextButton>
                      );
                    case "reloading":
                      return <Text>reloading...</Text>;
                    case "subsequent_failed":
                      return (
                        <Hint message={state.error.message} placement="bottom">
                          <TextButton
                            color={"error"}
                            onClick={() =>
                              setState({
                                type: "reloading",
                                params: state.params,
                                data: state.data,
                              })
                            }
                          >
                            reload
                          </TextButton>
                        </Hint>
                      );

                    /* istanbul ignore next */
                    default:
                      return notReachable(state);
                  }
                })()}
              </Subheader.Side>
            </Subheader>

            <Group>
              {state.data.map((pr) => {
                return (
                  <Item
                    key={pr.id}
                    pullRequest={pr}
                    credentials={credentials}
                    settings={settings}
                  />
                );
              })}
            </Group>
          </UILayout.Main>
        </UILayout>
      );
    /* istanbul ignore next */
    default:
      return notReachable(state);
  }
};
