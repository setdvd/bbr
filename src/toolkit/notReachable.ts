export const notReachable = (_: never): never => {
  throw new Error(`should never be reached ${_}`);
};
