module Posts.SinglePost exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Models exposing (..)
import Msgs exposing (..)
import StyleVariables exposing (..)
import RemoteData exposing (WebData)
import Views.PostItem exposing (postItem)
import Views.CommentItem exposing (commentItem)


view : Model -> WebData Post -> PostId -> Html Msg
view model currentPost postId =
    case currentPost of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading ..."

        RemoteData.Success currentPost ->
            post model currentPost

        RemoteData.Failure err ->
            text (toString err)


commentForm : Html Msg
commentForm =
    div [] []


post : Model -> Post -> Html Msg
post model currentPost =
    let
        topLevelComments =
            List.filter (\c -> c.parentCommentId == Nothing) currentPost.comments
    in
        div
            [ css
                [ maxWidth (px contentWidth)
                , margin2 (px 0) auto
                , padding (px postsListSpacing)
                ]
            ]
            [ postItem model currentPost
            , div
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
            , div [ css [ marginLeft (px ratingButtonsWidth) ] ]
                (List.concat
                    [ [ div [ css [ marginTop (px 16) ] ]
                            [ strong []
                                [ text ((toString currentPost.commentCount) ++ " comments") ]
                            , hr [] []
                            ]
                      , commentForm
                      ]
                    , List.map (commentItem model currentPost.comments False False False) topLevelComments
                    ]
                )
            ]
