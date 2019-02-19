port module Port exposing (auth, fetchSpendItems, login, putSpend, resetSpendInputValue)

import Model exposing (PutSpendData)


port auth : () -> Cmd msg


port login : () -> Cmd msg


port putSpend : PutSpendData -> Cmd msg


port fetchSpendItems : String -> Cmd msg


port resetSpendInputValue : () -> Cmd msg
