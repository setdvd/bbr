module User exposing (PR, User, init)

import Credentials exposing (Credentials)
import Json.Decode
import Json.Decode.Pipeline exposing (required)


type alias User =
    Credentials


init : { a | username : String, password : String } -> User
init =
    Credentials.init


type alias PR =
    { id : String
    , title : String
    }


decodePRList : Json.Decode.Decoder (List PR)
decodePRList =
    Json.Decode.field "values" <|
        Json.Decode.list
            (Json.Decode.succeed PR
                |> required "id" Json.Decode.string
                |> required "title" Json.Decode.string
            )



--
--fetchUserPRs : User -> (RemoteData.WebData (List PR) -> msg) -> Cmd msg
--fetchUserPRs { username, password } toMsg =
--    Http.get
--        { url = apiUrl username password ("/pullrequests/" ++ username ++ "?state=MERGED")
--        , expect = Http.expectJson (RemoteData.fromResult >> toMsg) decodePRList
--        }
--
--
--checkAccess : User -> (RemoteData.WebData Bool -> msg) -> Cmd msg
--checkAccess user toMsg =
--    Http.get
--        { url = apiUrl user.username user.password "/user"
--        , expect = Http.expectJson (RemoteData.fromResult >> toMsg) (Json.Decode.succeed True)
--        }
--
--
--x =
--    Http.task
