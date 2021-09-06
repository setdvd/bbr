import { Dispatch, SetStateAction, useEffect, useState } from "react";

import * as Primitive from "./Primitive";
import { useLiveRef } from "../useLiveRef";
import { useCancellify } from "../useCancellify";
import { notReachable } from "../notReachable";
import { noop } from "../noop";

/**
 * Type representing  async process which starts immedately, can be restarted on demand and require parameters to execute
 * @typeParam T Type of result
 * @typeParam P Type of parameters
 * @typeParam E Type of error which can happen during async process
 */
export type ReloadableDataWithParams<T, P, E = Error> =
  | (Primitive.Loaded<T> & Primitive.Params<P>)
  | (Primitive.Reloading<T> & Primitive.Params<P>)
  | (Primitive.SubsequentFailed<T, E> & Primitive.Params<P>)
  | (Primitive.Loading & Primitive.Params<P>)
  | (Primitive.Failed<E> & Primitive.Params<P>);

/**
 * Hook to simplify usage of {@link ReloadableDataWithParams} type in React
 * @param fetch function which requires params P and returns Promise<T>, representing async action
 * @param initState initial state of the loadable data
 * @param options.accumulate  function allows to accumulate data when you transition from reloading to loaded state
 *                useful when do
 */
export const useReloadableDataWithParams = <T, P, E = Error>(
  fetch: (params: P) => Promise<T>,
  initState: ReloadableDataWithParams<T, P, E>,
  options?: {
    accumulate: (newData: T, prevData: T) => T;
  }
): [
  ReloadableDataWithParams<T, P, E>,
  Dispatch<SetStateAction<ReloadableDataWithParams<T, P, E>>>
] => {
  const fetchRef = useLiveRef(fetch);
  const [state, setState] =
    useState<ReloadableDataWithParams<T, P, E>>(initState);
  const { isCancelled, cancellify } = useCancellify();

  const mergeState =
    options?.accumulate ?? ((currentData: T): T => currentData);

  const mergeStateLive = useLiveRef(mergeState);

  useEffect(() => {
    const loadData = (params: P, onError: (e: E) => void) => {
      const { promise, cancel } = cancellify(fetchRef.current(params));
      promise
        .then((data) => {
          switch (state.type) {
            case "loading":
            case "error":
            case "loaded":
            case "subsequent_failed":
              setState({
                type: "loaded",
                params,
                data,
              });
              break;
            case "reloading": {
              const newData = mergeStateLive.current(data, state.data);
              return setState({
                type: "loaded",
                params,
                data: newData,
              });
            }

            default:
              /* istanbul ignore next */
              return notReachable(state);
          }
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
  }, [cancellify, fetchRef, isCancelled, mergeStateLive, state]);

  return [state, setState];
};
