module UI exposing (..)

import Element exposing (Attribute, Element)
import Element.Background
import Element.Border
import Html.Attributes
import UI.Color


type alias Attributes msg =
    List (List (Attribute msg))



-- Base


class : String -> List (Element.Attribute msg)
class className =
    [ Element.htmlAttribute <| Html.Attributes.class className ]


text : String -> Element msg
text string =
    Element.text string


el : Attributes msg -> Element msg -> Element msg
el attributes =
    Element.el (List.concat attributes)


row : Attributes msg -> List (Element msg) -> Element msg
row attributes elements =
    Element.row (List.concat attributes) elements


wrappedRow : Attributes msg -> List (Element msg) -> Element msg
wrappedRow attributes elements =
    Element.wrappedRow (List.concat attributes) elements


column : Attributes msg -> List (Element msg) -> Element msg
column attributes elements =
    Element.column (List.concat attributes) elements


paragraph : Attributes msg -> List (Element msg) -> Element msg
paragraph attributes elements =
    Element.paragraph (List.concat attributes) elements


fixed : Element msg -> Element msg
fixed element =
    Element.html <|
        Element.layoutWith
            { options =
                [ Element.noStaticStyleSheet
                ]
            }
            [ Element.inFront element ]
            Element.none



-- Helpers


concat : Attributes msg -> List (Attribute msg)
concat attr =
    List.concat attr


maybe : Maybe (Element msg) -> Element msg
maybe =
    Maybe.withDefault Element.none



-- Classes


circle : Int -> List (Element.Attribute msg)
circle size =
    [ Element.Border.rounded size
    , Element.width <| Element.px size
    , Element.height <| Element.px size
    ]


skeleton : List (Attribute msg)
skeleton =
    [ Element.htmlAttribute <| Html.Attributes.class "skeleton"
    , Element.Background.color UI.Color.grey10
    ]


container : List (Attribute msg)
container =
    [ Element.width Element.fill
    , Element.Border.rounded 12
    , Element.Background.color UI.Color.white
    ]


fillWH : List (Attribute msg)
fillWH =
    [ Element.width Element.fill
    , Element.height Element.fill
    ]


fillMax : Int -> Element.Length
fillMax maxSize =
    Element.maximum maxSize Element.fill


rect : Int -> List (Attribute msg)
rect size =
    [ Element.width <| Element.px size
    , Element.height <| Element.px size
    ]


center : List (Attribute msg)
center =
    [ Element.centerX
    , Element.centerY
    ]


tooltip : List (Attribute msg)
tooltip =
    concat
        [ container
        , [ Element.padding 8
          , Element.Border.shadow
                { offset = ( 0, 5 )
                , size = 0
                , blur = 10
                , color = UI.Color.grey5
                }
          ]
        ]
