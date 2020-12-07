port module Main exposing (..)

import Browser
import Credentials exposing (Credentials)
import Element exposing (Element)
import Element.Background
import Element.Font
import Html exposing (Html)
import Json.Decode
import Login
import Repo exposing (Repo)
import UI.Color


port notification : { status : String } -> Cmd msg



---- MODEL ----


type Model
    = Login Login.Model
    | PRs Credentials Repo.Model


init : Json.Decode.Value -> ( Model, Cmd Msg )
init flag =
    let
        credResult : Result Json.Decode.Error Credentials
        credResult =
            Json.Decode.decodeValue Credentials.decode flag
    in
    case credResult of
        Ok cred ->
            let
                ( m, c ) =
                    Repo.init { credentials = cred, data = [] }
            in
            ( PRs cred m, Cmd.map PRsMsg c )

        Err _ ->
            ( Login (Login.init { username = "", password = "" }), Cmd.none )



---- UPDATE ----


type Msg
    = LoginMsg Login.Msg
    | PRsMsg Repo.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoginMsg loginMsg, Login loginModel ) ->
            case Login.update loginModel loginMsg of
                ( _, _, Just (Login.LoggedIn data) ) ->
                    let
                        cred =
                            Credentials.init data

                        ( prsModel, prsCMD ) =
                            Repo.init { credentials = cred, data = data.data }

                        cmd =
                            Cmd.map PRsMsg prsCMD
                    in
                    ( PRs cred prsModel, Cmd.batch [ cmd, Credentials.save cred ] )

                ( newLoginModel, cmd, Nothing ) ->
                    ( Login newLoginModel, Cmd.map LoginMsg cmd )

        ( PRsMsg prMsg, PRs cred prModel ) ->
            case Repo.update cred prModel prMsg of
                ( _, _, Just Repo.Logout ) ->
                    ( Login <| Login.init { username = Tuple.first cred, password = "" }, Cmd.none )

                ( newModel, newCmd, Just (Repo.PRDataChanged status) ) ->
                    ( PRs cred newModel, Cmd.batch [ Cmd.map PRsMsg newCmd, notification { status = status } ] )

                ( newModel, newCmd, Nothing ) ->
                    ( PRs cred newModel, Cmd.map PRsMsg newCmd )

        ( _, _ ) ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout
        [ Element.Font.size 16
        , Element.Font.color UI.Color.black
        , Element.Font.alignLeft
        , Element.Background.color UI.Color.greyTone5
        , Element.height Element.fill
        , Element.width Element.fill
        ]
        (case model of
            Login loginModel ->
                Element.map LoginMsg <| Login.view loginModel

            PRs _ prsModel ->
                Element.map PRsMsg <| Repo.view prsModel
        )



---- PROGRAM ----


main : Program Json.Decode.Value Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
