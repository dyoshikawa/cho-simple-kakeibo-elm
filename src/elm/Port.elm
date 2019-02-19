module Port exposing (PutSpendData, fetchSpendItems, login, putSpend, resetSpendInputValue)


port auth : () -> Cmd msg


port login : () -> Cmd msg


port putSpend : PutSpendData -> Cmd msg


port fetchSpendItems : String -> Cmd msg


port resetSpendInputValue : () -> Cmd msg
