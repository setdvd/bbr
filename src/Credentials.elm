port module Credentials exposing (Credentials, decode, header, init, save)

import Base64
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required)


type Password
    = Password String


type alias Credentials =
    ( String, Password )


init : { a | username : String, password : String } -> Credentials
init { username, password } =
    ( username, Password password )


header : Credentials -> Http.Header
header ( username, Password password ) =
    Http.header "Authorization" ("Basic " ++ Base64.encode (username ++ ":" ++ password))


decode : Json.Decode.Decoder Credentials
decode =
    Json.Decode.succeed (\u p -> ( u, Password p ))
        |> required "username" Json.Decode.string
        |> required "password" Json.Decode.string


save : Credentials -> Cmd msg
save ( username, Password pass ) =
    saveCred { username = username, password = pass }


port saveCred : { username : String, password : String } -> Cmd msg
