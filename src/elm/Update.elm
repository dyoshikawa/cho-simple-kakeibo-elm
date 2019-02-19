module Update exposing (Msg(..), update)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, map2)
import Json.Encode exposing (encode, int, object, string)
import Model exposing (SpendItem)
import Port



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoneInput value ->
            ( { model | spendInput = value }, Cmd.none )

        PutSpendItem price ->
            ( { model | spendBusy = True }
            , Http.request
                { method = "POST"
                , headers =
                    [ Http.header "Authorization" ("Bearer " ++ model.me.idToken) ]
                , url = "https://us-central1-cho-simple-kakeibo-develop.cloudfunctions.net/spendItems/"
                , body = Http.jsonBody (object [ ( "price", string price ) ])
                , expect = Http.expectString DonePutSpendItem
                , timeout = Nothing
                , tracker = Nothing
                }
            )

        DonePutSpendItem _ ->
            ( { model | spendBusy = False, spendInput = "" }, resetSpendInputValue () )

        CheckAuth ->
            ( model, auth () )

        Login ->
            ( { model | spendInput = "" }, login () )

        FetchedMe me ->
            let
                oldMe =
                    model.me

                newMe =
                    { oldMe | uid = me.uid, idToken = me.idToken }
            in
            ( { model | me = newMe, status = Loggedin }, fetchSpendItems me.uid )

        FetchSpendItems uid ->
            ( model, fetchSpendItems uid )

        FetchedSpendItems items ->
            ( { model | spendItems = items }, Cmd.none )

        DeleteSpendItem item ->
            ( { model
                | spendItems =
                    (\items ->
                        List.map
                            (\item2 ->
                                if item2.id == item.id then
                                    { item2 | busy = True }

                                else
                                    item2
                            )
                            items
                    )
                        model.spendItems
              }
            , Http.request
                { method = "DELETE"
                , headers =
                    [ Http.header "Authorization" ("Bearer " ++ model.me.idToken) ]
                , url = "https://us-central1-cho-simple-kakeibo-develop.cloudfunctions.net/spendItems/" ++ item.id
                , body = Http.emptyBody
                , expect = Http.expectString DeletedSpendItem
                , timeout = Nothing
                , tracker = Nothing
                }
            )

        DeletedSpendItem _ ->
            ( { model
                | spendItems =
                    (\items ->
                        List.map
                            (\item ->
                                if item.id == item.id then
                                    { item | busy = False }

                                else
                                    item
                            )
                            items
                    )
                        model.spendItems
              }
            , Cmd.none
            )
