import * as User from "src/domains/User";
import { get, post } from "src/toolkit/requests";
import { Credential, getHTTPAuthHeader } from "src/domains/User";
import { PullRequest, PullRequestItem } from "../PullRequest";

type Params = {
  credentials: User.Credential;
};

export const fetchCurrentUserPullRequests = ({
  credentials,
}: Params): Promise<PullRequestItem[]> => {
  return get<any>(`/pullrequests/${credentials.username}`, {
    headers: getHTTPAuthHeader(credentials),
  }).then((prs) => {
    return prs.values;
  });
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
}: {
  pullRequest: PullRequest;
  credentials: Credential;
}) => {
  return post(pullRequest.links.merge.href, undefined, {
    headers: getHTTPAuthHeader(credentials),
  });
};
