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
import UI
import UI.Color
import UI.Font


type alias Notification =
    { title : String, description : String }


port notification : Notification -> Cmd msg



---- MODEL ----


type Model
    = Login String Login.Model
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

        version =
            flag
                |> Json.Decode.decodeValue versionDecoder
                |> Result.withDefault ""
    in
    case credResult of
        Ok cred ->
            let
                ( prModel, cmd ) =
                    PR.Page.init cred

                global =
                    { settings = Settings.defaultSettings
                    , credentials = cred
                    , version = version
                    }
            in
            ( PRs
                global
                prModel
            , Cmd.map PRsMsg cmd
            )

        Err _ ->
            ( Login version (Login.init { username = "", password = "" }), Cmd.none )



---- UPDATE ----


type Msg
    = LoginMsg Login.Msg
    | PRsMsg PR.Page.Msg


viewVersion : String -> Element Msg
viewVersion version =
    UI.fixed <|
        UI.el
            [ UI.Font.caption
            , [ Element.alignBottom
              , Element.alignRight
              , Element.padding 8
              , Element.spacing 4
              ]
            ]
            (UI.text <| "v" ++ version)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoginMsg loginMsg, Login version loginModel ) ->
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
                            { settings = Settings.defaultSettings
                            , credentials = cred
                            , version = version
                            }
                    in
                    ( PRs global prsModel, Cmd.batch [ cmd, Credentials.save cred ] )

                ( newLoginModel, cmd, Nothing ) ->
                    ( Login version newLoginModel, Cmd.map LoginMsg cmd )

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
    let
        container =
            UI.column [ UI.fillWH ]
    in
    Element.layout
        [ Element.Font.size 14
        , Element.Font.color UI.Color.black
        , Element.Font.alignLeft
        , Element.Background.color UI.Color.grey5
        , Element.height Element.fill
        , Element.width Element.fill
        ]
        (case model of
            Login version loginModel ->
                container [ Element.map LoginMsg <| Login.view loginModel, viewVersion version ]

            PRs global prsModel ->
                container [ Element.map PRsMsg <| PR.Page.view global prsModel, viewVersion global.version ]
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
