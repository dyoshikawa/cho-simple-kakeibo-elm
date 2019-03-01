module Views.BudgetView exposing (budgetView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.BarChart exposing (Data, barChart)


type alias BudgetInput =
    { value : String, busy : Bool }


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
                , barChart (Data 1000 3)
                ]
            ]
        ]
