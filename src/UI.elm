module UI exposing (..)

import Element exposing (..)


rect : Int -> List (Attribute msg)
rect size =
    [ width <| px size, height <| px size ]


maybe : Maybe (Element msg) -> Element msg
maybe =
    Maybe.withDefault Element.none


fillMax : Int -> Element.Length
fillMax maxSize =
    Element.maximum maxSize Element.fill


fixed : Element msg -> Element msg
fixed element =
    Element.html <|
        Element.layoutWith
            { options =
                [ Element.noStaticStyleSheet
                ]
            }
            [ inFront element ]
            none
