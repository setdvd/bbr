module Task.Extra exposing (..)

import Task exposing (Task)


traverse : List (Task a b) -> Task a (List b)
traverse tasks =
    case tasks of
        [] ->
            Task.succeed []

        [ x ] ->
            Task.map List.singleton x

        x :: xs ->
            Task.map2 (\x_ xs_ -> x_ :: xs_) x (traverse xs)
