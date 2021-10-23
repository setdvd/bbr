import { notReachable } from "src/toolkit/notReachable"
import { MergeStrategy } from "../MergeStrategy"

export const getLabel = (strategy: MergeStrategy): string => {
  switch (strategy) {
    case "fast_forward":
      return "Fast forward"

    case "merge":
      return "Merge commit"

    case "squash":
      return "Squash"

    default:
      return notReachable(strategy)
  }
}
