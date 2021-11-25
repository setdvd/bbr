import {
  chain,
  Group,
  Header,
  ItemSkeleton,
  Layout,
  Subheader,
} from "@revolut/ui-kit";
import { fetchList, PullRequestItem } from "src/domains/PullRequest";
import { Credential } from "src/domains/User";
import { usePollableDataWithParams } from "src/toolkit/LoadableData";
import { notReachable } from "src/toolkit/notReachable";

import { UncheckedItem } from "./UncheckedItem";
import { CheckedItem } from "./CheckedItem";
import {
  PullRequestTagsHash,
  groupPullRequests,
} from "src/domains/PullRequestTagsHash";
import { Settings } from "src/domains/Settings";

type Props = {
  credentials: Credential;
  pullRequestTagsHash: PullRequestTagsHash;
  settings: Settings;
  onMsg: (msg: Msg) => void;
};

type Msg =
  | { type: "mark_pr_as_checked_clicked"; pr: PullRequestItem }
  | { type: "mark_pr_as_unchecked_clicked"; pr: PullRequestItem }
  | { type: "mark_pr_as_ignored_clicked"; pr: PullRequestItem }
  | { type: "close" };

export const ReviewPage = ({
  credentials,
  pullRequestTagsHash,
  settings,
  onMsg,
}: Props) => {
  const [loadable] = usePollableDataWithParams(
    fetchList,
    {
      type: "loading",
      params: {
        pageSize: 50,
        workspace: settings.reviewInWorkspace,
        repoSlug: settings.reviewInRepo,
        credentials,
        params: {
          state: "OPEN",
          "reviewers.uuid": `{${settings.reviewByUserUUID}}`,
        },
      },
    },
    2 * 1000 * 60
  );

  switch (loadable.type) {
    case "loading":
    case "error":
      return (
        <Layout>
          <Layout.Main>
            <Header variant="main">
              <Header.BackButton onClick={() => onMsg({ type: "close" })} />

              <Header.Title>PRs to Review</Header.Title>
            </Header>
            <Group>
              <ItemSkeleton />
              <ItemSkeleton />
            </Group>
          </Layout.Main>
        </Layout>
      );

    case "subsequent_failed":
    case "reloading":
    case "loaded": {
      const grouped = groupPullRequests(
        pullRequestTagsHash,
        loadable.data.values
      );

      return (
        <Layout>
          <Layout.Main>
            <Header variant="form">
              <Header.BackButton
                aria-label={"back"}
                onClick={() => onMsg({ type: "close" })}
              />

              <Header.Title>PRs to Review</Header.Title>
            </Header>

            {grouped.unchecked.length > 0 && (
              <>
                <Subheader>
                  {chain("To review", grouped.unchecked.length)}
                </Subheader>
                <Group>
                  {grouped.unchecked.map((pr) => (
                    <UncheckedItem
                      key={pr.id}
                      pullRequest={pr}
                      onMarkIgnoredClick={() =>
                        onMsg({ type: "mark_pr_as_ignored_clicked", pr })
                      }
                      onMarkCheckedClick={() =>
                        onMsg({ type: "mark_pr_as_checked_clicked", pr })
                      }
                    />
                  ))}
                </Group>
              </>
            )}

            {grouped.checked.length > 0 && (
              <>
                <Subheader>Checked</Subheader>
                <Group>
                  {grouped.checked.map((pr) => (
                    <CheckedItem
                      key={pr.id}
                      pullRequest={pr}
                      onMarkUncheckedClick={() =>
                        onMsg({ type: "mark_pr_as_unchecked_clicked", pr })
                      }
                    />
                  ))}
                </Group>
              </>
            )}

            {grouped.ignored.length > 0 && (
              <>
                <Subheader>Ignored</Subheader>
                <Group>
                  {grouped.ignored.map((pr) => (
                    <CheckedItem
                      key={pr.id}
                      pullRequest={pr}
                      onMarkUncheckedClick={() =>
                        onMsg({ type: "mark_pr_as_unchecked_clicked", pr })
                      }
                    />
                  ))}
                </Group>
              </>
            )}
          </Layout.Main>
        </Layout>
      );
    }

    /* istanbul ignore next */
    default:
      return notReachable(loadable);
  }
};
