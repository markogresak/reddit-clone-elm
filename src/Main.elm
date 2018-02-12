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
import Task
import Request.Post as Post
import Views.Menu as Menu
import Page.NotFound as NotFound
import Page.Login as Login
import Page.Posts as Posts


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
    in
        initLocationState
            currentRoute
            { route = currentRoute
            , apiBase = apiBase
            , now = Nothing
            , posts = RemoteData.Loading
            , currentPost = RemoteData.Loading
            , sessionUser = (decodeSession value)
            , loginData = (Login.initialModel apiBase)
            }


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform (Just >> SetCurrentTime) Date.now


initLocationState : Route -> Model -> ( Model, Cmd Msg )
initLocationState route model =
    case route of
        PostsRoute ->
            ( model, Post.list model.apiBase )

        PostRoute postId ->
            ( model, Post.get model.apiBase postId )

        NewPostRoute postType ->
            ( model, Cmd.none )

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
            ( { model | currentPost = response }, getCurrentDate )

        SetSession sessionUser ->
            let
                cmd =
                    if model.sessionUser /= Nothing && sessionUser == Nothing then
                        Route.modifyUrl PostsRoute
                    else
                        Cmd.none
            in
                ( { model | sessionUser = sessionUser }, cmd )

        Model.OnLoginMsg subMsg ->
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
                ( { newModel | loginData = loginModel }, Cmd.map Model.OnLoginMsg cmd )


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

        NewPostRoute _ ->
            Debug.crash "TODO"

        UserRoute _ ->
            Debug.crash "TODO"

        LoginRoute ->
            Login.view model.loginData
                |> Html.Styled.map OnLoginMsg

        LogoutRoute ->
            text ""

        RegisterRoute ->
            Debug.crash "TODO"

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
