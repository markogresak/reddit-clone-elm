module Main exposing (..)

import Css exposing (fontFamily, sansSerif, textDecoration, none, underline, color)
import Css.Foreign exposing (global, typeSelector, selector)
import StyleVariables exposing (..)
import Html.Styled exposing (..)
import Navigation exposing (Location)
import Route
import Model exposing (..)
import Json.Decode as Decode exposing (Value)
import RemoteData exposing (WebData)
import Util.AccessToken exposing (localSessionDecoder)
import Util.Ports as Ports
import Date exposing (Date)
import Ternary exposing ((?))
import List.Extra
import Task
import Http
import Request.Post as Post
import Views.Menu as Menu
import Page.NotFound as NotFound
import Page.Login as Login
import Page.Posts as Posts
import Page.NewPost as NewPost
import Views.CommentItem as CommentItem


decodeSession : Value -> Maybe Session
decodeSession json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString localSessionDecoder >> Result.toMaybe)


init : Value -> Location -> ( Model, Cmd Msg )
init value location =
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
            { route = currentRoute
            , apiBase = apiBase
            , now = Nothing
            , posts = RemoteData.Loading
            , currentPost = RemoteData.Loading
            , currentPostCommentModels = []
            , sessionUser = sessionUser
            , loginData = (Login.initialModel apiBase)
            , newPostData = (NewPost.initialModel apiBase sessionUser newPostType)
            }


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform (Just >> SetCurrentTime) Date.now


initLocationState : Route -> Model -> ( Model, Cmd Msg )
initLocationState route model =
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
                        ( model, Route.modifyUrl NotFoundRoute )

                    _ ->
                        let
                            initialNewPostData =
                                NewPost.initialModel model.apiBase model.sessionUser postType
                        in
                            ( { model | newPostData = initialNewPostData }, Cmd.none )

        UserRoute userId ->
            ( model, Cmd.none )

        LoginRoute ->
            case model.sessionUser of
                Just sessionUser ->
                    ( model, Route.modifyUrl PostsRoute )

                Nothing ->
                    ( model, Cmd.none )

        LogoutRoute ->
            ( { model | sessionUser = Nothing }
            , Cmd.batch
                [ Ports.storeSession Nothing
                , Route.modifyUrl PostsRoute
                ]
            )

        RegisterRoute ->
            ( model, Cmd.none )

        NotFoundRoute ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange route ->
            initLocationState route { model | route = route }

        NavigateTo route ->
            ( model, Navigation.newUrl route )

        OnfetchPosts response ->
            ( { model | posts = response }, getCurrentDate )

        SetCurrentTime date ->
            ( { model | now = date }, Cmd.none )

        OnfetchCurrentPost response ->
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
                        Route.modifyUrl PostsRoute
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

        OnNewPostMsg subMsg ->
            let
                ( ( newPostModel, cmd ), msgFromPage ) =
                    NewPost.update subMsg model.newPostData
            in
                ( { model | newPostData = newPostModel }, Cmd.map OnNewPostMsg cmd )

        OnCommentFormMsg id subMsg ->
            case (List.Extra.find (\m -> m.comment.id == id) model.currentPostCommentModels) of
                Just commentFormModel ->
                    let
                        ( ( newCommentFormModel, cmd ), msgFromPage ) =
                            CommentItem.update subMsg commentFormModel

                        newModel =
                            { model | currentPostCommentModels = List.map (\m -> (m.comment.id == id) ? newCommentFormModel <| m) model.currentPostCommentModels }
                    in
                        case msgFromPage of
                            CommentItem.CommentFormNavigateTo route ->
                                update (NavigateTo route) newModel

                            CommentItem.CommentFormOnRate ratingType id isDownButton userRating ->
                                update (OnRate ratingType id isDownButton userRating) newModel

                            CommentItem.OnAddNewComment newComment ->
                                ( { newModel
                                    | currentPostCommentModels = [ (CommentItem.initialModel newModel newComment) ] ++ newModel.currentPostCommentModels
                                  }
                                , Cmd.map (OnCommentFormMsg id) cmd
                                )

                            CommentItem.OnEditComment updatedComment ->
                                ( { newModel
                                    | currentPostCommentModels = List.map (\m -> (m.comment.id == updatedComment.id) ? (CommentItem.initialModel newModel updatedComment) <| m) newModel.currentPostCommentModels
                                  }
                                , Cmd.map (OnCommentFormMsg id) cmd
                                )

                            _ ->
                                ( newModel, Cmd.map (OnCommentFormMsg id) cmd )

                Nothing ->
                    ( model, Cmd.map (OnCommentFormMsg id) Cmd.none )

        OnRate ratingType id isDownButton userRating ->
            let
                rating =
                    if isDownButton && userRating /= -1 then
                        -1
                    else if (not isDownButton) && userRating /= 1 then
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

        UserRoute id ->
            Debug.crash ("TODO: UserRoute/" ++ toString id)

        LoginRoute ->
            Login.view model.loginData
                |> Html.Styled.map OnLoginMsg

        LogoutRoute ->
            text ""

        RegisterRoute ->
            Debug.crash "TODO: RegisterRoute"

        NotFoundRoute ->
            NotFound.view


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Sub.map SetSession sessionChange ]


sessionChange : Sub (Maybe Session)
sessionChange =
    Ports.onSessionChange (Decode.decodeValue localSessionDecoder >> Result.toMaybe)


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.parseLocation >> OnLocationChange)
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
