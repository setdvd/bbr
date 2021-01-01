module Global exposing (..)

import Credentials exposing (Credentials)
import Settings exposing (Settings)


type alias Global =
    { settings : Settings
    , credentials : Credentials
    , version : String
    }
