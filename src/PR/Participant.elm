module PR.Participant exposing (Participant, ParticipantRole, decode, viewApprovedStatus)

import Element exposing (Element)
import Element.Font
import Json.Decode
import Json.Decode.Pipeline exposing (required, requiredAt)
import UI.Color


type ParticipantRole
    = Reviewer
    | Other


type alias Participant =
    { id : String
    , approved : Bool
    , role : ParticipantRole
    }


decode : Json.Decode.Decoder Participant
decode =
    Json.Decode.succeed Participant
        |> requiredAt [ "user", "uuid" ] Json.Decode.string
        |> required "approved" Json.Decode.bool
        |> required "role" participantRoleDecoder


participantRoleDecoder : Json.Decode.Decoder ParticipantRole
participantRoleDecoder =
    let
        get id =
            case id of
                "REVIEWER" ->
                    Json.Decode.succeed Reviewer

                "participant" ->
                    Json.Decode.succeed Other

                _ ->
                    Json.Decode.fail ("unknown value for ParticipantRole: " ++ id)
    in
    Json.Decode.string |> Json.Decode.andThen get


viewApprovedStatus : List Participant -> Element msg
viewApprovedStatus participants =
    let
        approvedCount =
            participants
                |> List.filter .approved
                |> List.length

        color =
            if approvedCount > 0 then
                UI.Color.success

            else
                UI.Color.greyTone50
    in
    Element.el
        [ Element.Font.color color ]
        (Element.text <|
            case approvedCount of
                0 ->
                    "not approved yet"

                1 ->
                    "single approve"

                x ->
                    String.fromInt x ++ " approves"
        )
