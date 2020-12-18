module PR.DiffStat exposing (..)

import API
import Credentials exposing (Credentials)
import Http
import Json.Decode
import PR exposing (PR)
import Task exposing (Task)


type alias PRDiffStat =
    Bool


decodeState : Json.Decode.Decoder Bool
decodeState =
    Json.Decode.field "status" Json.Decode.string
        |> Json.Decode.map
            (\status ->
                case status of
                    "merge conflict" ->
                        True

                    _ ->
                        False
            )


decode : Json.Decode.Decoder PRDiffStat
decode =
    Json.Decode.field "values" (Json.Decode.list decodeState)
        |> Json.Decode.map (List.any identity)


fetch : Credentials -> PR -> Task Http.Error PRDiffStat
fetch credentials pr =
    API.get
        { url = pr.diffStatUrl
        , creds = credentials
        , decoder = decode
        }
