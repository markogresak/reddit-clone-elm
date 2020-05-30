module Main exposing (..)

import Css exposing (color, fontFamily, none, sansSerif, textDecoration, underline)
import Css.Foreign exposing (global, selector, typeSelector)
import Html.Styled exposing (..)
import Http
import Json.Decode as Decode exposing (Value)
import List.Extra
import Model exposing (..)
import Page.Login as Login
import Page.NewPost as NewPost
import Page.NotFound as NotFound
import Page.Posts as Posts
import Page.Register as Register
import Page.User as User
import RemoteData exposing (WebData)
import Request.Post as Post
import Request.User
import Route
import StyleVariables exposing (..)
import Task
import Util.AccessToken exposing (localSessionDecoder)
import Util.Ports as Ports
import Views.CommentItem as CommentItem
import Views.Menu as Menu


decodeSession : Value -> Maybe Session
decodeSession json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString localSessionDecoder >> Result.toMaybe)


-- init : Value -> Url.Url -> ( Model, Cmd Msg )
-- init value location =

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let

        apiBase =
            if location.hostname == "localhost" then
                "http://localhost:4000/api"

            else
                "https://reddit-eu.herokuapp.com/api"

        currentRoute =
            Route.parseLocation location

        sessionUser =
            decodeSession value

        newPostType =
            case currentRoute of
                NewPostRoute postTypeString ->
                    Route.stringToPostType postTypeString

                _ ->
                    UnknownPost
    in
    initLocationState
        currentRoute
        { key = key,
            route = currentRoute
        , apiBase = apiBase
        , now = Nothing
        , posts = RemoteData.Loading
        , currentPost = RemoteData.Loading
        , currentPostCommentModels = []
        , sessionUser = sessionUser
        , loginData = Login.initialModel apiBase
        , registerData = Register.initialModel apiBase
        , newPostData = NewPost.initialModel apiBase sessionUser newPostType
        , userPage = RemoteData.Loading
        }


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform (Just >> SetCurrentTime) Date.now


