module UI.Card exposing (..)

import Element exposing (..)
import Element.Background
import Element.Border
import UI
import UI.Color


box : List (List (Attribute msg)) -> List (Element msg) -> Element msg
box attr =
    row
        (List.concat
            [ [ padding 16
              , spacing 16
              , width fill
              , Element.Border.rounded 12
              , Element.Background.color UI.Color.white
              ]
            , List.concat attr
            ]
        )


avatarSize : Int
avatarSize =
    40


avatar : List (List (Attribute msg)) -> Element msg -> Element msg
avatar attrs =
    Element.el
        (List.concat
            [ [ alignTop
              , padding 8
              ]
            , UI.circle 40
            , List.concat attrs
            ]
        )


skeleton : Element msg
skeleton =
    let
        line =
            UI.skeleton [ [ width fill, height <| px 8, Element.Border.rounded 4 ] ]

        filler =
            el [ width fill ] none
    in
    box
        []
        [ UI.skeleton [ UI.circle avatarSize ]
        , column [ spacing 16, width <| fillPortion 2 ]
            [ line
            , row
                [ width fill ]
                [ line, filler ]
            ]
        , filler
        ]
