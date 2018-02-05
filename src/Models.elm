module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { posts : WebData (List Post)
    , route : Route
    , apiBase : String
    , locationPrefix : String
    }


initialModel : Route -> String -> String -> Model
initialModel route apiBase locationPrefix =
    { posts = RemoteData.Loading
    , route = route
    , apiBase = apiBase
    , locationPrefix = locationPrefix
    }


type alias PostId =
    Int


type alias Post =
    { id : PostId
    , title : String
    }


type Route
    = PostsRoute
    | PostRoute String
    | NotFoundRoute
