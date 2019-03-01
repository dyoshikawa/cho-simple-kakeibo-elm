module Main exposing (main)

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
import Update exposing (update)
import View.BudgetView exposing (budgetView)
import View.Button exposing (loadingLoginButton, loginButton, logoutButton)
import View.Hero exposing (hero)
import View.SpendView exposing (spendView)


main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }



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
