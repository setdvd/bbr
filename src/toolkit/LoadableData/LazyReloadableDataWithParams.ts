import { Dispatch, SetStateAction, useEffect, useState } from "react";

import * as Primitive from "./Primitive";
import { ReloadableDataWithParams } from "./ReloadableDataWithParams";
import { useLiveRef } from "../useLiveRef";
import { useCancellify } from "../useCancellify";
import { noop } from "../noop";
import { notReachable } from "../notReachable";

/**
 * Type representing  async process which starts on demand, can be restarted on demand and require parameters to execute
 * @typeParam T Type of result
 * @typeParam P Type of parameters
 * @typeParam E Type of error which can happen during async process
 */
export type LazyReloadableDataWithParams<T, P, E = Error> =
  | ReloadableDataWithParams<T, P, E>
  | (Primitive.NotAsked & Primitive.ParamsStub);

/**
 * Hook to simplify usage of {@link LazyReloadableDataWithParams} type in React
 * @param fetch function which requires params P and returns Promise<T>, representing async action
 */
export const useLazyReloadableDataWithParams = <T, P, E = Error>(
  fetch: (params: P) => Promise<T>,
  initState: LazyReloadableDataWithParams<T, P, E>
): [
  LazyReloadableDataWithParams<T, P, E>,
  Dispatch<SetStateAction<LazyReloadableDataWithParams<T, P, E>>>
] => {
  const fetchRef = useLiveRef(fetch);
  const [state, setState] =
    useState<LazyReloadableDataWithParams<T, P, E>>(initState);
  const { isCancelled, cancellify } = useCancellify();

  useEffect(() => {
    const loadData = (params: P, onError: (e: E) => void) => {
      const { promise, cancel } = cancellify(fetchRef.current(params));
      promise
        .then((data) => {
          setState({
            type: "loaded",
            params,
            data,
          });
        })
        .catch((e) => {
          if (isCancelled(e)) {
            return;
          }
          onError(e);
        });

      return cancel;
    };
    switch (state.type) {
      case "not_asked":
        return noop;

      case "loading": {
        const params = state.params;
        return loadData(params, (error) => {
          setState({
            type: "error",
            error,
            params,
          });
        });
      }

      case "reloading": {
        const params = state.params;
        return loadData(
          params,

          (error) => {
            setState({
              type: "subsequent_failed",
              error,
              params,
              data: state.data,
            });
          }
        );
      }
      case "error":
      case "subsequent_failed":
      case "loaded":
        return noop;
      default:
        return notReachable(state);
    }
  }, [cancellify, fetchRef, isCancelled, state]);

  return [state, setState];
};
