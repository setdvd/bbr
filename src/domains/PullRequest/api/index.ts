import * as User from "src/domains/User";

type Params = {
  credentials: User.Credential;
};
export const fetchCurrentUserPullRequests = ({ credentials }: Params) => {
  return fetch("");
};
