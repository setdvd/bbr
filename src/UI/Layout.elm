module UI.Layout exposing (..)

import Element exposing (..)
import Element.Background
import Element.Region
import UI
import UI.Color
import UI.Font


page : List (List (Element.Attribute msg)) -> List (Element msg) -> Element msg
page attr =
    column
        (List.concat
            [ [ width (UI.fillMax 536)
              , spacing 16
              , Element.padding 16
              , centerX
              , height fill
              , Element.Background.color UI.Color.grey5
              ]
            , List.concat attr
            ]
        )


header : List (List (Element.Attribute msg)) -> String -> Element msg
header attr headerText =
    el
        (List.concat
            [ [ Element.Region.heading 1 ]
            , UI.Font.h6HeadLine
            , List.concat attr
            ]
        )
        (text headerText)


actions : List (List (Element.Attribute msg)) -> List (Element msg) -> Element msg
actions attrs elements =
    UI.fixed
        (row
            (List.concat
                [ [ Element.alignBottom
                  , width <| UI.fillMax (343 + 24 * 2)
                  , padding 24
                  , centerX
                  ]
                , List.concat attrs
                ]
            )
            elements
        )
