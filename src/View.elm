module View exposing (..)

import Html.Styled exposing (..)
import Model exposing (..)
import Css exposing (..)
import Css.Foreign exposing (global, typeSelector, selector)
import StyleVariables exposing (..)
import Views.Menu as Menu
import Page.Posts


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
            Page.Posts.listView model model.posts

        PostRoute id ->
            Page.Posts.itemView model model.currentPost

        NewPostRoute _ ->
            Debug.crash "TODO"

        UserRoute _ ->
            Debug.crash "TODO"

        LoginRoute ->
            Debug.crash "TODO"

        LogoutRoute ->
            text ""

        RegisterRoute ->
            Debug.crash "TODO"

        NotFoundRoute ->
            notFoundView


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found" ]
