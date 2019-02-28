port module Main exposing
    ( Msg(..)
    , auth
    , fetchSpendItems
    , fetchedMe
    , fetchedSpendItems
    , login
    , logout
    , main
    , putSpend
    , resetSpendInputValue
    , update
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2)
import Json.Encode exposing (encode, int, object, string)
import View.BarChart exposing (Data, view)
import View.Button exposing (loadingLoginButton, loginButton, logoutButton)


main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }



-- MODEL


type Msg
    = DoneInput String
    | Login
    | Logout
    | FetchedMe Me
    | CheckedAuth ()
    | FetchSpendItems String
    | FetchedSpendItems (List SpendItem)
    | PutSpendItem String
    | DonePutSpendItem (Result Http.Error String)
    | DeleteSpendItem SpendItem
    | DeletedSpendItem (Result Http.Error String)
    | ChangeTabSpend
    | ChangeTabBudget


type Status
    = Loggedin
    | NotLoggedin
    | Loading


type alias PutSpendData =
    { uid : String, spend : String }


type alias SpendItem =
    { id : String, price : Int, createdAt : String, busy : Bool }


type alias BudgetInput =
    { value : String, busy : Bool }


type alias Me =
    { uid : String, idToken : String }


type Tab
    = SpendTab
    | BudgetTab


type alias Model =
    { spendInput : String
    , me : Me
    , status : Status
    , spendItems : List SpendItem
    , spendBusy : Bool
    , tab : Tab
    , budgetInput : BudgetInput
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" (Me "" "") Loading [] False SpendTab (BudgetInput "" False)
    , auth ()
    )



-- UPDATE


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

        Logout ->
            ( { model | status = NotLoggedin }, logout () )

        CheckedAuth () ->
            ( { model | status = NotLoggedin }, Cmd.none )

        FetchedMe me ->
            let
                oldMe =
                    model.me

                newMe =
                    { oldMe | uid = me.uid, idToken = me.idToken }
            in
            ( { model | me = newMe, status = Loggedin }, fetchSpendItems me.uid )

        FetchSpendItems uid ->
            ( model, fetchSpendItems uid )

        FetchedSpendItems items ->
            ( { model | spendItems = items }, Cmd.none )

        DeleteSpendItem item ->
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
                , expect = Http.expectString DeletedSpendItem
                , timeout = Nothing
                , tracker = Nothing
                }
            )

        DeletedSpendItem _ ->
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

        ChangeTabSpend ->
            ( { model | tab = SpendTab }
            , Cmd.none
            )

        ChangeTabBudget ->
            ( { model | tab = BudgetTab }
            , Cmd.none
            )



-- Port


port auth : () -> Cmd msg


port login : () -> Cmd msg


port putSpend : PutSpendData -> Cmd msg


port fetchSpendItems : String -> Cmd msg


port resetSpendInputValue : () -> Cmd msg


port logout : () -> Cmd msg



-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ fetchedMe FetchedMe, fetchedSpendItems FetchedSpendItems, checkedAuth CheckedAuth ]


port fetchedMe : (Me -> msg) -> Sub msg


port checkedAuth : (() -> msg) -> Sub msg


port fetchedSpendItems : (List SpendItem -> msg) -> Sub msg



-- VIEW


view : Model -> Html Msg
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
                , case model.status of
                    Loading ->
                        div
                            [ class "pageloader is-active is-info" ]
                            [ span [ class "title" ] [ text "Loading..." ] ]

                    Loggedin ->
                        logoutButton Logout

                    NotLoggedin ->
                        loginButton Login
                ]
            ]
        , div [ class "container" ]
            [ div [ class "tabs" ]
                [ ul []
                    [ li
                        [ class
                            ((\tab ->
                                if tab == SpendTab then
                                    "is-active"

                                else
                                    ""
                             )
                                model.tab
                            )
                        , onClick ChangeTabSpend
                        ]
                        [ a [] [ text "支出" ] ]
                    , li
                        [ class
                            ((\tab ->
                                if tab == BudgetTab then
                                    "is-active"

                                else
                                    ""
                             )
                                model.tab
                            )
                        , onClick ChangeTabBudget
                        ]
                        [ a
                            []
                            [ text "予算" ]
                        ]
                    ]
                ]
            ]
        , (\tab ->
            if tab == SpendTab then
                spendView model.spendInput model.spendBusy model.spendItems DoneInput PutSpendItem DeleteSpendItem

            else
                budgetView (BudgetInput "" False)
          )
            model.tab
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


spendView : String -> Bool -> List SpendItem -> (String -> msg) -> (String -> msg) -> (SpendItem -> msg) -> Html msg
spendView spendInput spendBusy spendItems doneInput putSpendItem deleteSpendItem =
    div []
        [ section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input [ id "spendInput", class "input", type_ "number", placeholder "支出金額", onInput doneInput ] [] ]
                    , div [ class "control" ]
                        [ button
                            [ class
                                ((\busy ->
                                    if busy == True then
                                        "button is-info is-loading"

                                    else
                                        "button is-info"
                                 )
                                    spendBusy
                                )
                            , onClick (putSpendItem spendInput)
                            ]
                            [ text "登録" ]
                        ]
                    ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                (spendItemCards
                    spendItems
                    deleteSpendItem
                )
            ]
        ]


budgetView : BudgetInput -> Html msg
budgetView budgetInput =
    div []
        [ section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input [ id "spendInput", class "input", type_ "number", placeholder "予算金額" ] [] ]
                    , div [ class "control" ]
                        [ button
                            [ class
                                ((\busy ->
                                    if busy == True then
                                        "button is-info is-loading"

                                    else
                                        "button is-info"
                                 )
                                    budgetInput.busy
                                )
                            ]
                            [ text "登録" ]
                        ]
                    ]
                , View.BarChart.view (View.BarChart.Data 1000 3)
                ]
            ]
        ]
