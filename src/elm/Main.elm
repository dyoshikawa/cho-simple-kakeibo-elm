module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2)
import Json.Encode exposing (encode, int, object, string)
import Model
import Subscription
import Update
import View exposing (view)


main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }
