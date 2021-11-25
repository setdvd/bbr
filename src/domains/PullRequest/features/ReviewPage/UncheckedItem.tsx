import { Button, Ellipsis, HStack, Item, Link } from "@revolut/ui-kit";
import * as Icons from "@revolut/icons";
import { PullRequestItem } from "src/domains/PullRequest";

type Props = {
  pullRequest: PullRequestItem;
  onMarkCheckedClick: () => void;
  onMarkIgnoredClick: () => void;
};

export const UncheckedItem = ({
  pullRequest,
  onMarkCheckedClick,
  onMarkIgnoredClick,
}: Props) => (
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
      <HStack space="s-8">
        <Button
          variant="secondary"
          useIcon={Icons.ArrowDowngrade}
          size="sm"
          onClick={onMarkCheckedClick}
        />
        <Button
          variant="negative"
          useIcon={Icons.Stop}
          size="sm"
          onClick={onMarkIgnoredClick}
        />
      </HStack>
    </Item.Side>
  </Item>
);
