module Msgs exposing (..)

import Http
import Models exposing (Post, PostId)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = OnfetchPosts (WebData (List Post))
    | OnLocationChange Location
    | OnPostSave (Result Http.Error Post)
