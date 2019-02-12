module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, button, div, h1, h2, input, section, text)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onClick, onInput)


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Nested =
    { value : String }


type alias Model =
    { spendInput : String, nested : Nested }


init : Model
init =
    Nested ""
        |> Model ""



-- UPDATE


type Msg
    = DoneInput String
    | PutSpend String
    | GotNested String


update msg model =
    case msg of
        DoneInput value ->
            { model | spendInput = value }

        PutSpend value ->
            { model | spendInput = value }

        GotNested text ->
            let
                oldNested =
                    model.nested

                newNested =
                    { oldNested | value = text }
            in
            { model | nested = newNested }



-- VIEW


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
                [ h2
                    [ class "subtitle" ]
                    [ text "煩わしい入力項目のない超シンプルな家計簿です。" ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input [ class "input", type_ "number", placeholder "支出金額", onInput DoneInput ] [] ]
                    , div [ class "control" ] [ button [ class "button is-info", onClick (PutSpend model.spendInput) ] [ text "登録" ] ]
                    ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "card" ]
                    [ div [ class "card-content" ]
                        [ div [ class "content" ]
                            [ text "test" ]
                        ]
                    ]
                ]
            ]
        ]
