module Models exposing (..)

import RemoteData exposing (WebData)
import Navigation exposing (Location)


type alias Model =
    { route : Route
    , history : List Location
    , apiBase : String
    , posts : WebData (List Post)
    }


initialModel : Route -> String -> Model
initialModel route apiBase =
    { route = route
    , history = []
    , apiBase = apiBase
    , posts = RemoteData.Loading
    }


type alias PostId =
    Int


type alias UserId =
    Int


type alias Post =
    { id : PostId
    , title : String
    }


type Route
    = PostsRoute
    | PostRoute PostId
    | NotFoundRoute
