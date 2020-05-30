port module Util.Ports exposing (confirm, onConfirm, onSessionChange, storeSession)

import Json.Encode exposing (Value)


port storeSession : Maybe String -> Cmd msg


port onSessionChange : (Value -> msg) -> Sub msg


port confirm : String -> Cmd msg


port onConfirm : (Value -> msg) -> Sub msg
