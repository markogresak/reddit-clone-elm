module Main exposing (..)

import Html.Styled exposing (toUnstyled)
import Navigation exposing (Location)
import Route
import Model exposing (..)
import Update exposing (update, initLocationState)
import View exposing (view)
import Json.Decode as Decode exposing (Value)
import RemoteData exposing (WebData)
import Util.AccessToken exposing (sessionUserDecoder)
import Util.Ports as Ports


decodeSession : Value -> Maybe Session
decodeSession json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString sessionUserDecoder >> Result.toMaybe)


init : Value -> Location -> ( Model, Cmd Msg )
init value location =
    let
        apiBase =
            if location.hostname == "localhost" then
                "http://localhost:4000/api"
            else
                "https://reddit-eu.herokuapp.com/api"

        currentRoute =
            Route.parseLocation location
    in
        initLocationState
            currentRoute
            { route = currentRoute
            , apiBase = apiBase
            , now = Nothing
            , posts = RemoteData.Loading
            , currentPost = RemoteData.Loading
            , sessionUser = (decodeSession value)
            }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Sub.map OnSessionChange sessionChange ]


sessionChange : Sub (Maybe Session)
sessionChange =
    Ports.onSessionChange (Decode.decodeValue sessionUserDecoder >> Result.toMaybe)


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.parseLocation >> OnLocationChange)
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
