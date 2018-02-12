module Page.Posts exposing (listView, itemView)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import StyleVariables exposing (..)
import Model exposing (..)
import Route exposing (..)
import RemoteData exposing (WebData)
import Views.LinkTo exposing (linkTo)
import Views.PostItem exposing (postItem)
import Views.CommentItem exposing (commentItem)
import Ternary exposing ((?))


listView : Model -> WebData (List Post) -> Html Msg
listView model response =
    maybeView model response postList


itemView : Model -> WebData Post -> Html Msg
itemView model response =
    maybeView model response singlePost


maybeView : Model -> WebData data -> (Model -> data -> Html Msg) -> Html Msg
maybeView model response renderData =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success data ->
            renderData model data

        RemoteData.Failure error ->
            text (toString error)


newPostButton : PostType -> String -> Html Msg
newPostButton postType buttonText =
    div
        [ css
            [ marginRight (px 10) ]
        ]
        [ linkTo (routeToString (NewPostRoute (postTypeToString postType)))
            []
            [ button [] [ text buttonText ]
            ]
        ]


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
            ((model.sessionUser /= Nothing)
                ? [ newPostButton LinkPost "+ Add new link post"
                  , newPostButton TextPost "+ Add new text post"
                  ]
             <|
                []
            )
        , div
            [ css
                [ maxWidth (px contentWidth)
                , margin2 (px 0) auto
                , padding (px postsListSpacing)
                ]
            ]
            (List.map (postItem model) posts)
        ]


commentForm : Html Msg
commentForm =
    div [] []


singlePost : Model -> Post -> Html Msg
singlePost model currentPost =
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
