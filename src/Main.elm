module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, button, div, h1, input, section, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)


main =
    Browser.sandbox { init = 0, update = update, view = view }


type Msg
    = Increment
    | Decrement


update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1


view model =
    div []
        [ section [ class "hero is-info" ]
            [ div [ class "hero-body" ]
                [ div [ class "container" ]
                    [ h1 [ class "title" ] [ text "超シンプル家計簿" ] ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input [ class "input", type_ "text" ] [] ]
                    , div [ class "control" ] [ button [ class "button is-info" ] [ text "登録" ] ]
                    ]
                ]
            ]
        ]
