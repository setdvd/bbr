import { Dispatch, SetStateAction, useEffect } from "react";

import {
  useReloadableDataWithParams,
  ReloadableDataWithParams,
} from "./ReloadableDataWithParams";
import { notReachable } from "../notReachable";
import { noop } from "../noop";

/**
 * Type representing repeating async process which starts immedately and require parameters to execute
 * @typeParam T Type of result
 * @typeParam P Type of parameters
 * @typeParam E Type of error which can happen during async process
 */
export type PollableDataWithParams<T, P, E = Error> = ReloadableDataWithParams<
  T,
  P,
  E
>;

type Fetch<T, P> = (params: P) => Promise<T>;

/**
 * Hook to simplify usage of {@link PollableDataWithParams} type in React
 * @param fetch function which requires params P and returns Promise<T>, representing async action
 * @param config.pollIntervalMilliseconds interval in milliseconds to execute async process
 * @param config.stopIf function which accepts current state and return true if polling should stop
 */
export const usePollableDataWithParams = <T, P, E = Error>(
  fetch: Fetch<T, P>,
  initState: PollableDataWithParams<T, P, E>,
  intervalMs: number = 2000
): [
  PollableDataWithParams<T, P, E>,
  Dispatch<SetStateAction<PollableDataWithParams<T, P, E>>>
] => {
  const [state, setState] = useReloadableDataWithParams(fetch, initState);

  useEffect(() => {
    const timeout = (cb: () => void) => {
      const id = setTimeout(cb, intervalMs);
      return () => clearTimeout(id);
    };
    switch (state.type) {
      case "loading":
      case "reloading":
        return noop;
      case "error":
        return timeout(() => {
          setState({ type: "loading", params: state.params });
        });
      case "loaded":
      case "subsequent_failed":
        return timeout(() => {
          setState({
            type: "reloading",
            params: state.params,
            data: state.data,
          });
        });
      default:
        return notReachable(state);
    }
  }, [intervalMs, setState, state]);

  return [state, setState];
};
