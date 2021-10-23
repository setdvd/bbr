import { Cell, Group, Header, Input, Popup } from "@revolut/ui-kit";

import { MergeStrategy } from "../MergeStrategy";
import { getLabel, getAllMergeStrategies } from "../helpers";
import { useState } from "react";

type Props = {
  value: MergeStrategy;
  onChange: (value: MergeStrategy) => void;
};

export const MergeStrategyInput = ({ value, onChange }: Props) => {
  const [state, setState] = useState<ModalState>("closed");

  return (
    <>
      <Input
        variant="grey"
        label="Merge strategy"
        readOnly
        value={getLabel(value)}
        onClick={() => setState("opened")}
      />

      <Modal
        value={value}
        state={state}
        onSelect={onChange}
        onClose={() => setState("closed")}
      />
    </>
  );
};

type ModalState = "opened" | "closed";

const Modal = ({
  state,
  value,
  onSelect,
  onClose,
}: {
  state: ModalState;
  value: MergeStrategy;
  onSelect: (value: MergeStrategy) => void;
  onClose: () => void;
}) => {
  switch (state) {
    case "closed":
      return <Popup variant="bottom-sheet" isOpen={false} />;

    case "opened":
      return (
        <Popup variant="bottom-sheet" isOpen onExit={onClose}>
          <Header variant="bottom-sheet">
            <Header.Title>Select default merge strategy</Header.Title>
          </Header>

          <Group>
            {getAllMergeStrategies().map((strategy) => (
              <Cell
                key={strategy}
                use="button"
                variant="choice"
                aria-pressed={value === strategy}
                onClick={() => onSelect(strategy)}
              >
                {getLabel(strategy)}
              </Cell>
            ))}
          </Group>
        </Popup>
      );
  }
};
