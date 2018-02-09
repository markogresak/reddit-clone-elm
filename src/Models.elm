module Models exposing (..)

import RemoteData exposing (WebData)
import Navigation exposing (Location)
import Date exposing (Date)


type alias Model =
    { route : Route
    , history : List Location
    , apiBase : String
    , now : Maybe Date
    , posts : WebData (List Post)
    }


initialModel : Route -> String -> Model
initialModel route apiBase =
    { route = route
    , history = []
    , apiBase = apiBase
    , now = Nothing
    , posts = RemoteData.Loading
    }


type alias PostId =
    Int


type alias UserId =
    Int


type alias User =
    { id : UserId
    , username : String
    }


type alias Post =
    { id : PostId
    , title : String
    , url : Maybe String
    , text : String
    , commentCount : Int
    , rating : Int
    , userRating : Int
    , submittedAt : Date
    , user : User
    }


type Route
    = PostsRoute
    | PostRoute PostId
    | NotFoundRoute
