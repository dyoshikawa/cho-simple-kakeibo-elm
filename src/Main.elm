module Main exposing (main)

import Browser
import Model exposing (init)
import Subscription exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }
