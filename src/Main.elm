port module Main exposing (..)

import Browser
import Commit.Build
import Credentials exposing (Credentials)
import Element exposing (Element)
import Element.Background
import Element.Font
import Global exposing (Global)
import Html exposing (Html)
import Json.Decode
import Login
import PR.Page
import Settings
import UI.Color


type alias Notification =
    { title : String, description : String }


port notification : Notification -> Cmd msg



---- MODEL ----


type Model
    = Login Login.Model
    | PRs Global PR.Page.Model


versionDecoder : Json.Decode.Decoder String
versionDecoder =
    Json.Decode.field "version" Json.Decode.string


init : Json.Decode.Value -> ( Model, Cmd Msg )
init flag =
    let
        credResult : Result Json.Decode.Error Credentials
        credResult =
            Json.Decode.decodeValue (Json.Decode.field "cred" Credentials.decode) flag

        -- TODO: Show version
        --       milestone: v0.1
        version : Maybe String
        version =
            flag
                |> Json.Decode.decodeValue versionDecoder
                |> Result.toMaybe
    in
    case credResult of
        Ok cred ->
            let
                ( prModel, cmd ) =
                    PR.Page.init cred

                global =
                    Global Settings.defaultSettings cred
            in
            ( PRs
                global
                prModel
            , Cmd.map PRsMsg cmd
            )

        Err _ ->
            ( Login (Login.init { username = "", password = "" }), Cmd.none )



---- UPDATE ----


type Msg
    = LoginMsg Login.Msg
    | PRsMsg PR.Page.Msg


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
                            PR.Page.init cred

                        cmd =
                            Cmd.map PRsMsg prsCMD

                        global =
                            Global Settings.defaultSettings cred
                    in
                    ( PRs global prsModel, Cmd.batch [ cmd, Credentials.save cred ] )

                ( newLoginModel, cmd, Nothing ) ->
                    ( Login newLoginModel, Cmd.map LoginMsg cmd )

        ( PRsMsg prMsg, PRs global prModel ) ->
            case PR.Page.update global prModel prMsg of
                ( newModel, newCmd, Nothing ) ->
                    ( PRs global newModel, Cmd.map PRsMsg newCmd )

                ( newModel, newCmd, Just (PR.Page.PRItemUpdated info) ) ->
                    let
                        notificationList =
                            info
                                |> PR.Page.notification
                                |> List.map notification
                    in
                    ( PRs global newModel, Cmd.batch ([ Cmd.map PRsMsg newCmd ] ++ notificationList) )

        ( _, _ ) ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Element.layout
        [ Element.Font.size 14
        , Element.Font.color UI.Color.black
        , Element.Font.alignLeft
        , Element.Background.color UI.Color.grey5
        , Element.height Element.fill
        , Element.width Element.fill
        ]
        (case model of
            Login loginModel ->
                Element.map LoginMsg <| Login.view loginModel

            PRs global prsModel ->
                Element.map PRsMsg <| PR.Page.view global prsModel
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



---- BACKLOG ----
--  TODO add decoding error reporting
--       add sentry reporting on decode errors
--       milestone: v0.1
