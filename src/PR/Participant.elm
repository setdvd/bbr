module PR.Participant exposing (..)

-- TODO implement approve status for participants
--      [] we should see the number of approve PR has
--      [] if PR has 1 approve and successfully build we should get notification
--      labels: Focus


type ParticipantRole
    = Reviewer
    | Participant


type alias Participant =
    { approved : Bool
    , role : ParticipantRole
    }
