import { MergeStrategy } from "../MergeStrategy"

const strategies: Record<MergeStrategy, true> = {
  fast_forward: true,
  merge: true,
  squash: true,
}

export const getAllMergeStrategies = (): MergeStrategy[] =>
  Object.keys(strategies) as MergeStrategy[]
