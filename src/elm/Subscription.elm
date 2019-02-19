module Subscription exposing (fetchedMe, fetchedSpendItems, subscriptions)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2)
import Json.Encode exposing (encode, int, object, string)
import Model exposing (Model, Msg(..))
import Port


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ fetchedMe FetchedMe, fetchedSpendItems FetchedSpendItems ]


port fetchedMe : (Me -> msg) -> Sub msg


port fetchedSpendItems : (List SpendItem -> msg) -> Sub msg
