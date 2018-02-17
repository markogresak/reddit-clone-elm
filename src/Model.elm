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
    , registerSuccess : Bool
    }


type alias RegisterModel =
    { username : String
    , password : String
    , passwordConfirm : String
    , errors : List String
    , apiBase : ApiBase
    , isLoading : Bool
    , passwordConfirmError : Bool
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
    , isConfirmMode : Bool
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
    , registerData : RegisterModel
    , newPostData : NewPostModel
    , userPage : WebData UserPage
    }


type alias UserId =
    Int


type alias User =
    { id : UserId
    , username : String
    }


type alias UserPage =
    { id : UserId
    , username : String
    , posts : List Post
    , comments : List Comment
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


type UserTabType
    = PostsTab
    | CommentsTab
    | UnknownTab


type RatingType
    = PostRating
    | CommentRating


type alias VoteId =
    Int


type Route
    = PostsRoute
    | PostRoute PostId
    | NewPostRoute String
    | UserRoute UserId String
    | LoginRoute
    | LogoutRoute
    | RegisterRoute
    | NotFoundRoute


type Msg
    = NavigateTo String
    | OnFetchPosts (WebData (List Post))
    | OnFetchCurrentPost (WebData Post)
    | OnFetchUserPage (WebData UserPage)
    | OnLocationChange Route
    | SetSession (Maybe Session)
    | SetCurrentTime (Maybe Date)
    | OnRate RatingType VoteId Bool Int
    | OnRateCompleted (Result Http.Error Rating)
    | OnLoginMsg LoginMsg
    | OnRegisterMsg RegisterMsg
    | OnNewPostMsg NewPostMsg
    | OnCommentFormMsg CommentId CommentFormMsg
    | OnConfirm Bool


type LoginMsg
    = OnLoginSubmit
    | OnUsernameChange String
    | OnPasswordChange String
    | OnRememberMeChange Bool
    | OnLoginCompleted (Result Http.Error Session)


type RegisterMsg
    = OnRegisterSubmit
    | OnRegisterUsernameChange String
    | OnRegisterPasswordChange String
    | OnRegisterPasswordConfirmChange String
    | OnRegisterCompleted (Result Http.Error ())


type NewPostMsg
    = OnNewPostSubmit
    | OnTitleChange String
    | OnUrlChange String
    | OnTextChange String
    | OnAddNewPostCompleted (Result Http.Error Post)


type CommentFormMsg
    = OnCommentChange String
    | OnReplyClick
    | OnReplyCancel
    | OnEditClick
    | OnCollapseClick
    | OnDeleteClick
    | OnDeleteConfirm Bool
    | CommentFormMsgNavigateTo String
    | CommentFormMsgOnRate RatingType VoteId Bool Int
    | OnCommentSubmit
    | OnCommentSubmitCompleted (Result Http.Error Comment)
    | OnCommentDeleteCompleted (Result Http.Error ())
