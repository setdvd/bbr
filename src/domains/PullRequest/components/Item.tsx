import React from "react";
import { Item as UIItem, ItemSkeleton } from "@revolut/ui-kit";

import { PullRequestItem } from "../PullRequest";

type Props = {
  pullRequest: PullRequestItem;
};

export const Item = ({ pullRequest }: Props) => {
  return (
    <UIItem use="label">
      <UIItem.Content>
        <UIItem.Title>{pullRequest.title}</UIItem.Title>
        <ItemSkeleton.Description />
      </UIItem.Content>
    </UIItem>
  );
};
