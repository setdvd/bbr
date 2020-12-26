module LoadableData exposing (..)


type LoadableData e t
    = Loading
    | Loaded (Result e t)
