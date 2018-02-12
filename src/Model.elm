module Model exposing (..)

import Date exposing (Date)
import RemoteData exposing (WebData)
import Json.Decode as Decode exposing (Value)


type alias Model =
    { route : Route
    , apiBase : String
    , now : Maybe Date
    , posts : WebData (List Post)
    , currentPost : WebData Post
    , sessionUser : Maybe Session
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


type alias NewPost =
    { title : String
    , url : Maybe String
    , text : Maybe String
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


type alias Session =
    { id : Int
    , username : String
    , accessToken : String
    }


type PostType
    = LinkPost
    | TextPost
    | UnknownPost


type Route
    = PostsRoute
    | PostRoute PostId
    | NewPostRoute String
    | UserRoute UserId
    | LoginRoute
    | RegisterRoute
    | NotFoundRoute


type Msg
    = NavigateTo String
    | OnfetchPosts (WebData (List Post))
    | OnfetchCurrentPost (WebData Post)
    | OnLocationChange Route
    | OnSessionChange (Maybe Session)
      -- | OnPostSave (Result Http.Error Post)
    | SetCurrentTime (Maybe Date)
