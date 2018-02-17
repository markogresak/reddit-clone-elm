module Request.User exposing (login, loginErrorDecoder, get, register, registerErrorsDecoder)

import Http
import RemoteData
import HttpBuilder
import Json.Decode as Decode
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (decode, optional, required)
import Model exposing (..)
import Util.AccessToken exposing (withAccessToken, loginRequestSessionDecoder)
import Request.Post exposing (postDecoder, commentDecoder)


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


register : String -> { r | username : String, password : String } -> Http.Request ()
register apiBase { username, password } =
    let
        user =
            Encode.object
                [ ( "username", Encode.string username )
                , ( "password", Encode.string password )
                ]

        body =
            Encode.object [ ( "user", user ) ]
                |> Http.jsonBody
    in
        HttpBuilder.post (usersUrl apiBase)
            |> HttpBuilder.withBody body
            |> HttpBuilder.toRequest


get : String -> Maybe Session -> UserId -> Cmd Msg
get apiBase session userId =
    HttpBuilder.get (usersUrl apiBase ++ "/" ++ toString userId)
        |> withAccessToken session
        |> HttpBuilder.withExpect (Http.expectJson (Decode.at [ "data" ] userPageDecoder))
        |> HttpBuilder.toRequest
        |> RemoteData.sendRequest
        |> Cmd.map OnFetchUserPage


userPageDecoder : Decode.Decoder UserPage
userPageDecoder =
    decode UserPage
        |> required "id" Decode.int
        |> required "username" Decode.string
        |> optional "posts" (Decode.list postDecoder) []
        |> optional "comments" (Decode.list commentDecoder) []


registerErrorsDecoder : String -> List String
registerErrorsDecoder body =
    let
        decodeErrorList atPath =
            case Decode.decodeString (Decode.at atPath (Decode.list Decode.string)) body of
                Ok errorMessages ->
                    errorMessages

                Err _ ->
                    []
    in
        List.concat (List.map (\key -> List.map (\s -> key ++ " " ++ s) (decodeErrorList [ "errors", key ])) [ "username", "password" ])


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


usersUrl : String -> String
usersUrl apiBase =
    apiBase ++ "/users"
