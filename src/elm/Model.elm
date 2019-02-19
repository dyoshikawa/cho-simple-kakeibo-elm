module Model exposing (Me, Model, Nested, SpendItem, Status(..), init)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2)
import Json.Encode exposing (encode, int, object, string)



-- MODEL


type Msg
    = DoneInput String
    | CheckAuth
    | Login
    | FetchedMe Me
    | FetchSpendItems String
    | FetchedSpendItems (List SpendItem)
    | PutSpendItem String
    | DonePutSpendItem (Result Http.Error String)
    | DeleteSpendItem SpendItem
    | DeletedSpendItem (Result Http.Error String)


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
