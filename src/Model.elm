module Model exposing (BudgetInput, Me, Model, Msg(..), PutSpendData, SpendItem, Status(..), Tab(..), init)

import Http
import Port exposing (auth, checkedAuth, fetchSpendItems, fetchedMe, fetchedSpendItems, login, logout, putSpend, resetSpendInputValue)


type Msg
    = DoneInput String
    | Login
    | Logout
    | FetchedMe Me
    | CheckedAuth ()
    | FetchSpendItems String
    | FetchedSpendItems (List SpendItem)
    | PutSpendItem String
    | DonePutSpendItem (Result Http.Error String)
    | DeleteSpendItem SpendItem
    | DeletedSpendItem (Result Http.Error String)
    | ChangeTabSpend
    | ChangeTabBudget


type Status
    = Loggedin
    | NotLoggedin
    | Loading


type alias PutSpendData =
    { uid : String, spend : String }


type alias SpendItem =
    { id : String, price : Int, createdAt : String, busy : Bool }


type alias BudgetInput =
    { value : String, busy : Bool }


type alias Me =
    { uid : String, idToken : String }


type Tab
    = SpendTab
    | BudgetTab


type alias Model =
    { spendInput : String
    , me : Me
    , status : Status
    , spendItems : List SpendItem
    , spendBusy : Bool
    , tab : Tab
    , budgetInput : BudgetInput
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" (Me "" "") Loading [] False SpendTab (BudgetInput "" False)
    , auth ()
    )
