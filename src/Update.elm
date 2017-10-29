module Update exposing (..)

import Models exposing (Model, Post)
import Msgs exposing (Msg)
import Routing exposing (parseLocation)
import RemoteData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnfetchPosts response ->
            ( { model | posts = response }, Cmd.none )

        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        Msgs.OnPostSave (Ok post) ->
            ( updatePost model post, Cmd.none )

        Msgs.OnPostSave (Err error) ->
            ( model, Cmd.none )


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
