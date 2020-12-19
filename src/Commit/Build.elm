module Commit.Build exposing
    ( Build
    , Status(..)
    , fetch
    , shouldNotify
    , statusToString
    , viewBuildStatusString
    , viewStateIcon
    )

import API
import Credentials exposing (Credentials)
import Element exposing (Element)
import Element.Font
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required, requiredAt)
import Task exposing (Task)
import UI
import UI.Color
import UI.Icons


type alias BuildInfo =
    { uuid : String
    , status : Status
    , buildURL : String
    , name : String
    , description : String
    }


type Build
    = Empty
    | Started BuildInfo


type Status
    = InProgress
    | Success
    | Failed
    | Stopped


decodeStatus : Json.Decode.Decoder Status
decodeStatus =
    let
        get : String -> Json.Decode.Decoder Status
        get id =
            case id of
                "INPROGRESS" ->
                    Json.Decode.succeed InProgress

                "SUCCESSFUL" ->
                    Json.Decode.succeed Success

                "FAILED" ->
                    Json.Decode.succeed Failed

                "STOPPED" ->
                    Json.Decode.succeed Stopped

                xx ->
                    Json.Decode.fail ("unknown value for Status: " ++ xx)
    in
    Json.Decode.string |> Json.Decode.andThen get


decode : Json.Decode.Decoder BuildInfo
decode =
    Json.Decode.succeed BuildInfo
        |> required "key" Json.Decode.string
        |> required "state" decodeStatus
        |> required "url" Json.Decode.string
        |> required "name" Json.Decode.string
        |> required "description" Json.Decode.string


decodeList : Json.Decode.Decoder Build
decodeList =
    Json.Decode.at [ "values" ] (Json.Decode.list decode)
        |> Json.Decode.andThen decodeListHelper


decodeListHelper : List BuildInfo -> Json.Decode.Decoder Build
decodeListHelper builds =
    case List.head builds of
        Just x ->
            Json.Decode.succeed <| Started x

        Nothing ->
            Json.Decode.succeed Empty


fetch : Credentials -> String -> Task Http.Error Build
fetch credentials url =
    API.get
        { url = url
        , creds = credentials
        , decoder = decodeList
        }


viewBuildStatusString : Build -> Element msg
viewBuildStatusString build =
    let
        buildString =
            "Build: " ++ statusToString build

        color =
            case build of
                Empty ->
                    UI.Color.grey50

                Started buildInfo ->
                    case buildInfo.status of
                        InProgress ->
                            UI.Color.grey50

                        Success ->
                            UI.Color.grey50

                        Failed ->
                            UI.Color.error

                        Stopped ->
                            UI.Color.error
    in
    Element.el
        [ Element.Font.color color ]
        (Element.text buildString)


statusToString : Build -> String
statusToString build =
    case build of
        Empty ->
            "not started"

        Started buildInfo ->
            case buildInfo.status of
                InProgress ->
                    "in progress"

                Success ->
                    "success"

                Failed ->
                    "failed"

                Stopped ->
                    "stopped"


viewStateIcon : Build -> UI.Attributes msg -> Element msg
viewStateIcon build attributes =
    let
        container =
            UI.container ([ UI.rect 24 ] ++ attributes)
    in
    case build of
        Empty ->
            container (UI.Icons.blur UI.Color.grey50)

        Started buildInfo ->
            container <|
                case buildInfo.status of
                    InProgress ->
                        UI.Icons.clock UI.Color.grey50

                    Success ->
                        UI.Icons.done UI.Color.success

                    Failed ->
                        UI.Icons.report UI.Color.error

                    Stopped ->
                        UI.Icons.report UI.Color.error


shouldNotify : Build -> Build -> Bool
shouldNotify old new =
    let
        helper : Status -> Bool
        helper status =
            case status of
                InProgress ->
                    False

                Success ->
                    True

                Failed ->
                    True

                Stopped ->
                    True
    in
    case ( old, new ) of
        ( _, Empty ) ->
            False

        ( Empty, Started info ) ->
            helper info.status

        ( Started oldInfo, Started newInfo ) ->
            if oldInfo.status == newInfo.status then
                False

            else
                helper newInfo.status
