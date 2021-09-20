import { useRef, useEffect } from 'react'

type Cancellable<T> = { promise: Promise<T>; cancel: () => void }

export class CancellationError extends Error {}

function isCancelled(error: Error): error is CancellationError {
  return error instanceof CancellationError
}

/**
 * A helper to cancel promise resolve/reject handling.
 * Considered as canceled when:
 * 1. A consumer unmounts
 * 2. A user invokes cancel function manually
 */
export function useCancellify() {
  const isMountedRef = useRef(true)
  useEffect(
    () => () => {
      isMountedRef.current = false
    },
    []
  )

  function cancellify<T>(promise: Promise<T>): Cancellable<T> {
    let isManuallyCancelled = false

    function cancel() {
      isManuallyCancelled = true
    }

    const wrappedPromise = new Promise<T>((resolve, reject) => {
      promise
        .then((value) => {
          const shouldResolve = isMountedRef.current && !isManuallyCancelled
          if (shouldResolve) {
            resolve(value)
          } else {
            reject(new CancellationError())
          }
        })
        .catch((error) => {
          const shouldForwardPromiseError =
            isMountedRef.current && !isManuallyCancelled
          if (shouldForwardPromiseError) {
            reject(error)
          } else {
            reject(new CancellationError())
          }
        })
    })

    return { promise: wrappedPromise, cancel }
  }
  const cancellifyRef = useRef(cancellify)

  // If you by some reason adding something new here, make sure its pointer stability
  // is tested like it's done for `isCancelled` and `cancellify`
  return { isCancelled, cancellify: cancellifyRef.current }
}
