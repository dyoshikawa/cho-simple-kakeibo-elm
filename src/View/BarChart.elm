module View.BarChart exposing (Data, view)

import Html exposing (..)
import Html.Events exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)


type alias Data =
    { budget : Int, spendSum : Int }


spendHeight : Float -> Float -> Float
spendHeight budget spend =
    spend
        / budget
        |> (*) 85.0


spendY : Float -> Float -> Float
spendY budget spend =
    spendHeight budget spend
        |> (\a -> 95.0 - a)


view : Data -> Html msg
view data =
    svg [ width "100%", height "100vh", viewBox "0 0 120 120", stroke "grey" ]
        [ rect
            [ x "20"
            , y "10"
            , width "30"
            , height "85"
            , strokeWidth "0.2"
            , stroke "grey"
            , fill "grey"
            ]
            []
        , rect
            [ x "60"
            , y (spendY (toFloat data.budget) (toFloat data.spendSum) |> String.fromFloat)
            , width "30"
            , height (spendHeight (toFloat data.budget) (toFloat data.spendSum) |> String.fromFloat)
            , strokeWidth "0.2"
            , stroke "grey"
            , fill "grey"
            ]
            []
        , line [ x1 "10", y1 "95", x2 "100", y2 "95", strokeWidth "0.2", stroke "grey" ] []
        , line [ x1 "10", y1 "10", x2 "10", y2 "95", strokeWidth "0.2", stroke "grey" ] []
        ]
