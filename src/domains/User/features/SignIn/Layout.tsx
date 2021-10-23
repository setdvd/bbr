import { useState } from "react";
import {
  Layout as UILayout,
  Header,
  Input,
  Button,
  InputGroup,
} from "@revolut/ui-kit";
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
    User.validateCredential(state).map((credentials) =>
      onMsg({ type: "on_submit", credentials })
    );
  };

  return (
    <UILayout>
      <UILayout.Main>
        <Header variant="form">
          <Header.Title>Login to Bitbucket</Header.Title>
        </Header>

        <InputGroup use="form" id="sign-in-form">
          <Input
            variant="grey"
            label="Bitbucket username"
            value={state.username}
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
            variant="grey"
            label="App password"
            type="password"
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
        </InputGroup>

        <UILayout.Actions>
          <Button
            pending={isLoading}
            type="submit"
            form="sign-in-form"
            onClick={(e) => {
              onSubmit();
              e.preventDefault();
            }}
          >
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
