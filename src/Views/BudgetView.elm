module Views.BudgetView exposing (budgetView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (BudgetViewData)
import Views.BarChart exposing (Data, barChart)


budgetView : BudgetViewData msg -> Html msg
budgetView budgetViewData =
    div []
        [ section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input
                            [ class "input"
                            , type_ "number"
                            , placeholder "予算金額"
                            , value budgetViewData.budgetInput
                            , onInput budgetViewData.doneBudgetInput
                            ]
                            []
                        ]
                    , div [ class "control" ]
                        [ button
                            [ class "button is-info"
                            , onClick
                                (budgetViewData.updateUserBudget
                                    { uid = budgetViewData.uid, budget = budgetViewData.budgetInput }
                                )
                            ]
                            [ text "登録" ]
                        ]
                    ]
                , barChart (Data 1000 3)
                ]
            ]
        ]
