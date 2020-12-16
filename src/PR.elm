module PR exposing (PR, fetchOpenPRs)

import API
import Credentials exposing (Credentials)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required, requiredAt)
import Task exposing (Task)


type alias PR =
    { id : Int
    , name : String
    , commitUrl : String
    }


decode : Json.Decode.Decoder PR
decode =
    Json.Decode.succeed PR
        |> required "id" Json.Decode.int
        |> required "title" Json.Decode.string
        |> requiredAt [ "source", "commit", "links", "self", "href" ] Json.Decode.string


decodePRList : Json.Decode.Decoder (List PR)
decodePRList =
    Json.Decode.field "values" <| Json.Decode.list decode


fetchOpenPRs : Credentials -> Task Http.Error (List PR)
fetchOpenPRs credentials =
    API.get
        { url = API.baseUrl ++ "/pullrequests/" ++ Tuple.first credentials
        , creds = credentials
        , decoder = decodePRList
        }
