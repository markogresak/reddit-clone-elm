module Util.AccessToken exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, requiredAt, hardcoded)
import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Encode as Encode
import Model exposing (..)


localSessionDecoder : Decode.Decoder Session
localSessionDecoder =
    decode Session
        |> required "userId" Decode.int
        |> required "username" Decode.string
        |> required "accessToken" Decode.string
        |> required "rememberMe" Decode.bool


loginRequestSessionDecoder : Decode.Decoder Session
loginRequestSessionDecoder =
    decode Session
        |> requiredAt [ "user", "id" ] Decode.int
        |> requiredAt [ "user", "username" ] Decode.string
        |> required "jwt" Decode.string
        |> hardcoded False


withAccessToken : Maybe Session -> RequestBuilder a -> RequestBuilder a
withAccessToken maybeSession builder =
    case maybeSession of
        Just { accessToken } ->
            builder
                |> withHeader "Authorization" ("Bearer " ++ accessToken)

        Nothing ->
            builder


encode : Maybe Session -> Maybe String
encode maybeSession =
    case maybeSession of
        Just session ->
            Encode.object
                [ ( "userId", Encode.int session.id )
                , ( "username", Encode.string session.username )
                , ( "accessToken", Encode.string session.accessToken )
                , ( "rememberMe", Encode.bool session.rememberMe )
                ]
                |> Encode.encode 0
                |> Just

        Nothing ->
            Nothing
