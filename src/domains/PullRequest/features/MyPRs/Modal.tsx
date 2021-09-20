import React from "react";
import { notReachable } from "src/toolkit/notReachable";
import {
  SettingsPage,
  Msg as SettingsMsg,
} from "src/domains/Settings/features/SettingsPage";
import { Settings } from "src/domains/Settings";
import { Modal as UIModal } from "@revolut/ui-kit";

type Props = {
  state: State;
  settings: Settings;
  onMsg: (msg: Msg) => void;
};

export type Msg = { type: "close" } | SettingsMsg;

export type State = { type: "modal_closed" } | { type: "settings" };

export const Modal = ({ state, settings, onMsg }: Props) => {
  switch (state.type) {
    case "modal_closed":
      return null;
    case "settings":
      return (
        <UIModal useTransition={false} isOpen>
          <SettingsPage settings={settings} onMsg={onMsg} />
        </UIModal>
      );
    /* istanbul ignore next */
    default:
      return notReachable(state);
  }
};
