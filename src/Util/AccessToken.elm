module Util.AccessToken exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import HttpBuilder exposing (RequestBuilder, withHeader)
import Model exposing (Session)


sessionUserDecoder : Decode.Decoder Session
sessionUserDecoder =
    decode Session
        |> required "userId" Decode.int
        |> required "username" Decode.string
        |> required "accessToken" Decode.string


withAccessToken : Maybe Session -> RequestBuilder a -> RequestBuilder a
withAccessToken maybeToken builder =
    case maybeToken of
        Just { accessToken } ->
            builder
                |> withHeader "Authorization" ("Bearer " ++ accessToken)

        Nothing ->
            builder
