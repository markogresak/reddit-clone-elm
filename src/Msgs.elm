module Msgs exposing (..)

import Models exposing (Post, PostId)
import Navigation exposing (Location)
import RemoteData exposing (WebData)
import Date exposing (Date)


type Msg
    = NavigateTo String
    | OnfetchPosts (WebData (List Post))
    | OnfetchCurrentPost (WebData Post)
    | OnLocationChange Location
      -- | OnPostSave (Result Http.Error Post)
    | SetCurrentTime (Maybe Date)
