module Update exposing (..)

import Model exposing (..)
import Request.Post as Post
import Route exposing (parseLocation)
import Navigation exposing (Location)
import Date exposing (Date)
import Task


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform (Just >> SetCurrentTime) Date.now


initLocationState : Location -> Model -> ( Model, Cmd Msg )
initLocationState location model =
    case (Route.parseLocation location) of
        PostsRoute ->
            ( model, Post.list model.apiBase )

        PostRoute postId ->
            ( model, Post.get model.apiBase postId )

        NewPostRoute postType ->
            ( model, Cmd.none )

        UserRoute userId ->
            ( model, Cmd.none )

        LoginRoute ->
            ( model, Cmd.none )

        RegisterRoute ->
            ( model, Cmd.none )

        NotFoundRoute ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            initLocationState location { model | history = location :: model.history, route = parseLocation location }

        NavigateTo route ->
            ( model, Navigation.newUrl route )

        OnfetchPosts response ->
            ( { model | posts = response }, getCurrentDate )

        SetCurrentTime date ->
            ( { model | now = date }, Cmd.none )

        OnfetchCurrentPost response ->
            ( { model | currentPost = response }, getCurrentDate )
