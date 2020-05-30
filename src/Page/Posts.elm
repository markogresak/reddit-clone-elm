module Page.Posts exposing (itemView, listView, postItemList)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import List.Extra
import Model exposing (..)
import RemoteData exposing (WebData)
import Route exposing (..)
import StyleVariables exposing (..)
import Views.CommentItem as CommentItem
import Views.LinkTo exposing (linkTo)
import Views.PostItem exposing (postItem)


listView : Model -> WebData (List Post) -> Html Msg
listView model response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success posts ->
            postList model posts

        RemoteData.Failure error ->
            text (toString error)


itemView : Model -> WebData Post -> Html Msg
itemView model response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success currentPost ->
            singlePost model currentPost

        RemoteData.Failure error ->
            text (toString error)


newPostButton : PostType -> String -> Html Msg
newPostButton postType buttonText =
    div
        [ css
            [ marginRight (px 10) ]
        ]
        [ linkTo NavigateTo
            (routeToString (NewPostRoute (postTypeToString postType)))
            []
            [ button [] [ text buttonText ]
            ]
        ]


postItemList : Model -> List Post -> List (Html Msg)
postItemList model posts =
    List.map (postItem model) posts


postList : Model -> List Post -> Html Msg
postList model posts =
    div []
        [ div
            [ css
                [ marginTop (px 20)
                , marginRight (px 16)
                , displayFlex
                , justifyContent flexEnd
                ]
            ]
            (if model.sessionUser /= Nothing then
                [ newPostButton LinkPost "+ Add new link post"
                , newPostButton TextPost "+ Add new text post"
                ]

             else
                []
            )
        , div
            [ css
                [ maxWidth (px contentWidth)
                , margin2 (px 0) auto
                , padding (px postsListSpacing)
                ]
            ]
            (postItemList model posts)
        ]


singlePost : Model -> Post -> Html Msg
singlePost model currentPost =
    let
        topLevelComments =
            List.filter (\m -> m.comment.id /= -1 && m.comment.parentCommentId == Nothing) model.currentPostCommentModels
                |> List.map (CommentItem.view model.currentPostCommentModels False False False)

        commentForm =
            case List.Extra.find (\m -> m.comment.id == -1) model.currentPostCommentModels of
                Just newCommentModel ->
                    CommentItem.commentForm newCommentModel False |> CommentItem.mapCommentMsg -1

                Nothing ->
                    text ""

        comments =
            div [ css [ marginLeft (px ratingButtonsWidth) ] ]
                (List.concat
                    [ [ div [ css [ marginTop (px 16) ] ]
                            [ strong []
                                [ text (toString currentPost.commentCount ++ " comments") ]
                            , hr [] []
                            ]
                      , commentForm
                      ]
                    , topLevelComments
                    ]
                )
    in
    div
        [ css
            [ maxWidth (px contentWidth)
            , margin2 (px 0) auto
            , padding (px postsListSpacing)
            ]
        ]
        [ postItem model currentPost
        , if String.isEmpty currentPost.text then
            text ""

          else
            div
                [ css
                    [ backgroundColor textBlockBackground
                    , marginTop (px 16)
                    , marginLeft (px ratingButtonsWidth)
                    , padding (px 16)
                    , borderRadius (px 4)
                    , border3 (px 1) solid textBlockBorder
                    ]
                ]
                [ text currentPost.text ]
        , comments
        ]
