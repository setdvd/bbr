module UI exposing (..)

import Element exposing (..)
import Element.Background
import Element.Border
import Html.Attributes
import UI.Color
import UI.Font



-- TODO : Review interface for styling
--        consider exporting UI.el, column and other counterpart to Element but with api
--        List (List (Attribute msg)) -> Element msg
--        and for other "components" or styles just export List (Attribute msg)
--        then you can easy compose them or and inline one


type alias Attributes msg =
    List (List (Attribute msg))


concat : Attributes msg -> Attributes msg -> List (Attribute msg)
concat parent own =
    List.concat (own ++ parent)


circle : Int -> List (Element.Attribute msg)
circle size =
    [ Element.Border.rounded size
    , width <| px size
    , height <| px size
    ]


skeleton : Attributes msg -> Element msg
skeleton attrs =
    el
        (concat
            attrs
            [ [ Element.htmlAttribute <| Html.Attributes.class "skeleton"
              , Element.Background.color UI.Color.grey10
              ]
            ]
        )
        none


box : Attributes msg -> Element msg -> Element msg
box attr =
    el (List.concat attr)


container : Attributes msg -> Element msg -> Element msg
container attributes =
    box
        ([ [ width fill
           , Element.Border.rounded 12
           , Element.Background.color UI.Color.white
           ]
         ]
            ++ attributes
        )


fillWH : List (Attribute msg)
fillWH =
    [ width fill, height fill ]


rect : Int -> List (Attribute msg)
rect size =
    [ width <| px size, height <| px size ]


maybe : Maybe (Element msg) -> Element msg
maybe =
    Maybe.withDefault Element.none


fillMax : Int -> Element.Length
fillMax maxSize =
    Element.maximum maxSize Element.fill


center : List (Attribute msg)
center =
    [ centerX, centerY ]


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


tooltip : List (Attribute msg)
tooltip =
    [ Element.Background.color UI.Color.primaryBackground
    , Element.Border.rounded 12
    ]
        ++ UI.Font.caption
