module UI.Card exposing (..)

import Element exposing (..)
import Element.Background
import Element.Border
import UI
import UI.Color


box : List (Element.Attribute msg)
box =
    [ padding 16
    , spacing 16
    , width fill
    , Element.Border.rounded 12
    , Element.Background.color UI.Color.white
    ]


avatarSize : Int
avatarSize =
    40


avatar : List (Attribute msg)
avatar =
    UI.concat
        [ [ alignTop
          , padding 8
          ]
        , UI.circle 40
        ]


skeleton : Element msg
skeleton =
    let
        line =
            UI.el
                [ UI.skeleton
                , [ width fill
                  , height <| px 8
                  , Element.Border.rounded 4
                  ]
                ]
                none

        filler =
            UI.el [ [ width fill ] ] none
    in
    UI.row
        [ box, [ Element.spacing 16 ] ]
        [ UI.el [ UI.skeleton, UI.circle avatarSize ] none
        , UI.column [ [ spacing 8, width <| fillPortion 2 ] ]
            [ line
            , row
                [ width fill ]
                [ line, filler ]
            ]
        , filler
        ]
