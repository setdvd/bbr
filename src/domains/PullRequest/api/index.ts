import * as User from "src/domains/User";
import { get, post } from "src/toolkit/requests";
import { Credential, getHTTPAuthHeader } from "src/domains/User";
import { PullRequest, PullRequestItem } from "../PullRequest";
import { MergeStrategy } from "src/domains/MergeStrategy";

type Params = {
  credentials: User.Credential;
};

export const fetchCurrentUserPullRequests = ({
  credentials,
}: Params): Promise<PullRequestItem[]> => {
  return get<any>(`/pullrequests/${credentials.username}`, {
    headers: getHTTPAuthHeader(credentials),
  }).then((prs) => prs.values);
};

export const fetchFullPullRequest = ({
  credentials,
  pullRequestItem,
}: {
  credentials: User.Credential;
  pullRequestItem: PullRequestItem;
}): Promise<PullRequest> => {
  return get<PullRequest>(pullRequestItem.links.self.href, {
    headers: getHTTPAuthHeader(credentials),
  }).then((pr) => {
    return {
      ...pr,
      participants: pr.participants.map((participant) => ({
        ...participant,
        state: !participant.state ? "no_actions_yet" : participant.state,
      })),
    };
  });
};

export const merge = ({
  pullRequest,
  credentials,
  mergeStrategy,
}: {
  pullRequest: PullRequest;
  credentials: Credential;
  mergeStrategy: MergeStrategy;
}) => {
  return post(
    pullRequest.links.merge.href,
    {
      message: `Merged in ${pullRequest.title} (pull request #${pullRequest.id})`,
      merge_strategy: mergeStrategy,
    },
    {
      headers: getHTTPAuthHeader(credentials),
    }
  );
};
