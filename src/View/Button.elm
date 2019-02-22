module View.Button exposing (loadingLoginButton, loginButton, logoutButton)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


loadingLoginButton : Html msg
loadingLoginButton =
    button
        [ class "button is-info is-loading" ]
        [ text "Googleログイン" ]


loginButton : msg -> Html msg
loginButton login =
    button
        [ class "button is-info", onClick login ]
        [ text "Googleログイン" ]


logoutButton : Html msg
logoutButton =
    button
        [ class "button is-danger" ]
        [ text "ログアウト" ]
