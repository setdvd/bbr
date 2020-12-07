module UI.Input exposing (..)

import Element exposing (..)
import Element.Background
import Element.Border
import Element.Font
import Element.Input exposing (Placeholder)
import Html.Attributes
import UI
import UI.Border
import UI.Color
import UI.Font
import UI.Icons


button :
    List (List (Element.Attribute msg))
    ->
        { label : String
        , onClick : Maybe msg
        , icon : Maybe (Color -> Element msg)
        }
    -> Element msg
button attr { label, onClick, icon } =
    let
        labelIcon =
            icon
                |> Maybe.map (\iconEl -> iconEl UI.Color.white)
                |> Maybe.map (UI.Icons.icon 16)
                |> UI.maybe
    in
    Element.Input.button
        (List.concat
            [ [ Element.Background.color UI.Color.primary
              , Element.width Element.fill
              , Element.padding 16
              , Element.Border.rounded 16
              , Element.mouseDown [ UI.Border.noShadow ]
              , Element.focused []
              , Element.mouseOver
                    [ Element.Border.shadow
                        { offset = ( 0, 5 )
                        , size = 0
                        , blur = 10
                        , color = UI.Color.primaryShadow
                        }
                    ]
              , Element.Border.shadow
                    { offset = ( 0, 3 )
                    , size = 0
                    , blur = 8
                    , color = UI.Color.primaryShadow
                    }
              ]
            , List.concat attr
            ]
        )
        { label =
            Element.el
                [ Element.Font.color UI.Color.white
                , Element.centerX
                , Element.centerY
                , UI.Font.w500
                , onLeft (Element.el [ Element.moveLeft 8 ] labelIcon)
                ]
                (Element.text label)
        , onPress = onClick
        }


text :
    List (List (Element.Attribute msg))
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe String
        , label : String
        , error : Maybe String
        }
    -> Element msg
text attrs options =
    let
        empty =
            String.length options.text == 0

        errorBlock =
            options.error
                |> Maybe.map error
                |> UI.maybe
    in
    column
        [ class "input fix-overflow"
        , width fill
        , spacing 8
        ]
        [ column
            [ width fill
            , spacing 8
            , Element.Border.rounded 8
            , Element.Background.color UI.Color.white
            , Element.paddingEach
                { top = 12
                , right = 16
                , bottom = 0
                , left = 16
                }
            ]
            [ Element.Input.text
                (List.concat
                    [ clearBox
                    , List.concat attrs
                    ]
                )
                { onChange = options.onChange
                , text = options.text
                , placeholder =
                    Maybe.map
                        (\placeholderText ->
                            Element.Input.placeholder [ class "placeholder", transparent (not empty) ] (Element.text placeholderText)
                        )
                        options.placeholder
                , label =
                    Element.Input.labelAbove
                        [ class "label"
                        , Element.Font.color UI.Color.greyTone50
                        , if not empty then
                            labelScale

                          else
                            Element.Background.color UI.Color.white
                        ]
                        (Element.text options.label)
                }
            , underInputLine
            ]
        , errorBlock
        ]



--- Helper


clearBox : List (Element.Attribute msg)
clearBox =
    [ Element.Border.width 0
    , Element.Background.color UI.Color.transparent
    , focused []
    , Element.padding 0
    ]


error : String -> Element msg
error errorText =
    paragraph [ width fill, Element.Font.color UI.Color.error, paddingXY 16 0 ] [ Element.text errorText ]


class : String -> Element.Attribute msg
class className =
    Element.htmlAttribute <| Html.Attributes.class className


labelScale : Element.Attribute msg
labelScale =
    Element.htmlAttribute <| Html.Attributes.style "transform" "scale(0.75)"


underInputLine : Element msg
underInputLine =
    el
        [ width fill
        , height <| px 2
        , Element.Background.color UI.Color.primary
        , class "status-border"
        ]
        none
