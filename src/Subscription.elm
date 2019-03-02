module Subscription exposing (subscriptions)

import Model exposing (Model, Msg(..))
import Port exposing (auth, checkedAuth, fetchSpendItems, fetchedMe, fetchedSpendItems, login, logout, putSpend, resetSpendInputValue)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ fetchedMe FetchedMe, fetchedSpendItems FetchedSpendItems, checkedAuth CheckedAuth ]
