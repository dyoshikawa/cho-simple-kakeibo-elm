module Model exposing (Me, Model, Nested, SpendItem, Status(..), auth, init)

-- MODEL


type alias Nested =
    { value : String }


type Status
    = Loggedin
    | NotLoggedin
    | Loading


type alias SpendItem =
    { id : String, price : Int, createdAt : String, busy : Bool }


type alias PutSpendData =
    { uid : String, spend : String }


type alias Me =
    { uid : String, idToken : String }


type alias Model =
    { spendInput : String, me : Me, status : Status, spendItems : List SpendItem, spendBusy : Bool }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" (Me "" "") Loading [] False, auth () )


port auth : () -> Cmd msg
