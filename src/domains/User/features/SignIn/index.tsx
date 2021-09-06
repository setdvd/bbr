import React from "react";
import * as User from "src/domains/User";
import { useLazyLoadableDataWithParams } from "src/toolkit/LoadableData";

type Props = {
  onMsg: (msg: Msg) => void;
};

export type Msg = { type: "credentials_created"; credentials: User.Credential };

export const SignIn = ({}: Props) => {
  const [state, setState] = useLazyLoadableDataWithParams(fetch);

  return <div></div>;
};
