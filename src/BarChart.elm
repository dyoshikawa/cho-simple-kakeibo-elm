module BarChart exposing (Data, view)

import Html exposing (..)
import Html.Events exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)


type alias Data =
    { budget : Int, spendSum : Int }


view : Data -> Html msg
view data =
    svg [ width "100%", height "100vh", viewBox "0 0 120 120", stroke "grey" ]
        [ rect [ x "20", y (String.fromInt ((\a -> 95 - a) data.budget)), width "30", height (String.fromInt data.budget), strokeWidth "0.2", stroke "grey", fill "grey" ] []
        , rect [ x "60", y (String.fromInt ((\a -> 95 - a) data.spendSum)), width "30", height (String.fromInt data.spendSum), strokeWidth "0.2", stroke "grey", fill "grey" ] []
        , line [ x1 "10", y1 "95", x2 "100", y2 "95", strokeWidth "0.2", stroke "grey" ] []
        , line [ x1 "10", y1 "10", x2 "10", y2 "95", strokeWidth "0.2", stroke "grey" ] []
        ]
