module Commit exposing (Commit, fetch)

import API
import Credentials exposing (Credentials)
import Http
import Json.Decode
import Json.Decode.Pipeline
import Task exposing (Task)


type alias Commit =
    { url : String
    , statusUrl : String
    }


decode : String -> Json.Decode.Decoder Commit
decode url =
    Json.Decode.succeed (Commit url)
        |> Json.Decode.Pipeline.requiredAt [ "links", "statuses", "href" ] Json.Decode.string


fetch : Credentials -> String -> Task Http.Error Commit
fetch credentials url =
    API.get
        { url = url
        , creds = credentials
        , decoder = decode url
        }
