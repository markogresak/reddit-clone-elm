module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { posts : WebData (List Post)
    , route : Route
    }


initialModel : Route -> Model
initialModel route =
    { posts = RemoteData.Loading
    , route = route
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
