import { notReachable } from "src/toolkit/notReachable";

interface InstanceMethods {
  andThen<E, T, T1>(
    this: Result<E, T>,
    cb: (arg: T) => Result<E, T1>
  ): Result<E, T1>;

  map<E, T, T1>(this: Result<E, T>, cb: (arg: T) => T1): Result<E, T1>;
  mapError<E, E1, T>(this: Result<E, T>, cb: (arg: E) => E1): Result<E1, T>;

  getFailureReason<E, T>(this: Result<E, T>): E | undefined;
}

class Failure<E> implements InstanceMethods {
  readonly type = "Failure";

  readonly reason: E;

  constructor(reason: E) {
    this.reason = reason;
  }

  andThen<E, E1, T, T1>(
    this: Result<E, T>,
    cb: (arg: T) => Result<E1, T1>
  ): Result<E | E1, T1> {
    return then(this, cb);
  }

  getFailureReason<E, T>(this: Result<E, T>): E | undefined {
    return getFailureReason(this);
  }

  getSuccessResult<E, T>(this: Result<E, T>): T | undefined {
    return getSuccessResult(this);
  }

  getSuccessResultOrThrow<E, T>(this: Result<E, T>): T {
    return getSuccessResultOrThrow(this);
  }

  map<E, T, T1>(this: Result<E, T>, cb: (arg: T) => T1): Result<E, T1> {
    return map(this, cb);
  }

  mapError<E, E1, T>(this: Result<E, T>, cb: (arg: E) => E1): Result<E1, T> {
    return mapError(this, cb);
  }
}

class Success<T> implements InstanceMethods {
  readonly type = "Success";

  readonly data: T;

  constructor(data: T) {
    this.data = data;
  }

  andThen<E, E1, T, T1>(
    this: Result<E, T>,
    cb: (arg: T) => Result<E1, T1>
  ): Result<E | E1, T1> {
    return then(this, cb);
  }

  map<E, T, T1>(this: Result<E, T>, cb: (arg: T) => T1): Result<E, T1> {
    return map(this, cb);
  }

  mapError<E, E1, T>(this: Result<E, T>, cb: (arg: E) => E1): Result<E1, T> {
    return mapError(this, cb);
  }

  getFailureReason<E, T>(this: Result<E, T>): E | undefined {
    return getFailureReason(this);
  }

  getSuccessResult<E, T>(this: Result<E, T>): T | undefined {
    return getSuccessResult(this);
  }

  getSuccessResultOrThrow<E, T>(this: Result<E, T>): T {
    return getSuccessResultOrThrow(this);
  }
}

const getSuccessResultOrThrow = <E, T>(result: Result<E, T>): T => {
  switch (result.type) {
    case "Failure":
      throw new Error(
        `Expected Success result but got Failure instead: ${JSON.stringify(
          result.reason,
          undefined,
          4
        )} `
      );
    case "Success":
      return result.data;
    default:
      /* istanbul ignore next */
      return notReachable(result);
  }
};

const map = <E, T, T1>(
  result: Result<E, T>,
  cb: (result: T) => T1
): Result<E, T1> => {
  switch (result.type) {
    case "Failure":
      return result;
    case "Success":
      return success(cb(result.data));
    default:
      return notReachable(result);
  }
};

const mapError = <E, E1, T>(
  result: Result<E, T>,
  cb: (error: E) => E1
): Result<E1, T> => {
  switch (result.type) {
    case "Failure":
      return failure(cb(result.reason));
    case "Success":
      return result;
    default:
      return notReachable(result);
  }
};

const then = <E, E1, T, T1>(
  result: Result<E, T>,
  cb: (result: T) => Result<E1, T1>
): Result<E | E1, T1> => {
  switch (result.type) {
    case "Failure":
      return result;
    case "Success":
      return cb(result.data);
    default:
      return notReachable(result);
  }
};

const getSuccessResult = <E, T>(result: Result<E, T>): T | undefined => {
  switch (result.type) {
    case "Failure":
      return undefined;
    case "Success":
      return result.data;
    default:
      return notReachable(result);
  }
};

