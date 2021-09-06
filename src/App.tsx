import React, { useState } from "react";
import * as User from "src/domains/User";
import { notReachable } from "src/toolkit/notReachable";
import { SignIn } from "src/domains/User/features/SignIn";

type State =
  | { type: "has_user"; credentials: User.Credential }
  | { type: "sign_in" };

export const App = () => {
  const [state, setState] = useState<State>(() => {
    const credentials = User.getCredentials();
    return credentials
      ? { type: "has_user", credentials }
      : { type: "sign_in" };
  });

  switch (state.type) {
    case "sign_in":
      return <SignIn onMsg={() => {}} />;
    case "has_user":
      return <SignIn onMsg={() => {}} />;
    default:
      /* istanbul ignore next */
      return notReachable(state);
  }
};
