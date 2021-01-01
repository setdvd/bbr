module UI.Input exposing (..)

import Element exposing (Attribute, Element)
import Element.Background
import Element.Border
import Element.Font
import Element.Input exposing (Placeholder)
import Html.Attributes
import UI exposing (Attributes)
import UI.Border
import UI.Color
import UI.Font
import UI.Icons


button :
    List (List (Element.Attribute msg))
    ->
        { label : String
        , onClick : Maybe msg
        , icon : Maybe (Element.Color -> Element msg)
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
            UI.el
                [ [ Element.Font.color UI.Color.white
                  , Element.centerX
                  , Element.centerY
                  , UI.Font.w500
                  , Element.onLeft (UI.el [ [ Element.moveLeft 8 ] ] labelIcon)
                  ]
                ]
                (UI.text label)
        , onPress = onClick
        }


iconButton : UI.Attributes msg -> { icon : Element msg, onClick : Maybe msg } -> Element msg
iconButton attributes { onClick, icon } =
    let
        style =
            [ Element.mouseDown
                [ Element.Background.color UI.Color.primaryBackgroundHover ]
            , Element.focused []
            ]

        s =
            24

        iconEl =
            UI.Icons.icon s icon
    in
    Element.Input.button
        (style ++ UI.circle s ++ List.concat attributes)
        { onPress = onClick, label = iconEl }


smallButton : UI.Attributes msg -> { label : Element msg, onClick : Maybe msg } -> Element msg
smallButton attributes { label, onClick } =
    Element.Input.button
        (UI.concat
            ([ UI.Font.caption
             , [ Element.Background.color UI.Color.primaryBackground
               , Element.Font.color UI.Color.primary
               , Element.paddingXY 12 10
               , Element.spacing 10
               , Element.Border.rounded 10
               , UI.Font.w500
               , Element.mouseOver [ Element.Background.color UI.Color.primaryBackgroundHover ]
               ]
             ]
                ++ attributes
            )
        )
        { onPress = onClick
        , label = label
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
    UI.column
        [ [ Element.width Element.fill
          , Element.spacing 8
          ]
        , UI.class "input fix-overflow"
        ]
        [ UI.column
            [ [ Element.width Element.fill
              , Element.spacing 8
              , Element.Border.rounded 8
              , Element.Background.color UI.Color.white
              , Element.paddingEach
                    { top = 12
                    , right = 16
                    , bottom = 0
                    , left = 16
                    }
              ]
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
                            Element.Input.placeholder
                                (UI.class "placeholder"
                                    ++ [ Element.transparent (not empty)
                                       ]
                                )
                                (UI.text placeholderText)
                        )
                        options.placeholder
                , label =
                    Element.Input.labelAbove
                        (UI.class "label"
                            ++ [ Element.Font.color UI.Color.grey50
                               , if not empty then
                                    labelScale

                                 else
                                    Element.Background.color UI.Color.white
                               ]
                        )
                        (Element.text options.label)
                }
            , underInputLine
            ]
        , errorBlock
        ]



-- Check box


checkBox : Attributes msg -> { onChange : Bool -> msg, checked : Bool, label : String } -> Element msg
checkBox attributes { onChange, checked, label } =
    Element.Input.checkbox
        (List.concat attributes)
        { onChange = onChange
        , icon =
            \isChecked ->
                let
                    icon =
                        if isChecked then
                            UI.Icons.checkboxChecked

                        else
                            UI.Icons.checkboxBlank
                in
                UI.Icons.icon 20 <| icon UI.Color.grey50
        , checked = checked
        , label = Element.Input.labelRight [ Element.Font.color UI.Color.grey50, Element.centerY ] (Element.text label)
        }



--- Helper


clearBox : List (Element.Attribute msg)
clearBox =
    [ Element.Border.width 0
    , Element.Background.color UI.Color.transparent
    , Element.focused []
    , Element.padding 0
    ]


error : String -> Element msg
error errorText =
    UI.paragraph
        [ [ Element.width Element.fill
          , Element.Font.color UI.Color.error
          , Element.paddingXY 16 0
          ]
        ]
        [ UI.text errorText ]


labelScale : Element.Attribute msg
labelScale =
    Element.htmlAttribute <| Html.Attributes.style "transform" "scale(0.75)"


underInputLine : Element msg
underInputLine =
    UI.el
        [ [ Element.width Element.fill
          , Element.height <| Element.px 2
          , Element.Background.color UI.Color.primary
          ]
        , UI.class "status-border"
        ]
        Element.none