const getFailureReason = <E, T>(result: Result<E, T>): E | undefined => {
  switch (result.type) {
    case "Failure":
      return result.reason;
    case "Success":
      return undefined;
    default:
      return notReachable(result);
  }
};

export type Result<E, T> = Failure<E> | Success<T>;

export const isFailure = <E, T>(result: Result<E, T>): result is Failure<E> =>
  result.type === "Failure";

export const isSuccess = <E, T>(result: Result<E, T>): result is Success<T> =>
  result.type === "Success";

// Constructors

export const failure = <E>(reason: E): Result<E, never> => {
  return new Failure<E>(reason);
};

export const success = <T>(data: T): Result<never, T> => {
  return new Success<T>(data);
};

// Combinators

/**
 * Converts array of Result into Result with Errors for failure and Types for success
 * When at least 1 failure => Failure
 *
 * @params results - A non empty array of results
 * @returns Result with all failures or success with all data
 */
export const combine = <E, T>(results: Result<E, T>[]): Result<E[], T[]> => {
  const failureReasons: E[] = [];
  const successData: T[] = [];
  results.forEach((result) => {
    switch (result.type) {
      case "Failure":
        failureReasons.push(result.reason);
        break;
      case "Success":
        successData.push(result.data);
        break;
      default:
        /* istanbul ignore next */
        notReachable(result);
    }
  });
  return failureReasons.length ? failure(failureReasons) : success(successData);
};

/**
 * Tries to find result of type `Success` within given array of results.
 *
 * @param results - A non empty array of results to try searching one of type `Success` within.
 * @returns Either first found `Success` or first found `Failure` (in case of there is no `Success` found).
 */

export function oneOf<T0, T1, E0, E1>(
  arr: [Result<E0, T0>, Result<E1, T1>]
): Result<E0 | E1, T0 | T1>;

export function oneOf<T0, T1, T2, E0, E1, E2>(
  arr: [Result<E0, T0>, Result<E1, T1>, Result<E2, T2>]
): Result<E0 | E1 | E2, T0 | T1 | T2>;

export function oneOf<T0, T1, T2, T3, E0, E1, E2, E3>(
  arr: [Result<E0, T0>, Result<E1, T1>, Result<E2, T2>, Result<E3, T3>]
): Result<E0 | E1 | E2 | E3, T0 | T1 | T2 | T3>;

export function oneOf<T0, T1, T2, T3, T4, E0, E1, E2, E3, E4>(
  arr: [
    Result<E0, T0>,
    Result<E1, T1>,
    Result<E2, T2>,
    Result<E3, T3>,
    Result<E4, T4>
  ]
): Result<E0 | E1 | E2 | E3 | E4, T0 | T1 | T2 | T3 | T4>;

export function oneOf<T0, T1, T2, T3, T4, T5, E0, E1, E2, E3, E4, E5>(
  arr: [
    Result<E0, T0>,
    Result<E1, T1>,
    Result<E2, T2>,
    Result<E3, T3>,
    Result<E4, T4>,
    Result<E5, T5>
  ]
): Result<E0 | E1 | E2 | E3 | E4 | E5, T0 | T1 | T2 | T3 | T4 | T5>;

export function oneOf<T0, T1, T2, T3, T4, T5, T6, E0, E1, E2, E3, E4, E5, E6>(
  arr: [
    Result<E0, T0>,
    Result<E1, T1>,
    Result<E2, T2>,
    Result<E3, T3>,
    Result<E4, T4>,
    Result<E5, T5>,
    Result<E6, T6>
  ]
): Result<E0 | E1 | E2 | E3 | E4 | E5 | E6, T0 | T1 | T2 | T3 | T4 | T5 | T6>;

export function oneOf<
  T0,
  T1,
  T2,
  T3,
  T4,
  T5,
  T6,
  T7,
  E0,
  E1,
  E2,
  E3,
  E4,
  E5,
  E6,
  E7
>(
  arr: [
    Result<E0, T0>,
    Result<E1, T1>,
    Result<E2, T2>,
    Result<E3, T3>,
    Result<E4, T4>,
    Result<E5, T5>,
    Result<E6, T6>,
    Result<E7, T7>
  ]
): Result<
  E0 | E1 | E2 | E3 | E4 | E5 | E6 | E7,
  T0 | T1 | T2 | T3 | T4 | T5 | T6 | T7
