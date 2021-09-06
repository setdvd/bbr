import { useEffect } from "react";

import { useCancellify } from "src/toolkit/useCancellify";
import { noop } from "src/toolkit/noop";
import { notReachable } from "src/toolkit/notReachable";

import {
  LazyReloadableDataWithParams,
  useLazyReloadableDataWithParams,
} from "./LazyReloadableDataWithParams";

/**
 * Type representing repeating async process which starts on demand and require parameters to execute
 * @typeParam T Type of result
 * @typeParam P Type of parameters
 * @typeParam E Type of error which can happen during async process
 */
export type LazyPollableDataWithParams<
  T,
  P,
  E = Error
> = LazyReloadableDataWithParams<T, P, E>;

type Result<T, P, E> = [
  LazyPollableDataWithParams<T, P, E>,
  React.Dispatch<React.SetStateAction<LazyPollableDataWithParams<T, P, E>>>
];

type Config<T, P, E> = {
  stopIf?: (loadable: LazyPollableDataWithParams<T, P, E>) => boolean;
  pollIntervalMilliseconds: number;
};

const timeout = (cb: () => void, intervalMs: number) => {
  const id = setTimeout(cb, intervalMs);
  return () => clearTimeout(id);
};

/**
 * Hook to simplify usage of {@link LazyPollableDataWithParams} type in React
 * @param fetch function which requires params P and returns Promise<T>, representing async action
 * @param config.pollIntervalMilliseconds interval in milliseconds to execute async process
 * @param config.stopIf function which accepts current state and return true if polling should stop
 */
export const useLazyPollableDataWithParams = <T, P, E = Error>(
  fetch: (params: P) => Promise<T>,
  initialState: LazyPollableDataWithParams<T, P, E>,
  { pollIntervalMilliseconds, stopIf = () => false }: Config<T, P, E>
): Result<T, P, E> => {
  const { cancellify, isCancelled } = useCancellify();

  const [state, setState] = useLazyReloadableDataWithParams(
    fetch,
    initialState
  );

  useEffect(() => {
    switch (state.type) {
      case "error":
        return stopIf(state)
          ? noop
          : timeout(() => {
              setState({
                type: "loading",
                params: state.params,
              });
            }, pollIntervalMilliseconds);

      case "subsequent_failed":
      case "loaded":
        return stopIf(state)
          ? noop
          : timeout(() => {
              setState({
                type: "reloading",
                params: state.params,
                data: state.data,
              });
            }, pollIntervalMilliseconds);

      case "loading":
      case "reloading":
      case "not_asked":
        return noop;

      default:
        return notReachable(state);
    }
  }, [
    state,
    pollIntervalMilliseconds,
    stopIf,
    cancellify,
    isCancelled,
    setState,
  ]);

  return [state, setState];
};
