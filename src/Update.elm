module Update exposing (update)

import Http
import Json.Decode exposing (Decoder, field, map2)
import Json.Encode exposing (encode, int, object, string)
import Model exposing (..)
import Port exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DoneInput value ->
            ( { model | spendInput = value }, Cmd.none )

        PutSpendItem data ->
            ( model
            , putSpendItem data
            )

        DonePutSpendItem _ ->
            ( { model | spendBusy = False, spendInput = "" }, resetSpendInputValue () )

        Login ->
            ( { model | spendInput = "" }, login () )

        Logout ->
            ( { model | status = NotLoggedin }, logout () )

        CheckedAuth () ->
            ( { model | status = NotLoggedin }, Cmd.none )

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
            ( model
            , deleteSpendItem item.id
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

        ChangeTabSpend ->
            ( { model | tab = SpendTab }
            , Cmd.none
            )

        ChangeTabBudget ->
            ( { model | tab = BudgetTab }
            , Cmd.none
            )
