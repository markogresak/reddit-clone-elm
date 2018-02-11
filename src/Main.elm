module Main exposing (..)

import Html.Styled exposing (toUnstyled)
import Model exposing (..)
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
    in
        initLocationState location (initialModel currentRoute apiBase)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
