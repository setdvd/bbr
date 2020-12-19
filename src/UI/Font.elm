module UI.Font exposing (..)

import Element
import Element.Font exposing (..)
import UI.Color


w500 : Element.Attribute msg
w500 =
    medium


w600 : Element.Attribute msg
w600 =
    semiBold


h1 : List (Element.Attribute msg)
h1 =
    [ w600
    , size 34
    ]


h6HeadLine : List (Element.Attribute msg)
h6HeadLine =
    [ bold
    , italic
    , size 20
    ]


caption : List (Element.Attribute msg)
caption =
    [ size 12
    , color UI.Color.grey50
    ]
