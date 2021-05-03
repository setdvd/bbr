module PR.DiffStat exposing (..)

import API
import Credentials exposing (Credentials)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required)
import PR exposing (PR)
import Task exposing (Task)


type alias PRDiffStat =
    { hasConflict : Bool
    , linesAdded : Int
    }


type alias DiffInfo =
    { hasConflict : Bool, linesAdded : Int }


decodeItem : Json.Decode.Decoder DiffInfo
decodeItem =
    Json.Decode.succeed DiffInfo
        |> required "status"
            (Json.Decode.string
                |> Json.Decode.map
                    (\status ->
                        case status of
                            "merge conflict" ->
                                True

                            _ ->
                                False
                    )
            )
        |> required "lines_added" Json.Decode.int


sum : Int -> Int -> Int
sum int1 int2 =
    int1 + int2


decode : Json.Decode.Decoder PRDiffStat
decode =
    Json.Decode.field "values" (Json.Decode.list decodeItem)
        |> Json.Decode.map (\items -> PRDiffStat (List.any (\x -> x.hasConflict) items) (List.foldl sum 0 (List.map .linesAdded items)))


fetch : Credentials -> PR -> Task Http.Error PRDiffStat
fetch credentials pr =
    API.get
        { url = pr.diffStatUrl
        , creds = credentials
        , decoder = decode
        }
