import { Settings } from "../../Settings";
import {
  Header,
  Layout,
  Subheader,
  Input,
  Item,
  InputGroup,
} from "@revolut/ui-kit";
import { LogoutDoor } from "@revolut/icons";
import { Column } from "src/uikit/Column";

import { MergeStrategyInput } from "src/domains/MergeStrategy/components";

type Props = {
  settings: Settings;
  onMsg: (msg: Msg) => void;
};

export type Msg =
  | { type: "close" }
  | { type: "settings_change"; settings: Settings };

export const SettingsPage = ({ settings, onMsg }: Props) => {
  return (
    <Layout>
      <Layout.Main>
        <Header variant="form">
          <Header.BackButton
            aria-label={"back"}
            onClick={() => onMsg({ type: "close" })}
          />

          <Header.Title>Settings</Header.Title>
        </Header>

        <Subheader>
          <Subheader.Title>Merge rules</Subheader.Title>
        </Subheader>

        <InputGroup>
          <Input
            variant={"grey"}
            label="Number of builds to pass"
            type={"number"}
            value={settings.numberOfBuilds}
            onChange={(e) => {
              onMsg({
                type: "settings_change",
                settings: {
                  ...settings,
                  numberOfBuilds: Number(e.currentTarget.value),
                },
              });
            }}
          />

          <Input
            variant={"grey"}
            label="Number of approves"
            type={"number"}
            value={settings.numberOfApproves}
            onChange={(e) => {
              onMsg({
                type: "settings_change",
                settings: {
                  ...settings,
                  numberOfApproves: Number(e.currentTarget.value),
                },
              });
            }}
          />

          <Input
            variant={"grey"}
            label="Poll interval (minutes)"
            type={"number"}
            value={settings.pollIntervalMinutes}
            onChange={(e) => {
              onMsg({
                type: "settings_change",
                settings: {
                  ...settings,
                  pollIntervalMinutes: Number(e.currentTarget.value),
                },
              });
            }}
          />

          <Input
            variant="grey"
            label="Current user UUID (used for review PRs)"
            value={settings.reviewByUserUUID}
            onChange={(e) => {
              onMsg({
                type: "settings_change",
                settings: {
                  ...settings,
                  reviewByUserUUID: e.currentTarget.value,
                },
              });
            }}
          />

          <Input
            variant="grey"
            label="Review workspace"
            value={settings.reviewInWorkspace}
            onChange={(e) => {
              onMsg({
                type: "settings_change",
                settings: {
                  ...settings,
                  reviewInWorkspace: e.currentTarget.value,
                },
              });
            }}
          />

          <Input
            variant="grey"
            label="Review repo"
            value={settings.reviewInRepo}
            onChange={(e) => {
              onMsg({
                type: "settings_change",
                settings: {
                  ...settings,
                  reviewInRepo: e.currentTarget.value,
                },
              });
            }}
          />

          <MergeStrategyInput
            value={settings.mergeStrategy}
            onChange={(mergeStrategy) =>
              onMsg({
                type: "settings_change",
                settings: {
                  ...settings,
                  mergeStrategy,
                },
              })
            }
          />
        </InputGroup>
        <Subheader>
          <Subheader.Title>Actions</Subheader.Title>
        </Subheader>
        <Column space={"s-16"}>
          <Item
            use="button"
            variant={"disclosure"}
            useIcon={LogoutDoor}
            iconColor={"error"}
            onClick={() => console.log("Click on Item")}
          >
            <Item.Content color="primary">Logout</Item.Content>
          </Item>
        </Column>
      </Layout.Main>
    </Layout>
  );
};