>;

export function oneOf<
  T extends Result<any, any>,
  T1 extends T[],
  R extends Extract<T1[keyof T1], { type: "Failure" | "Success" }>
>(results: T1): R {
  const foundResult =
    results.find((result) => isSuccess(result)) ||
    results.find((result) => isFailure(result));

  // Basically this throw is needed to satisfy TS after `array.find` usage.
  // Given that input is `NonEmptyArray` by static type, it should be impossible
  // to pass an empty array here being in compile-time-safe world.
  if (!foundResult) {
    throw new Error(
      "Unreachable statement. There is neither success nor failure result found"
    );
  }

  return foundResult as R;
}

type Ext<T extends { [key: string]: Result<any, any> }> = Result<
  {
    [K in keyof T]?: T[K] extends Result<infer Err, any> ? Err : never;
  },
  {
    [K in keyof T]: T[K] extends Result<any, infer R> ? R : never;
  }
>;

export const object = <Conf extends { [key: string]: Result<any, any> }>(
  config: Conf
): Ext<Conf> => {
  const error = {} as any;
  const out = {} as any;
  Object.keys(config).forEach((key) => {
    const typedKey = key;
    const result = config[typedKey];
    switch (result.type) {
      case "Failure":
        error[typedKey] = result.reason;
        break;
      case "Success":
        out[typedKey] = result.data;
        break;
      default:
        notReachable(result);
    }
  });

  if (Object.keys(error).length === 0) {
    return success(out);
  }
  return failure(error);
};

// validators

export const string = <E = { type: "value_is_not_a_string"; value: unknown }>(
  value: unknown,
  error?: E
): Result<E, string> => {
  if (typeof value === "string") {
    return success(value);
  }
  return failure(
    error ?? ({ type: "value_is_not_a_string" as const, value } as any as E)
  );
};

export const match = <
  T,
  E = {
    type: "value_is_not_matching_with_reference";
    value: unknown;
    matchValue: T;
  }
>(
  value: unknown,
  matchValue: T,
  error?: E
): Result<E, T> => {
  if (value === matchValue) {
    return success(matchValue);
  }

  return failure(
    error ??
      ({
        type: "value_is_not_matching_with_reference" as const,
        matchValue,
        value,
      } as unknown as E)
  );
};

export const number = <E = { type: "value_is_not_a_number"; value: unknown }>(
  value: unknown,
  error?: E
): Result<E, number> => {
  if (typeof value === "number") {
    return success(value);
  }
  return failure(
    error ?? ({ type: "value_is_not_a_number" as const, value } as any as E)
  );
};

export const nullable = <E = { type: "value_not_null"; value: unknown }>(
  value: unknown,
  error?: E
): Result<E, null> => {
  if (value === null || value === undefined) {
    return success(null);
  }
  return failure(
    error ?? ({ type: "value_not_null" as const, value } as any as E)
  );
};

export const required = <T, E = { type: "value_is_required"; value: unknown }>(
  value: T,
  error?: E
): Result<E, T extends null | undefined ? never : T> => {
  if (value === null || value === undefined) {
    return failure(
      error ?? ({ type: "value_is_required" as const, value } as any as E)
    );
  }
  return success(value as any);
};

export const boolean = <E = { type: "value_is_not_a_bool"; value: unknown }>(
  value: unknown,
  error?: E
): Result<E, boolean> => {
  if (typeof value === "boolean") {
    return success(value);
  }
  return failure(
    error ?? ({ type: "value_is_not_a_bool" as const, value } as any as E)
  );
};

type Falsy = 0 | null | undefined | false | "";
type NotFalsy<T> = T extends Falsy ? never : T;

export const notEmpty = <T, E = { type: "value_is_empty"; value: unknown }>(
  value: T,
  error?: E
): Result<E, NotFalsy<T>> => {
  if (value) {
    success(value);
  }
  return failure(error ?? ({ type: "value_is_empty", value } as any));
};
