module Main exposing (..)

import Html.Styled exposing (toUnstyled)
import Models exposing (..)
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Route
import Update exposing (update, initLocationState)
import View exposing (view)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        apiBase =
            if location.hostname == "localhost" then
                "http://localhost:4000/api"
            else
                "https://reddit-eu.herokuapp.com/api"

        currentRoute =
            Route.parseLocation location

        model =
            initialModel currentRoute apiBase
    in
        initLocationState location model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Navigation.program Msgs.OnLocationChange
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
