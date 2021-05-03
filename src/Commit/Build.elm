module Commit.Build exposing
    ( Build(..)
    , Status(..)
    , fetch
    , isNewFailed
    , isPass
    , statusToString
    , transverse
    , viewBuildStatusString
    )

import API
import Credentials exposing (Credentials)
import Element exposing (Element)
import Element.Font
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required)
import Task exposing (Task)
import UI
import UI.Color


type alias BuildInfo =
    { uuid : String
    , status : Status
    , buildURL : String
    , name : String
    , description : String
    }


type Build
    = Empty
    | Started (List BuildInfo)


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
    Json.Decode.succeed
        (case builds of
            [] ->
                Empty

            items ->
                Started items
        )


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
                    if List.any (\info -> info.status == Failed) buildInfo then
                        UI.Color.error

                    else if List.all (\info -> info.status == Success) buildInfo then
                        UI.Color.green70

                    else
                        UI.Color.grey50
    in
    UI.el
        [ [ Element.Font.color color ] ]
        (Element.text buildString)


transverse : Build -> Status
transverse build =
    case build of
        Empty ->
            InProgress

        Started buildInfos ->
            if List.any (\info -> info.status == Failed) buildInfos then
                Failed

            else if List.all (\info -> info.status == Success) buildInfos then
                Success

            else
                InProgress


statusToString : Build -> String
statusToString build =
    case transverse build of
        InProgress ->
            "in progress"

        Success ->
            "success"

        Failed ->
            "failed"

        Stopped ->
            "stopped"


isFailed : Build -> Bool
isFailed build =
    case transverse build of
        Failed ->
            True

        _ ->
            False


isPass : Build -> Bool
isPass build =
    case build of
        Started info ->
            List.all (\i -> i.status == Success) info

        _ ->
            False


isNewFailed : ( Build, Build ) -> Bool
isNewFailed ( old, new ) =
    not (isFailed old) && isFailed new
