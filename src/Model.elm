module Model exposing (BudgetViewData, Me, Model, Msg(..), PutSpendData, SpendItem, Status(..), Tab(..), init)

import Http
import Port exposing (auth, checkedAuth, fetchSpendItems, fetchedMe, fetchedSpendItems, login, logout, putSpend, resetSpendInputValue)


type Msg
    = DoneInput String
    | DoneBudgetInput String
    | Login
    | Logout
    | FetchedMe Me
    | CheckedAuth ()
    | FetchSpendItems String
    | FetchedSpendItems (List SpendItem)
    | PutSpendItem PutSpendData
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


type alias BudgetViewData msg =
    { budgetInput : String
    , doneBudgetInput : String -> msg
    }


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
    , budgetInput : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" (Me "" "") Loading [] False SpendTab ""
    , auth ()
    )
