module User exposing (User, fetch)

import API
import Credentials exposing (Credentials)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required, requiredAt)
import Task exposing (Task)


type alias User =
    { uuid : String
    , username : String
    , displayName : String
    , avatarURL : String
    }


decode : Json.Decode.Decoder User
decode =
    Json.Decode.succeed User
        |> required "uuid" Json.Decode.string
        |> required "username" Json.Decode.string
        |> required "display_name" Json.Decode.string
        |> requiredAt [ "links", "avatar", "href" ] Json.Decode.string


fetch : Credentials -> Task Http.Error User
fetch credentials =
    API.get
        { url = API.baseUrl ++ "/user"
        , decoder = decode
        , creds = credentials
        }
