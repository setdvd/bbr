import styled from "styled-components";
import { Flex, themeVariant } from "@revolut/ui-kit";

type SpacingProp = {
  space?: number | string;
};

export const Column = styled(Flex)<SpacingProp>`
  display: flex;
  flex-direction: column;
  & > *:not(:first-child) {
    margin-top: ${(props) =>
      themeVariant("space")(props)[props.space || 0] || props.space};
  }
`;
