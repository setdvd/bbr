import { Button, Ellipsis, Item, Link } from "@revolut/ui-kit";
import * as Icons from "@revolut/icons";
import { PullRequestItem } from "src/domains/PullRequest";

type Props = {
  pullRequest: PullRequestItem;
  onMarkUncheckedClick: () => void;
};

export const CheckedItem = ({ pullRequest, onMarkUncheckedClick }: Props) => (
  <Item>
    <Item.Content>
      <Item.Title>
        <Link href={pullRequest.links.html.href} target="_blank">
          <Ellipsis>{pullRequest.title}</Ellipsis>
        </Link>
      </Item.Title>
      <Item.Description>{pullRequest.author.display_name}</Item.Description>
    </Item.Content>
    <Item.Side>
      <Button
        variant="secondary"
        useIcon={Icons.ArrowUpgrade}
        size="sm"
        onClick={onMarkUncheckedClick}
      />
    </Item.Side>
  </Item>
);
