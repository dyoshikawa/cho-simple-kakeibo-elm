module Subscription exposing (fetchedMe, fetchedSpendItems, subscriptions)

import Model exposing (Model, Msg(..))
import Port


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ fetchedMe FetchedMe, fetchedSpendItems FetchedSpendItems ]


port fetchedMe : (Me -> msg) -> Sub msg


port fetchedSpendItems : (List SpendItem -> msg) -> Sub msg
