module API exposing (baseUrl, get, post)

import Credentials exposing (Credentials)
import Http
import Json.Decode
import Json.Encode
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


type alias Params a =
    { url : String
    , creds : Credentials
    , decoder : Json.Decode.Decoder a
    }


type alias PostParams a =
    { url : String
    , creds : Credentials
    , decoder : Json.Decode.Decoder a
    , body : Json.Encode.Value
    }



-- TODO handle 429 rate limit


get : Params a -> Task Http.Error a
get { url, creds, decoder } =
    Http.task
        { method = "GET"
        , headers = [ Credentials.header creds ]
        , url = url
        , body = Http.emptyBody
        , resolver = Http.stringResolver (expectJson decoder)
        , timeout = Nothing
        }


post : PostParams a -> Task Http.Error a
post { url, creds, decoder, body } =
    Http.task
        { method = "POST"
        , headers = [ Credentials.header creds ]
        , url = url
        , body = Http.jsonBody body
        , resolver = Http.stringResolver (expectJson decoder)
        , timeout = Nothing
        }
