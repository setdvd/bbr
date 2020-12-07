module Commit exposing (..)

import API
import Credentials exposing (Credentials)
import Http
import Json.Decode
import Task exposing (Task)


type alias Commit =
    { url : String
    , status : String
    }


type alias Status =
    String


decode : Json.Decode.Decoder String
decode =
    Json.Decode.at [ "links", "statuses", "href" ] Json.Decode.string


decodeStatus : Json.Decode.Decoder Status
decodeStatus =
    Json.Decode.field "values"
        (Json.Decode.list (Json.Decode.field "state" Json.Decode.string))
        |> Json.Decode.map (\ss -> Maybe.withDefault "unknown" (List.head ss))


fetch : Credentials -> String -> Task Http.Error Status
fetch credentials url =
    API.get
        { url = url
        , creds = credentials
        , decoder = decode
        }
        |> Task.andThen (fetchCommitStatus credentials)


fetchCommitStatus : Credentials -> String -> Task Http.Error Status
fetchCommitStatus credentials url =
    API.get { url = url, creds = credentials, decoder = decodeStatus }
