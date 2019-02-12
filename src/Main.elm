port module Main exposing (Msg(..), hello, jsHello, login, main, store, update)

import Browser
import Html exposing (button, div, h1, h2, i, input, section, text)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onClick, onInput)


main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }



-- MODEL


type alias Nested =
    { value : String }


type alias Model =
    { spendInput : String, nested : Nested }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" (Nested ""), Cmd.none )



-- UPDATE


type Msg
    = DoneInput String
    | PutSpend String
    | GotNested String
    | PortTest String
    | ClickedLogin


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoneInput value ->
            ( { model | spendInput = value }, Cmd.none )

        PutSpend value ->
            ( { model | spendInput = value }, Cmd.none )

        GotNested text ->
            let
                oldNested =
                    model.nested

                newNested =
                    { oldNested | value = text }
            in
            ( { model | nested = newNested }, Cmd.none )

        PortTest text ->
            ( { model | spendInput = text }, store text )

        ClickedLogin ->
            ( { model | spendInput = "" }, login () )



-- Cmd


port hello : String -> Cmd msg


port store : String -> Cmd msg


port login : () -> Cmd msg



-- Sub


subscriptions : Model -> Sub Msg
subscriptions model =
    jsHello GotNested


port jsHello : (String -> msg) -> Sub msg



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
                , button [ class "button is-info", onClick ClickedLogin ] [ i [ class "fa-google fab" ] [], text "&nbsp", text "Googleログイン" ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input [ class "input", type_ "number", placeholder "支出金額", onInput DoneInput ] [] ]
                    , div [ class "control" ] [ button [ class "button is-info", onClick (PutSpend model.spendInput) ] [ text "登録" ] ]
                    ]
                , button [ onClick (PortTest "test") ] [ text "test" ]
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
