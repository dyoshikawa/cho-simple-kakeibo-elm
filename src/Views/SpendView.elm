module Views.SpendView exposing (spendView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias SpendItem =
    { id : String, price : Int, createdAt : String, busy : Bool }


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
