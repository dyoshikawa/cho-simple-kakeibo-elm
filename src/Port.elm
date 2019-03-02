port module Port exposing
    ( auth
    , checkedAuth
    , deleteSpendItem
    , fetchSpendItems
    , fetchedMe
    , fetchedSpendItems
    , login
    , logout
    , putSpend
    , putSpendItem
    , resetSpendInputValue
    )


type alias PutSpendData =
    { uid : String, spend : String }


type alias Me =
    { uid : String, idToken : String }


type alias SpendItem =
    { id : String, price : Int, createdAt : String, busy : Bool }


port auth : () -> Cmd msg


port login : () -> Cmd msg


port putSpend : PutSpendData -> Cmd msg


port fetchSpendItems : String -> Cmd msg


port resetSpendInputValue : () -> Cmd msg


port logout : () -> Cmd msg


port fetchedMe : (Me -> msg) -> Sub msg


port checkedAuth : (() -> msg) -> Sub msg


port fetchedSpendItems : (List SpendItem -> msg) -> Sub msg


port putSpendItem : PutSpendData -> Cmd msg


port deleteSpendItem : String -> Cmd msg
