module UI.Color exposing (..)

import Element exposing (rgb255)


primary : Element.Color
primary =
    Element.rgb255 6 102 235


primaryShadow : Element.Color
primaryShadow =
    Element.rgba255 6 103 235 0.45


transparent : Element.Color
transparent =
    Element.rgba255 0 0 0 0


white : Element.Color
white =
    Element.rgb255 255 255 255


black : Element.Color
black =
    Element.rgb255 21 23 26


grey5 : Element.Color
grey5 =
    Element.rgb255 237 238 240


grey10 : Element.Color
grey10 =
    Element.rgb255 232 235 239


grey50 : Element.Color
grey50 =
    Element.rgb255 139 149 158


success : Element.Color
success =
    Element.rgb255 9 190 103


green70 : Element.Color
green70 =
    rgb255 82 209 148


error : Element.Color
error =
    Element.rgb255 245 76 62


warning : Element.Color
warning =
    Element.rgb255 247 147 13
