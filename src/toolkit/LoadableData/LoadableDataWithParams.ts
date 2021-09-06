import { Dispatch, SetStateAction, useEffect, useState } from "react";

import * as Primitive from "./Primitive";
import { useLiveRef } from "../useLiveRef";
import { useCancellify } from "../useCancellify";

/**
 * Type representing async process which starts immediately and require parameters to start
 * @typeParam T Type of result
 * @typeParam P Type of parameters
 * @typeParam E Type of error which can happen during async process
 */
export type LoadableDataWithParams<T, P, E = Error> =
  | (Primitive.Loading & Primitive.Params<P>)
  | (Primitive.Loaded<T> & Primitive.Params<P>)
  | (Primitive.Failed<E> & Primitive.Params<P>);

/**
 * Hook to simplify usage of {@link LoadableDataWithParams} type in React
 * @param fetch function which requires params P and returns Promise<T>, representing async action
 */
export const useLoadableDataWithParams = <T, P, E = Error>(
  fetch: (params: P) => Promise<T>,
  initialState: LoadableDataWithParams<T, P, E>
): [
  LoadableDataWithParams<T, P, E>,
  Dispatch<SetStateAction<LoadableDataWithParams<T, P, E>>>
] => {
  const fetchRef = useLiveRef(fetch);
  const { cancellify, isCancelled } = useCancellify();
  const [state, setState] =
    useState<LoadableDataWithParams<T, P, E>>(initialState);

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
    return () => {};
  }, [fetchRef, state.type, state.params, cancellify, isCancelled]);

  return [state, setState];
};
