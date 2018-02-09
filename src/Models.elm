module Models exposing (..)

import Date exposing (Date)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type alias Model =
    { route : Route
    , history : List Location
    , apiBase : String
    , now : Maybe Date
    , posts : WebData (List Post)
    , currentPost : WebData Post
    , currentUser : User
    }


initialModel : Route -> String -> Model
initialModel route apiBase =
    { route = route
    , history = []
    , apiBase = apiBase
    , now = Nothing
    , posts = RemoteData.Loading
    , currentPost = RemoteData.Loading
    , currentUser = { id = 123, username = "kek" }
    }


type alias UserId =
    Int


type alias User =
    { id : UserId
    , username : String
    }


type alias PostId =
    Int


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
    , comments : List Comment
    }


type alias CommentId =
    Int


type alias Comment =
    { id : CommentId
    , text : String
    , submittedAt : Date
    , rating : Int
    , postId : PostId
    , parentCommentId : Maybe CommentId
    , userRating : Int
    , user : User
    }


type PostType
    = LinkPost
    | TextPost


type Route
    = PostsRoute
    | PostRoute PostId
    | NewPostRoute String
    | UserRoute UserId
    | LoginRoute
    | RegisterRoute
    | NotFoundRoute
