module API exposing (baseUrl, get)

import Credentials exposing (Credentials)
import Http
import Json.Decode
import Task exposing (Task)


expectJson : Json.Decode.Decoder a -> Http.Response String -> Result Http.Error a
expectJson decoder response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadStatus_ metadata body ->
            Err (Http.BadStatus metadata.statusCode)

        Http.GoodStatus_ metadata body ->
            case Json.Decode.decodeString decoder body of
                Ok value ->
                    Ok value

                Err err ->
                    Err (Http.BadBody (Json.Decode.errorToString err))


baseUrl : String
baseUrl =
    "https://api.bitbucket.org/2.0"


get :
    { url : String
    , creds : Credentials
    , decoder : Json.Decode.Decoder a
    }
    -> Task Http.Error a
get { url, creds, decoder } =
    Http.task
        { method = "GET"
        , headers = [ Credentials.header creds ]
        , url = url
        , body = Http.emptyBody
        , resolver = Http.stringResolver (expectJson decoder)
        , timeout = Nothing
        }
