module Main exposing
    ( main
    , update
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2)
import Json.Encode exposing (encode, int, object, string)
import Model exposing (BudgetInput, Me, Model, Msg(..), PutSpendData, SpendItem, Status(..), Tab(..), init)
import Port exposing (auth, checkedAuth, fetchSpendItems, fetchedMe, fetchedSpendItems, login, logout, putSpend, resetSpendInputValue)
import Subscription exposing (subscriptions)
import View.BudgetView exposing (budgetView)
import View.Button exposing (loadingLoginButton, loginButton, logoutButton)
import View.Hero exposing (hero)
import View.SpendView exposing (spendView)


main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }



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



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ hero
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
