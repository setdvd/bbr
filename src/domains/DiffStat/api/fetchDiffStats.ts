import { get } from "src/toolkit/requests";
import { DiffStat } from "../index";
import { PullRequestItem } from "src/domains/PullRequest";
import { getHTTPAuthHeader, Credential } from "src/domains/User";

type DiffStatDTO = {
  status: "merge conflict" | "added" | "removed" | "modified" | "renamed";
  lines_added: number;
};

type ResponseDTO = {
  values: DiffStatDTO[];
};

type Params = {
  pullRequestItem: PullRequestItem;
  credentials: Credential;
};
export const fetchDiffStats = async ({
  pullRequestItem,
  credentials,
}: Params): Promise<DiffStat[]> => {
  const { values } = await get<ResponseDTO>(
    pullRequestItem.links.diffstat.href,
    {
      headers: getHTTPAuthHeader(credentials),
    }
  );
  return values.map(({ lines_added, status }) => {
    return {
      status,
      linesAdded: lines_added,
    };
  });
};
