module UI.Font exposing (..)

import Element
import Element.Font exposing (..)
import Element.Region


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
    , Element.Region.heading 1
    ]
