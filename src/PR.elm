module PR exposing (PR, PREssential, fetchOpenPRs, fetchOpenPRsEssential, fetchPRDetailsList, fetchPrDetails)

import API
import Credentials exposing (Credentials)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required, requiredAt)
import PR.Participant exposing (Participant)
import Task exposing (Task)
import Task.Extra


type alias PREssential =
    { id : Int
    , name : String
    , commitUrl : String
    , selfUrl : String
    }


type alias PR =
    { id : Int
    , name : String
    , commitUrl : String
    , selfUrl : String
    , participants : List Participant
    , mergeUrl : String
    , diffStatUrl : String
    }


decodePREssential : Json.Decode.Decoder PREssential
decodePREssential =
    Json.Decode.succeed PREssential
        |> required "id" Json.Decode.int
        |> required "title" Json.Decode.string
        |> requiredAt [ "source", "commit", "links", "self", "href" ] Json.Decode.string
        |> requiredAt [ "links", "self", "href" ] Json.Decode.string


decodePR : Json.Decode.Decoder PR
decodePR =
    Json.Decode.succeed PR
        |> required "id" Json.Decode.int
        |> required "title" Json.Decode.string
        |> requiredAt [ "source", "commit", "links", "self", "href" ] Json.Decode.string
        |> requiredAt [ "links", "self", "href" ] Json.Decode.string
        |> required "participants" (Json.Decode.list PR.Participant.decode)
        |> requiredAt [ "links", "merge", "href" ] Json.Decode.string
        |> requiredAt [ "links", "diffstat", "href" ] Json.Decode.string


decodePRList : Json.Decode.Decoder (List PREssential)
decodePRList =
    Json.Decode.field "values" <| Json.Decode.list decodePREssential


fetchPrDetails : Credentials -> PREssential -> Task Http.Error PR
fetchPrDetails credentials pr =
    API.get
        { url = pr.selfUrl
        , creds = credentials
        , decoder = decodePR
        }


fetchPRDetailsList : Credentials -> List PREssential -> Task Http.Error (List PR)
fetchPRDetailsList credentials prEssentials =
    prEssentials
        |> List.map (fetchPrDetails credentials)
        |> Task.Extra.traverse



-- TODO implement approve status for participants
--      [] we should see the number of approve PR has
--      [] if PR has 1 approve and successfully build we should get notification
--      labels: Focus


fetchOpenPRsEssential : Credentials -> Task Http.Error (List PREssential)
fetchOpenPRsEssential credentials =
    API.get
        { url = API.baseUrl ++ "/pullrequests/" ++ Tuple.first credentials
        , creds = credentials
        , decoder = decodePRList
        }


fetchOpenPRs : Credentials -> Task Http.Error (List PR)
fetchOpenPRs credentials =
    fetchOpenPRsEssential credentials
        |> Task.andThen (fetchPRDetailsList credentials)
