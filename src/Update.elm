module Update exposing (..)

import Models exposing (..)
import Commands exposing (..)
import Msgs exposing (Msg)
import Route exposing (parseLocation)
import Navigation exposing (Location)
import Date exposing (Date)
import Task


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform (Just >> Msgs.SetCurrentTime) Date.now


initLocationState : Location -> Model -> ( Model, Cmd Msg )
initLocationState location model =
    case (Route.parseLocation location) of
        PostsRoute ->
            ( model, fetchPosts model.apiBase )

        PostRoute postId ->
            ( model, fetchPost model.apiBase postId )

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
        Msgs.NavigateTo route ->
            ( model, Navigation.newUrl route )

        Msgs.OnfetchPosts response ->
            ( { model | posts = response }, getCurrentDate )

        Msgs.OnLocationChange location ->
            initLocationState location { model | history = location :: model.history, route = parseLocation location }

        Msgs.SetCurrentTime date ->
            ( { model | now = date }, Cmd.none )

        Msgs.OnfetchCurrentPost response ->
            ( { model | currentPost = response }, getCurrentDate )