initLocationState : Route -> Model -> ( Model, Cmd Msg )
initLocationState route model =
    let
        ( nextModel, cmd ) =
            case route of
                PostsRoute ->
                    ( model, Post.list model.apiBase model.sessionUser )

                PostRoute postId ->
                    ( model, Post.get model.apiBase model.sessionUser postId )

                NewPostRoute postTypeString ->
                    let
                        postType =
                            Route.stringToPostType postTypeString
                    in
                    case postType of
                        UnknownPost ->
                            ( model, Route.modifyUrl model.key NotFoundRoute )

                        _ ->
                            let
                                initialNewPostData =
                                    NewPost.initialModel model.apiBase model.sessionUser postType
                            in
                            ( { model | newPostData = initialNewPostData }, Cmd.none )

                UserRoute userId tabType ->
                    let
                        requestCmd =
                            Request.User.get model.apiBase model.sessionUser userId

                        cmd =
                            case model.userPage of
                                RemoteData.Success userPage ->
                                    if userPage.id == userId then
                                        Cmd.none

                                    else
                                        requestCmd

                                _ ->
                                    requestCmd
                    in
                    ( model, cmd )

                LoginRoute ->
                    case model.sessionUser of
                        Just sessionUser ->
                            ( model, Route.modifyUrl model.key PostsRoute )

                        Nothing ->
                            ( model, Cmd.none )

                LogoutRoute ->
                    ( { model | sessionUser = Nothing }
                    , Cmd.batch [ Ports.storeSession Nothing, Route.modifyUrl PostsRoute ]
                    )

                RegisterRoute ->
                    ( model, Cmd.none )

                NotFoundRoute ->
                    ( model, Cmd.none )
    in
    ( nextModel, Cmd.batch [ cmd, getCurrentDate ] )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLinkClick urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        OnLocationChange route ->
            let
                updatedModel =
                    { model | route = route }

                loginData =
                    model.loginData

                newModel =
                    case route of
                        LoginRoute ->
                            updatedModel

                        _ ->
                            -- Reset registerSuccess state
                            { updatedModel | loginData = { loginData | registerSuccess = False } }
            in
            initLocationState route newModel

        NavigateTo route ->
            ( model, Navigation.newUrl route )

        OnFetchPosts response ->
            ( { model | posts = response }, getCurrentDate )

        SetCurrentTime date ->
            ( { model | now = date }, Cmd.none )

        OnFetchCurrentPost response ->
            case response of
                RemoteData.Success currentPost ->
                    let
                        newComment =
                            case model.sessionUser of
                                Just s ->
                                    [ Comment -1 "" (Date.fromTime 0) 0 currentPost.id Nothing 0 (User s.id s.username) ]

                                Nothing ->
                                    []
                    in
                    ( { model
                        | currentPost = response
                        , currentPostCommentModels = List.map (CommentItem.initialModel model) (newComment ++ currentPost.comments)
                      }
                    , getCurrentDate
                    )

                _ ->
                    ( { model | currentPost = response }, Cmd.none )

        SetSession sessionUser ->
            let
                cmd =
                    if model.sessionUser /= Nothing && sessionUser == Nothing then
                        Route.modifyUrl model.key PostsRoute

                    else
                        Cmd.none
            in
            ( { model | sessionUser = sessionUser }, cmd )

        OnLoginMsg subMsg ->
            let
                ( ( loginModel, cmd ), msgFromPage ) =
                    Login.update subMsg model.loginData

                newModel =
                    case msgFromPage of
                        Login.NoOp ->
                            model

                        Login.SetSession sessionUser ->
                            { model | sessionUser = Just sessionUser }
            in
            ( { newModel | loginData = loginModel }, Cmd.map OnLoginMsg cmd )

        Model.OnRegisterMsg subMsg ->
            let
                ( ( registerModel, cmd ), msgFromPage ) =
                    Register.update subMsg model.registerData

                newModel =
                    { model | registerData = registerModel }

                loginData =
                    model.loginData
            in
            case msgFromPage of
                Register.OnRegisterSuccess ->
                    update (NavigateTo (Route.routeToString LoginRoute)) { newModel | loginData = { loginData | registerSuccess = True } }

                _ ->
                    ( newModel, Cmd.map OnRegisterMsg cmd )

        OnNewPostMsg subMsg ->
            let
                ( ( newPostModel, cmd ), msgFromPage ) =
                    NewPost.update subMsg model.newPostData
            in
            ( { model | newPostData = newPostModel }, Cmd.map OnNewPostMsg cmd )

        OnCommentFormMsg id subMsg ->
            case List.Extra.find (\m -> m.comment.id == id) model.currentPostCommentModels of
                Just commentFormModel ->
                    let
                        ( ( newCommentFormModel, cmd ), msgFromPage ) =
                            CommentItem.update subMsg commentFormModel

                        updatedModel =
                            { model
                                | currentPostCommentModels =
                                    List.map
                                        (\m ->
                                            if m.comment.id == id then
                                                newCommentFormModel

                                            else
                                                m
                                        )
                                        model.currentPostCommentModels
                            }

                        newModel =
                            case msgFromPage of
                                CommentItem.OnAddNewComment newComment ->
                                    { updatedModel
                                        | currentPostCommentModels = [ CommentItem.initialModel updatedModel newComment ] ++ updatedModel.currentPostCommentModels
                                    }

                                CommentItem.OnEditComment updatedComment ->
                                    { updatedModel
                                        | currentPostCommentModels =
                                            List.map
                                                (\m ->
                                                    if m.comment.id == updatedComment.id then
                                                        CommentItem.initialModel updatedModel updatedComment

                                                    else
                                                        m
                                                )
                                                updatedModel.currentPostCommentModels
                                    }

                                CommentItem.OnDeleteComment id ->
                                    { updatedModel
                                        | currentPostCommentModels = List.filter (\m -> m.comment.id /= id) updatedModel.currentPostCommentModels
                                    }

                                _ ->
                                    updatedModel
                    in
                    case msgFromPage of
                        CommentItem.CommentFormNavigateTo route ->
                            update (NavigateTo route) newModel

                        CommentItem.CommentFormOnRate ratingType id isDownButton userRating ->
                            update (OnRate ratingType id isDownButton userRating) newModel

                        _ ->
                            ( newModel, Cmd.map (OnCommentFormMsg id) cmd )

                Nothing ->
                    ( model, Cmd.map (OnCommentFormMsg id) Cmd.none )

        OnConfirm result ->
            case List.Extra.find .isConfirmMode model.currentPostCommentModels of
                Just m ->
                    update (OnCommentFormMsg m.comment.id (OnDeleteConfirm result)) model

                Nothing ->
                    ( model, Cmd.none )

        OnRate ratingType id isDownButton userRating ->
            let
                rating =
                    if isDownButton && userRating /= -1 then
                        -1

                    else if not isDownButton && userRating /= 1 then
                        1

                    else
                        0
            in
            case rating of
                0 ->
                    ( model, Cmd.none )

                _ ->
                    ( model, Http.send OnRateCompleted (Post.rate model.apiBase model.sessionUser id rating ratingType) )

        OnRateCompleted (Ok rating) ->
            let
                nextModel =
                    case rating.type_ of
                        PostRating ->
                            { model
                                | posts =
                                    model.posts
                                        |> RemoteData.withDefault []
                                        |> List.map (Post.updatePostRating rating)
                                        |> RemoteData.succeed
                                , currentPost =
                                    case model.currentPost of
                                        RemoteData.Success post ->
                                            RemoteData.succeed (Post.updatePostRating rating post)

                                        _ ->
                                            model.currentPost
                            }

                        CommentRating ->
                            { model
                                | currentPostCommentModels = List.map (\m -> { m | comment = Post.updateCommentRating rating m.comment }) model.currentPostCommentModels
                            }
            in
            ( nextModel, Cmd.none )

        OnRateCompleted (Err _) ->
            ( model, Cmd.none )

        Model.OnFetchUserPage userPage ->
            ( { model | userPage = userPage }, getCurrentDate )


