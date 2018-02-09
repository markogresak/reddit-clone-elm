module Update exposing (..)

import Models exposing (Model, Post)
import Msgs exposing (Msg)
import Routing exposing (parseLocation)
import RemoteData
import Navigation
import Date exposing (Date)
import Task


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform (Just >> Msgs.SetCurrentTime) Date.now


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.NavigateTo route ->
            ( model, Navigation.newUrl route )

        Msgs.OnfetchPosts response ->
            ( { model | posts = response }, getCurrentDate )

        Msgs.OnLocationChange location ->
            ( { model | history = location :: model.history, route = parseLocation location }, getCurrentDate )

        Msgs.OnPostSave (Ok post) ->
            ( updatePost model post, Cmd.none )

        Msgs.OnPostSave (Err error) ->
            ( model, Cmd.none )

        Msgs.SetCurrentTime date ->
            ( { model | now = date }, Cmd.none )


updatePost : Model -> Post -> Model
updatePost model updatedPost =
    let
        pick currentPost =
            if updatedPost.id == currentPost.id then
                updatedPost
            else
                currentPost

        updatePostList posts =
            List.map pick posts

        updatedPosts =
            RemoteData.map updatePostList model.posts
    in
        { model | posts = updatedPosts }
