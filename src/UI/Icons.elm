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


fromPaths : List String -> Element.Color -> Element msg
fromPaths strings color =
    Element.html <|
        Svg.svg
            [ Svg.Attributes.viewBox "0 0 24 24"
            ]
            (List.map
                (\string ->
                    Svg.path
                        [ Svg.Attributes.d string
                        , Svg.Attributes.fill <| toCSSColor color
                        ]
                        []
                )
                strings
            )


fromPath : String -> Element.Color -> Element msg
fromPath string =
    fromPaths [ string ]


icon : Int -> Element msg -> Element msg
icon size =
    Element.el (UI.rect size)


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


blur : Element.Color -> Element msg
blur =
    fromPath "M6 13c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm0 4c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm0-8c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm-3 .5c-.28 0-.5.22-.5.5s.22.5.5.5.5-.22.5-.5-.22-.5-.5-.5zM6 5c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm15 5.5c.28 0 .5-.22.5-.5s-.22-.5-.5-.5-.5.22-.5.5.22.5.5.5zM14 7c.55 0 1-.45 1-1s-.45-1-1-1-1 .45-1 1 .45 1 1 1zm0-3.5c.28 0 .5-.22.5-.5s-.22-.5-.5-.5-.5.22-.5.5.22.5.5.5zm-11 10c-.28 0-.5.22-.5.5s.22.5.5.5.5-.22.5-.5-.22-.5-.5-.5zm7 7c-.28 0-.5.22-.5.5s.22.5.5.5.5-.22.5-.5-.22-.5-.5-.5zm0-17c.28 0 .5-.22.5-.5s-.22-.5-.5-.5-.5.22-.5.5.22.5.5.5zM10 7c.55 0 1-.45 1-1s-.45-1-1-1-1 .45-1 1 .45 1 1 1zm0 5.5c-.83 0-1.5.67-1.5 1.5s.67 1.5 1.5 1.5 1.5-.67 1.5-1.5-.67-1.5-1.5-1.5zm8 .5c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm0 4c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm0-8c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm0-4c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm3 8.5c-.28 0-.5.22-.5.5s.22.5.5.5.5-.22.5-.5-.22-.5-.5-.5zM14 17c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm0 3.5c-.28 0-.5.22-.5.5s.22.5.5.5.5-.22.5-.5-.22-.5-.5-.5zm-4-12c-.83 0-1.5.67-1.5 1.5s.67 1.5 1.5 1.5 1.5-.67 1.5-1.5-.67-1.5-1.5-1.5zm0 8.5c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1zm4-4.5c-.83 0-1.5.67-1.5 1.5s.67 1.5 1.5 1.5 1.5-.67 1.5-1.5-.67-1.5-1.5-1.5zm0-4c-.83 0-1.5.67-1.5 1.5s.67 1.5 1.5 1.5 1.5-.67 1.5-1.5-.67-1.5-1.5-1.5z"


clock : Element.Color -> Element msg
clock =
    fromPaths
        [ "M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8z"
        , "M12.5 7H11v6l5.25 3.15.75-1.23-4.5-2.67z"
        ]


done : Element.Color -> Element msg
done =
    fromPath "M9 16.2L4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2z"


report : Element.Color -> Element msg
report =
    fromPath "M15.73 3H8.27L3 8.27v7.46L8.27 21h7.46L21 15.73V8.27L15.73 3zM12 17.3c-.72 0-1.3-.58-1.3-1.3 0-.72.58-1.3 1.3-1.3.72 0 1.3.58 1.3 1.3 0 .72-.58 1.3-1.3 1.3zm1-4.3h-2V7h2v6z"
