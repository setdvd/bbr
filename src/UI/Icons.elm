module UI.Icons exposing (..)

import Element exposing (Element)
import Svg
import Svg.Attributes exposing (..)
import UI


toCSSColor : Element.Color -> String
toCSSColor color =
    let
        { red, green, blue, alpha } =
            Element.toRgb color

        ch =
            [ red, green, blue ]
                |> List.map (\channel -> String.fromFloat (255 * channel))
                |> List.intersperse ","
                |> List.foldr (++) ""
    in
    "rgba(" ++ ch ++ "," ++ String.fromFloat alpha ++ ")"


circularProgress : Element.Color -> Element msg
circularProgress color =
    Element.html <|
        Svg.svg
            [ Svg.Attributes.class "progress_icon"
            , Svg.Attributes.viewBox "0 0 50 50"
            ]
            [ Svg.circle
                [ Svg.Attributes.fill "transparent"
                , Svg.Attributes.stroke <| toCSSColor color
                , Svg.Attributes.strokeWidth "4"
                , Svg.Attributes.r "21"
                , Svg.Attributes.cx "25"
                , Svg.Attributes.cy "25"
                , Svg.Attributes.class "progress_circle"
                ]
                []
            ]


icon : Int -> Element msg -> Element msg
icon size =
    Element.el (UI.rect size)
