module View exposing (..)

import Html.Styled exposing (Html, div, text)
import Models exposing (Model, PostId)
import Models exposing (Model)
import Msgs exposing (Msg)
import Menu
import Posts.Edit
import Posts.List
import RemoteData
import Css exposing (..)
import Css.Foreign exposing (global, body, typeSelector, selector)
import StyleVariables exposing (..)


view : Model -> Html Msg
view model =
    div
        []
        [ global
            [ body
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
        ]



-- page : Model -> Html Msg
-- page model =
--     case model.route of
--         Models.PostsRoute ->
--             Posts.List.view model.posts
--
--         Models.PostRoute id ->
--             postEditPage model id
--
--         Models.NotFoundRoute ->
--             notFoundView
-- postEditPage : Model -> PostId -> Html Msg
-- postEditPage model postId =
--     case model.posts of
--         RemoteData.NotAsked ->
--             text ""
--
--         RemoteData.Loading ->
--             text "Loading ..."
--
--         RemoteData.Success posts ->
--             let
--                 maybePost =
--                     posts
--                         |> List.filter (\post -> post.id == postId)
--                         |> List.head
--             in
--                 case maybePost of
--                     Just post ->
--                         Posts.Edit.view post
--
--                     Nothing ->
--                         notFoundView
--
--         RemoteData.Failure err ->
--             text (toString err)


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
