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


type alias NewPostModel =
    { postType : PostType
    , title : String
    , url : Maybe String
    , text : Maybe String
    , errors : List String
    , apiBase : ApiBase
    , session : Maybe Session
    , isLoading : Bool
    }


type alias CommentFormModel =
    { commentText : String
    , showReplyForm : Bool
    , isEditMode : Bool
    , isCollapsed : Bool
    , errors : List String
    , isLoading : Bool
    , apiBase : ApiBase
    , session : Maybe Session
    , now : Maybe Date
    , comment : Comment
    }


type alias Model =
    { route : Route
    , apiBase : ApiBase
    , now : Maybe Date
    , posts : WebData (List Post)
    , currentPost : WebData Post
    , currentPostCommentModels : List CommentFormModel
    , sessionUser : Maybe Session
    , loginData : LoginModel
    , newPostData : NewPostModel
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


type alias Rating =
    { id : Int
    , rating : Int
    , userRating : Int
    , type_ : RatingType
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


type RatingType
    = PostRating
    | CommentRating


type alias VoteId =
    Int


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
    | OnRate RatingType VoteId Bool Int
    | OnRateCompleted (Result Http.Error Rating)
    | OnLoginMsg LoginMsg
    | OnNewPostMsg NewPostMsg
    | OnCommentFormMsg CommentId CommentFormMsg


type LoginMsg
    = OnLoginSubmit
    | OnUsernameChange String
    | OnPasswordChange String
    | OnRememberMeChange Bool
    | OnLoginCompleted (Result Http.Error Session)


type NewPostMsg
    = OnNewPostSubmit
    | OnTitleChange String
    | OnUrlChange String
    | OnTextChange String
    | OnAddNewPostCompleted (Result Http.Error Post)


type CommentFormMsg
    = OnCommentChange String
    | OnCommentSubmit
    | OnReplyClick
    | OnReplyCancel
    | OnEditClick
    | OnDeleteClick
    | OnCollapseClick
    | CommentFormMsgNavigateTo String
    | CommentFormMsgOnRate RatingType VoteId Bool Int
