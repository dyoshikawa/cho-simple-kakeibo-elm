port module Main exposing (Msg(..), auth, jsGotItems, jsGotMe, login, main, putSpend, resetSpendInputValue, update)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2)
import Json.Encode exposing (encode, int, object, string)


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
    { id : String, price : Int, createdAt : String, busy : Bool }


type alias Me =
    { uid : String, idToken : String }


type alias Model =
    { spendInput : String, me : Me, status : Status, spendItems : List SpendItem, spendBusy : Bool }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" (Me "" "") Loggedin [] False, auth () )


port auth : () -> Cmd msg



-- UPDATE


type Msg
    = DoneInput String
    | Login
    | FetchedMe Me
    | FetchItems String
    | FetchedItems (List SpendItem)
    | PutSpendItem String
    | DonePutSpendItem (Result Http.Error String)
    | DeleteItem SpendItem
    | GotText (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoneInput value ->
            ( { model | spendInput = value }, Cmd.none )

        PutSpendItem price ->
            ( { model | spendBusy = True }
            , Http.request
                { method = "POST"
                , headers =
                    [ Http.header "Authorization" ("Bearer " ++ model.me.idToken) ]
                , url = "https://us-central1-cho-simple-kakeibo-develop.cloudfunctions.net/spendItems/"
                , body = Http.jsonBody (object [ ( "price", string price ) ])
                , expect = Http.expectString DonePutSpendItem
                , timeout = Nothing
                , tracker = Nothing
                }
            )

        DonePutSpendItem _ ->
            ( { model | spendBusy = False, spendInput = "" }, resetSpendInputValue () )

        Login ->
            ( { model | spendInput = "" }, login () )

        FetchedMe me ->
            let
                oldMe =
                    model.me

                newMe =
                    { oldMe | uid = me.uid, idToken = me.idToken }
            in
            ( { model | me = newMe, status = Loggedin }, fetchItems me.uid )

        FetchItems uid ->
            ( model, fetchItems uid )

        FetchedItems items ->
            ( { model | spendItems = items }, Cmd.none )

        DeleteItem item ->
            ( { model
                | spendItems =
                    (\items ->
                        List.map
                            (\item2 ->
                                if item2.id == item.id then
                                    { item2 | busy = True }

                                else
                                    item2
                            )
                            items
                    )
                        model.spendItems
              }
            , Http.request
                { method = "DELETE"
                , headers =
                    [ Http.header "Authorization" ("Bearer " ++ model.me.idToken) ]
                , url = "https://us-central1-cho-simple-kakeibo-develop.cloudfunctions.net/spendItems/" ++ item.id
                , body = Http.emptyBody
                , expect = Http.expectString GotText
                , timeout = Nothing
                , tracker = Nothing
                }
            )

        GotText text ->
            ( { model
                | spendItems =
                    (\items ->
                        List.map
                            (\item ->
                                if item.id == item.id then
                                    { item | busy = False }

                                else
                                    item
                            )
                            items
                    )
                        model.spendItems
              }
            , Cmd.none
            )



-- Cmd


port login : () -> Cmd msg


type alias PutSpendData =
    { uid : String, spend : String }


port putSpend : PutSpendData -> Cmd msg


port fetchItems : String -> Cmd msg


port resetSpendInputValue : () -> Cmd msg



-- Sub


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ jsGotMe FetchedMe, jsGotItems FetchedItems ]


port jsGotMe : (Me -> msg) -> Sub msg


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
                , button [ class "button is-info", onClick Login ] [ i [ class "fa-google fab" ] [], text "Googleログイン" ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input [ id "spendInput", class "input", type_ "number", placeholder "支出金額", onInput DoneInput ] [] ]
                    , div [ class "control" ]
                        [ button
                            [ class
                                ((\busy ->
                                    if busy == True then
                                        "button is-info is-loading"

                                    else
                                        "button is-info"
                                 )
                                    model.spendBusy
                                )
                            , onClick (PutSpendItem model.spendInput)
                            ]
                            [ text "登録" ]
                        ]
                    ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                (spendItemCards
                    model.spendItems
                    DeleteItem
                )
            ]
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


spendItemCards : List SpendItem -> (SpendItem -> msg) -> List (Html msg)
spendItemCards items msgDeletingItem =
    List.map
        (\item ->
            div
                [ class "card" ]
                [ div [ class "card-content" ]
                    [ div [ class "content" ]
                        [ div []
                            [ p [ class "title" ] [ text (String.fromInt item.price ++ "円") ]
                            , p [ class "subtitle" ] [ text item.createdAt ]
                            , button
                                [ class
                                    ((\busy ->
                                        if busy == True then
                                            "button is-danger is-loading"

                                        else
                                            "button is-danger"
                                     )
                                        item.busy
                                    )
                                , onClick (msgDeletingItem item)
                                ]
                                [ i [ class "material-icons" ] [ text "delete" ] ]
                            ]
                        ]
                    ]
                ]
        )
        items
