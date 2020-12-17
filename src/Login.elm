module Login exposing (..)

import Credentials
import Element exposing (Element)
import Http
import PR exposing (PR)
import RemoteData
import Task
import UI.Icons
import UI.Input
import UI.Layout


type alias Model =
    { username : String
    , password : String
    , submit : RemoteData.WebData (List PR)
    }


init : { a | username : String, password : String } -> Model
init { username, password } =
    Model username password RemoteData.NotAsked


type Msg
    = PasswordChange String
    | UsernameChange String
    | SubmitClick
    | SubmitFetched (Result Http.Error (List PR))


type External
    = LoggedIn
        { username : String
        , password : String
        , data : List PR
        }


update : Model -> Msg -> ( Model, Cmd Msg, Maybe External )
update model msg =
    case msg of
        PasswordChange string ->
            ( { model | password = string, submit = RemoteData.NotAsked }, Cmd.none, Nothing )

        UsernameChange string ->
            ( { model | username = string, submit = RemoteData.NotAsked }, Cmd.none, Nothing )

        -- TODO: fetch user object on login [P3] [S]
        SubmitClick ->
            ( { model | submit = RemoteData.Loading }, Task.attempt SubmitFetched (PR.fetchOpenPRs (Credentials.init model)), Nothing )

        SubmitFetched result ->
            case result of
                Ok value ->
                    ( model, Cmd.none, Just <| LoggedIn { username = model.username, password = model.password, data = value } )

                Err _ ->
                    ( { model | submit = RemoteData.fromResult result }, Cmd.none, Nothing )


view : Model -> Element Msg
view { username, password, submit } =
    let
        submitButtonConfig =
            if RemoteData.isLoading submit then
                { onClick = Nothing
                , label = "Login"
                , icon = Just UI.Icons.circularProgress
                }

            else
                { onClick = Just SubmitClick
                , label = "Login"
                , icon = Nothing
                }

        errorBlock : Maybe String
        errorBlock =
            Maybe.map
                errorToString
                (errored submit)
    in
    UI.Layout.page
        [ [ Element.spacing 16 ]
        ]
        [ UI.Layout.header [] "Login with Bitbucket"
        , UI.Input.text []
            { onChange = UsernameChange
            , text = username
            , placeholder = Just "your bitbucket username"
            , label = "Username"
            , error = Nothing
            }
        , UI.Input.text []
            { onChange = PasswordChange
            , text = password
            , placeholder = Just "bit bucket app password"
            , label = "Password"
            , error = errorBlock
            }
        , UI.Layout.actions []
            [ UI.Input.button []
                submitButtonConfig
            ]
        ]



--- Helper


errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadUrl string ->
            "Bad url: " ++ string

        Http.Timeout ->
            "request timeout"

        Http.NetworkError ->
            "Network is down"

        -- TODO: add generic error handler to parse common BB errors [P1] [S]
        Http.BadStatus status ->
            case status of
                401 ->
                    "Username or password is incorrect"

                403 ->
                    "You don't have access to read PRs, check access permissions in BB"

                code ->
                    "Server is down with status: " ++ String.fromInt code

        Http.BadBody string ->
            "Got unexpected response from server : \n " ++ string


errored : RemoteData.WebData a -> Maybe Http.Error
errored webData =
    case webData of
        RemoteData.NotAsked ->
            Nothing

        RemoteData.Loading ->
            Nothing

        RemoteData.Failure e ->
            Just e

        RemoteData.Success a ->
            Nothing
