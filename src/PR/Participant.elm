module PR.Participant exposing (..)


type ParticipantRole
    = Reviewer
    | Participant


type alias Participant =
    { approved : Bool
    , role : ParticipantRole
    }
