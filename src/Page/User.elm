module Page.User exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import StyleVariables exposing (..)
import Model exposing (..)
import Route exposing (..)
import RemoteData exposing (WebData)
import Page.Posts exposing (postItemList)
import Views.LinkTo exposing (linkTo)
import Views.CommentItem as CommentItem


view : UserTabType -> Model -> WebData UserPage -> Html Msg
view tabType model response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success userPage ->
            pageView tabType model userPage

        RemoteData.Failure error ->
            text (toString error)


tabButton : UserId -> UserTabType -> String -> Html Msg
tabButton userId tabType title =
    span [ css [ marginRight (px 16) ] ]
        [ linkTo NavigateTo (routeToString (UserRoute userId (userTabTypeToString tabType))) [] [ text title ] ]


pageView : UserTabType -> Model -> UserPage -> Html Msg
pageView tabType model userPage =
    let
        tabContent =
            case tabType of
                PostsTab ->
                    postItemList model userPage.posts

                CommentsTab ->
                    let
                        allCommentModels =
                            List.map (CommentItem.initialModel model) userPage.comments
                    in
                        List.map (CommentItem.view allCommentModels False True True) allCommentModels

                UnknownTab ->
                    [ text "Invalid tab name" ]
    in
        div
            [ css
                [ maxWidth (px contentWidth)
                , margin2 (px 0) auto
                , padding (px postsListSpacing)
                ]
            ]
            (List.concat
                [ [ h1 [] [ text ("User " ++ userPage.username) ]
                  , div [ css [ marginBottom (px 20) ] ]
                        [ tabButton userPage.id PostsTab "Posts"
                        , tabButton userPage.id CommentsTab "Comments"
                        ]
                  , hr [] []
                  ]
                , tabContent
                ]
            )
