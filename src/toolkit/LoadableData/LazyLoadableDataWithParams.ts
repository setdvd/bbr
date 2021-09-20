import { Dispatch, SetStateAction, useEffect, useState } from "react";

import { noop } from "src/toolkit/noop";
import { useLiveRef } from "src/toolkit/useLiveRef";

import * as Primitive from "./Primitive";
import { LoadableDataWithParams } from "./LoadableDataWithParams";
import { useCancellify } from "../useCancellify";

/**
 * Type representing async process which starts on demand and require parameters to start
 * @typeParam T Type of result
 * @typeParam P Type of parameters
 * @typeParam E Type of error which can happen during async process
 */
export type LazyLoadableDataWithParams<T, P, E = Error> =
  | (Primitive.NotAsked & Primitive.ParamsStub)
  | LoadableDataWithParams<T, P, E>;

/**
 * Hook to simplify usage of {@link LazyLoadableDataWithParams} type in React
 * @param fetch function which requires params P and returns Promise<T>, representing async action
 */
export const useLazyLoadableDataWithParams = <T, P, E = Error>(
  fetch: (params: P) => Promise<T>,
  initialState: LazyLoadableDataWithParams<T, P, E> = { type: "not_asked" }
): [
  LazyLoadableDataWithParams<T, P, E>,
  Dispatch<SetStateAction<LazyLoadableDataWithParams<T, P, E>>>
] => {
  const fetchRef = useLiveRef(fetch);
  const { cancellify, isCancelled } = useCancellify();
  const [state, setState] =
    useState<LazyLoadableDataWithParams<T, P, E>>(initialState);

  useEffect(() => {
    if (state.type === "loading") {
      const stateParams = state.params;
      const { promise, cancel } = cancellify(fetchRef.current(stateParams));

      promise
        .then((data) => {
          setState({ type: "loaded", data, params: stateParams });
        })
        .catch((error) => {
          if (isCancelled(error)) {
            return;
          }
          setState({ type: "error", error, params: stateParams });
        });

      return cancel;
    }

    return noop;
  }, [fetchRef, state.type, state.params, cancellify, isCancelled]);

  return [state, setState];
};
