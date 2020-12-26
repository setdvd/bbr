module Settings exposing (..)

import PR.Merge exposing (MergeRule)


type alias Settings =
    { myPRPollInterval : Int
    , mergeStrategy : PR.Merge.Strategy
    , mergeRule : MergeRule
    }


defaultSettings : Settings
defaultSettings =
    { myPRPollInterval = 1000 * 60 * 5
    , mergeStrategy = PR.Merge.defaultStrategy
    , mergeRule = PR.Merge.defaultMergeRule
    }
