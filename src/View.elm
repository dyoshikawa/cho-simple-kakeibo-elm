module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Model exposing (BudgetInput, Me, Model, Msg(..), PutSpendData, SpendItem, Status(..), Tab(..), init)
import Views.BudgetView exposing (budgetView)
import Views.Button exposing (loadingLoginButton, loginButton, logoutButton)
import Views.Hero exposing (hero)
import Views.SpendView exposing (spendView)


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
                spendView
                    { spendInput = model.spendInput
                    , spendItems = model.spendItems
                    , putSpendItem = PutSpendItem
                    , deleteSpendItem = DeleteSpendItem
                    , uid = model.me.uid
                    , doneInput = DoneInput
                    }

            else
                budgetView (BudgetInput "" False)
          )
            model.tab
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []
