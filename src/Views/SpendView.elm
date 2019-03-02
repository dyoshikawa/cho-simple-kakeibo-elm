module Views.SpendView exposing (spendView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)


type alias SpendViewData msg =
    { uid : String
    , spendInput : String
    , spendItems : List SpendItem
    , putSpendItem : PutSpendData -> msg
    , deleteSpendItem : SpendItem -> msg
    , doneInput : String -> msg
    }


spendView : SpendViewData msg -> Html msg
spendView args =
    div []
        [ section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input
                            [ id "spendInput"
                            , class "input"
                            , type_ "number"
                            , placeholder "支出金額"
                            , value args.spendInput
                            , onInput args.doneInput
                            ]
                            []
                        ]
                    , div [ class "control" ]
                        [ button
                            [ class "button is-info"
                            , onClick (args.putSpendItem { uid = args.uid, spend = args.spendInput })
                            ]
                            [ text "登録" ]
                        ]
                    ]
                ]
            ]
        , section [ class "section" ]
            [ div [ class "container" ]
                (spendItemCards
                    args.spendItems
                    args.deleteSpendItem
                )
            ]
        ]


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
