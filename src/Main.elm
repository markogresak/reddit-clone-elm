module Main exposing (..)

import Commands exposing (fetchPosts)
import Models exposing (Model, initialModel)
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Routing
import Update exposing (update)
import View exposing (view)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        isLocalhost =
            location.hostname == "localhost"

        apiBase =
            if isLocalhost then
                "http://localhost:4000/api"
            else
                "https://reddit-eu.herokuapp.com/api"

        locationPrefix =
            if isLocalhost then
                ""
            else
                "reddit-clone-elm/"

        currentRoute =
            Routing.parseLocation locationPrefix location
    in
        ( initialModel currentRoute apiBase locationPrefix, fetchPosts apiBase )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Never Model Msg
main =
    Navigation.program Msgs.OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
