port module Main exposing (Msg(..), auth, jsGotItems, jsGotUid, login, main, putSpend, update)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }



-- MODEL


type alias Nested =
    { value : String }


type Status
    = Loggedin
    | NotLoggedin
    | Loading


type alias SpendItem =
    { id : String, price : Int, createdAt : String }


type alias Model =
    { spendInput : String, uid : String, status : Status, spendItems : List SpendItem }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "" Loggedin [], auth () )


port auth : () -> Cmd msg



-- UPDATE


type Msg
    = DoneInput String
    | ClickedPutSpend String
    | CompletedPutSpend ()
    | ClickedLogin
    | GotUid String
    | StartedFetchItems String
    | GotItems (List SpendItem)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoneInput value ->
            ( { model | spendInput = value }, Cmd.none )

        ClickedPutSpend value ->
            ( model, putSpend (PutSpendData model.uid model.spendInput) )

        CompletedPutSpend () ->
            ( { model | spendInput = "" }, Cmd.none )

        ClickedLogin ->
            ( { model | spendInput = "" }, login () )

        GotUid uid ->
            ( { model | uid = uid, status = Loggedin }, fetchItems uid )

        StartedFetchItems uid ->
            ( model, fetchItems uid )

        GotItems items ->
            ( { model | spendItems = items }, Cmd.none )



-- Cmd


port login : () -> Cmd msg


type alias PutSpendData =
    { uid : String, spend : String }


port putSpend : PutSpendData -> Cmd msg


port fetchItems : String -> Cmd msg



-- Sub


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ jsGotUid GotUid, jsCompletedPutSpend CompletedPutSpend, jsGotItems GotItems ]


port jsGotUid : (String -> msg) -> Sub msg


port jsCompletedFetchItems : (String -> msg) -> Sub msg


port jsCompletedPutSpend : (() -> msg) -> Sub msg


port jsGotItems : (List SpendItem -> msg) -> Sub msg



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
                , button [ class "button is-info", onClick ClickedLogin ] [ i [ class "fa-google fab" ] [], text "Googleログイン" ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input [ id "spendInput", class "input", type_ "number", placeholder "支出金額", onInput DoneInput ] [] ]
                    , div [ class "control" ] [ button [ class "button is-info", onClick (ClickedPutSpend model.spendInput) ] [ text "登録" ] ]
                    ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                (spendItemCards
                    model.spendItems
                )
            ]
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


spendItemCards : List SpendItem -> List (Html msg)
spendItemCards items =
    List.map
        (\item ->
            div [ class "card" ]
                [ div [ class "card-content" ]
                    [ div [ class "content" ]
                        [ div []
                            [ p [ class "title" ]
                                [ text (String.fromInt item.price ++ "円") ]
                            , button [ class "button is-danger" ] [ i [ class "material-icons" ] [ text "delete" ] ]
                            ]
                        ]
                    ]
                ]
        )
        items
