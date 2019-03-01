module Views.Hero exposing (hero)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


hero : Html msg
hero =
    section [ class "hero is-info" ]
        [ div [ class "hero-body" ]
            [ div [ class "container" ]
                [ h1 [ class "title" ] [ text "超シンプル家計簿" ] ]
            ]
        ]