view : Model -> Html Msg
view model =
    div
        []
        [ global
            [ Css.Foreign.body
                [ fontFamily sansSerif
                , color defaultTextColor
                ]
            , typeSelector "a"
                [ textDecoration none
                , color linkColor
                ]
            , selector "a:not(.title):hover"
                [ textDecoration underline
                ]
            ]
        , Menu.view model
        , page model
        ]


page : Model -> Html Msg
page model =
    case model.route of
        PostsRoute ->
            Posts.listView model model.posts

        PostRoute id ->
            Posts.itemView model model.currentPost

        NewPostRoute postTypeString ->
            let
                postType =
                    Route.stringToPostType postTypeString
            in
            case postType of
                UnknownPost ->
                    NotFound.view

                _ ->
                    NewPost.view model.newPostData
                        |> Html.Styled.map OnNewPostMsg

        UserRoute id tabType ->
            User.view (Route.stringToUserTabType tabType) model model.userPage

        LoginRoute ->
            Login.view model.loginData
                |> Html.Styled.map OnLoginMsg

        LogoutRoute ->
            text ""

        RegisterRoute ->
            Register.view model.registerData
                |> Html.Styled.map OnRegisterMsg

        NotFoundRoute ->
            NotFound.view


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SetSession sessionChange
        , Sub.map OnConfirm onConfirm
        ]


sessionChange : Sub (Maybe Session)
sessionChange =
    Ports.onSessionChange (Decode.decodeValue localSessionDecoder >> Result.toMaybe)


onConfirm : Sub Bool
onConfirm =
    Ports.onConfirm (Decode.decodeValue Decode.bool >> Result.withDefault False)


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = (Route.parseLocation >> OnLocationChange)
        , onUrlRequest = OnLinkClick
        }