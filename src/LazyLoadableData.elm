module LazyLoadableData exposing (..)


type LazyLoadableData e t
    = NotAsked
    | Loading
    | Loaded (Result e t)
