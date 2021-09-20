import React from "react";
import { CommitStatus } from "../index";
import { Settings } from "../../Settings";
import { notReachable } from "src/toolkit/notReachable";
import { CheckSuccess, Pending, ExclamationMark } from "@revolut/icons";
import { Flex, Link } from "@revolut/ui-kit";

type Props = {
  settings: Settings;
  commit: {
    statuses: CommitStatus[];
  };
};

export const BuildStatus = ({ settings, commit: { statuses } }: Props) => {
  const waitingToStart = settings.numberOfBuilds - statuses.length;

  return (
    <Flex flexDirection={"row"}>
      {statuses.map((status) => (
        <Link href={status.url} target={"_blank"}>
          <Icon status={status} />
        </Link>
      ))}
      {!!waitingToStart && <Pending size={16} color={"grey-80"} />}
    </Flex>
  );
};

const Icon = ({ status }: { status: CommitStatus }) => {
  switch (status.state) {
    case "SUCCESSFUL":
      return <CheckSuccess size={16} color={"success"} />;
    case "INPROGRESS":
      return <Pending size={16} color={"grey-80"} />;
    case "FAILED":
    case "STOPPED":
      return <ExclamationMark size={16} color={"error"} />;

    /* istanbul ignore next */
    default:
      return notReachable(status.state);
  }
};
