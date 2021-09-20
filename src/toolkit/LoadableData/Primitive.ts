export type Loading = { type: "loading" };

export type Reloading<T> = { type: "reloading"; data: T };

export type Loaded<T> = { type: "loaded"; data: T };

export type Failed<E = Error> = { type: "error"; error: E };

export type SubsequentFailed<T, E = Error> = {
  type: "subsequent_failed";
  error: E;
  data: T;
};

export type NotAsked = { type: "not_asked" };

export type Params<P> = { params: P };

export type ParamsStub = Partial<Params<never>>;
