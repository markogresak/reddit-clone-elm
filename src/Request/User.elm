module Request.User exposing (login, loginErrorDecoder)

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Model exposing (..)
import Util.AccessToken exposing (loginRequestSessionDecoder)


login : String -> { r | username : String, password : String } -> Http.Request Session
login apiBase { username, password } =
    let
        body =
            Encode.object
                [ ( "username", Encode.string username )
                , ( "password", Encode.string password )
                ]
                |> Http.jsonBody
    in
        Decode.at [ "data" ] loginRequestSessionDecoder
            |> Http.post (loginUrl apiBase) body


loginErrorDecoder : String -> List String
loginErrorDecoder body =
    case Decode.decodeString (Decode.at [ "error", "message" ] Decode.string) body of
        Ok errorMessage ->
            [ errorMessage ]

        Err _ ->
            []


loginUrl : String -> String
loginUrl apiBase =
    apiBase ++ "/login"
