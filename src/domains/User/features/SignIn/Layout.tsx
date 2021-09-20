import React, { useState } from "react";
import { Layout as UILayout, Header, Input, Button } from "@revolut/ui-kit";
import * as User from "src/domains/User";
import { CredentialValidationError } from "src/domains/User";
import { notReachable } from "src/toolkit/notReachable";

type Props = {
  isLoading: boolean;
  onMsg: (msg: Msg) => void;
};

export type Msg = {
  type: "on_submit";
  credentials: User.Credential;
};

type State = {
  username?: string;
  password?: string;
};

export const Layout = ({ onMsg, isLoading }: Props) => {
  const [state, setState] = useState<State>({});
  const [isFormSubmitted, setIsFormSubmitted] = useState<boolean>(false);

  const error = isFormSubmitted
    ? User.validateCredential(state).getFailureReason()
    : undefined;

  console.log(error, state);

  const onSubmit = () => {
    setIsFormSubmitted(true);
    User.validateCredential(state).map((credentials) => {
      onMsg({ type: "on_submit", credentials });
    });
  };

  return (
    <UILayout>
      <UILayout.Main>
        <Header variant="form">
          <Header.Title>Login to Bitbucket</Header.Title>
        </Header>
        <Input
          variant={"grey"}
          label={"username"}
          value={state.username}
          placeholder={"bitbucket username"}
          hasError={!!error?.username}
          message={<UsernameMessage error={error} />}
          onChange={(e) => {
            setState({
              ...state,
              username: e.currentTarget.value,
            });
          }}
        />
        <Input
          variant={"grey"}
          label={"app password"}
          value={state.password}
          hasError={!!error?.password}
          message={<PasswordMessage error={error} />}
          onChange={(e) => {
            setState({
              ...state,
              password: e.currentTarget.value,
            });
          }}
        />
        <UILayout.Actions>
          <Button pending={isLoading} onClick={onSubmit}>
            Login
          </Button>
        </UILayout.Actions>
      </UILayout.Main>
    </UILayout>
  );
};

const UsernameMessage = ({
  error,
}: {
  error: CredentialValidationError | undefined;
}) => {
  if (!error || !error.username) {
    return null;
  }

  switch (error.username.type) {
    case "value_is_empty":
      return <>required</>;
    default:
      /* istanbul ignore next */
      return notReachable(error.username.type);
  }
};

const PasswordMessage = ({
  error,
}: {
  error: CredentialValidationError | undefined;
}) => {
  if (!error || !error.password) {
    return null;
  }

  switch (error.password.type) {
    case "value_is_empty":
      return <>required</>;
    default:
      /* istanbul ignore next */
      return notReachable(error.password.type);
  }
};
