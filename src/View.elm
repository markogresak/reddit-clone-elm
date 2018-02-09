module View exposing (..)

import Html.Styled exposing (..)
import Models exposing (..)
import Msgs exposing (Msg)
import Css exposing (..)
import Css.Foreign exposing (global, typeSelector, selector)
import StyleVariables exposing (..)
import Views.Menu as Menu
import Posts.List
import Posts.SinglePost


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
        Models.PostsRoute ->
            Posts.List.view model model.posts

        Models.PostRoute id ->
            Posts.SinglePost.view model model.currentPost id

        Models.NewPostRoute _ ->
            Debug.crash "TODO"

        Models.UserRoute _ ->
            Debug.crash "TODO"

        Models.LoginRoute ->
            Debug.crash "TODO"

        Models.RegisterRoute ->
            Debug.crash "TODO"

        Models.NotFoundRoute ->
            notFoundView


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found" ]
