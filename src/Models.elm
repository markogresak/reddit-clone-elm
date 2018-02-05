module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { posts : WebData (List Post)
    , route : Route
    , apiBase : String
    }


initialModel : Route -> String -> Model
initialModel route apiBase =
    { posts = RemoteData.Loading
    , route = route
    , apiBase = apiBase
    }


type alias PostId =
    Int


type alias Post =
    { id : PostId
    , title : String
    }


type Route
    = PostsRoute
    | PostRoute PostId
    | NotFoundRoute
