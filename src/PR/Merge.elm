module PR.Merge exposing (..)

import API
import Credentials exposing (Credentials)
import Http
import Json.Decode
import Json.Encode
import PR exposing (PR)
import Task exposing (Task)


type alias MergeRule =
    { minNumberOfBuildsToPass : Int
    , numberOfApproves : Int
    , openTasks : Bool
    }


defaultMergeRule : MergeRule
defaultMergeRule =
    { minNumberOfBuildsToPass = 1
    , numberOfApproves = 1
    , openTasks = True
    }


defaultMergeMessage : PR -> String
defaultMergeMessage pr =
    "Merged in " ++ pr.name ++ "(pull request #" ++ String.fromInt pr.id ++ ")"


type Strategy
    = Merge
    | Squash
    | FastForward


defaultStrategy : Strategy
defaultStrategy =
    Merge


strategyToString : Strategy -> String
strategyToString strategy =
    case strategy of
        Merge ->
            "merge_commit"

        Squash ->
            "squash"

        FastForward ->
            "fast_forward"



--  TODO handle delayed merge response
--       bb can response 204 with merge request id if merge takes to long to complete
--       milestone: v0.2


merge : Credentials -> PR -> Task Http.Error ()
merge cred pr =
    API.post
        { url = pr.mergeUrl
        , creds = cred
        , decoder = Json.Decode.succeed ()
        , body =
            Json.Encode.object
                [ ( "message", Json.Encode.string <| defaultMergeMessage pr )
                , ( "merge_strategy", Json.Encode.string <| strategyToString defaultStrategy )
                ]
        }
