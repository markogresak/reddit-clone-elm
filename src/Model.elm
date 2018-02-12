module Model exposing (..)

import Date exposing (Date)
import RemoteData exposing (WebData)
import Http


type alias ApiBase =
    String


type alias LoginModel =
    { username : String
    , password : String
    , rememberMe : Bool
    , errors : List String
    , apiBase : ApiBase
    , isLoading : Bool
    }


type alias Model =
    { route : Route
    , apiBase : ApiBase
    , now : Maybe Date
    , posts : WebData (List Post)
    , currentPost : WebData Post
    , sessionUser : Maybe Session
    , loginData : LoginModel
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
    , rememberMe : Bool
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
    | LogoutRoute
    | RegisterRoute
    | NotFoundRoute


type Msg
    = NavigateTo String
    | OnfetchPosts (WebData (List Post))
    | OnfetchCurrentPost (WebData Post)
    | OnLocationChange Route
    | SetSession (Maybe Session)
    | SetCurrentTime (Maybe Date)
    | OnLoginMsg LoginMsg


type LoginMsg
    = OnLoginSubmit
    | OnUsernameChange String
    | OnPasswordChange String
    | OnRememberMeChange Bool
    | OnLoginCompleted (Result Http.Error Session)
