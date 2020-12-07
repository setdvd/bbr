module UI.Border exposing (..)

import Element
import Element.Border
import UI.Color


noShadow : Element.Decoration
noShadow =
    Element.Border.shadow
        { offset = ( 0, 0 )
        , size = 0
        , blur = 0
        , color = UI.Color.transparent
        }
