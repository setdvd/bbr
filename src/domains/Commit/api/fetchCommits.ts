import { PullRequestItem } from "../../PullRequest";
import { Credential, getHTTPAuthHeader } from "../../User";
import { Commit, CommitStatus } from "../index";
import { get } from "src/toolkit/requests";

type Params = {
  pullRequestItem: PullRequestItem;
  credentials: Credential;
};

type Response = {
  values: Commit[];
};

export const fetchCommits = async ({
  pullRequestItem,
  credentials,
}: Params): Promise<{
  commit: Commit;
  statuses: CommitStatus[];
}> => {
  const {
    values: [commit],
  } = await get<Response>(pullRequestItem.links.commits.href, {
    headers: getHTTPAuthHeader(credentials),
  });

  const { values } = await get<any>(commit.links.statuses.href, {
    headers: getHTTPAuthHeader(credentials),
  });

  return {
    commit,
    statuses: values as CommitStatus[],
  };
};
