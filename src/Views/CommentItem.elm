module Views.CommentItem exposing (commentItem)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Model exposing (..)
import Route exposing (..)
import StyleVariables exposing (..)
import Route exposing (..)
import Date.Distance
import Date exposing (Date)
import List
import Views.LinkTo exposing (linkTo)
import Views.RatingButtons exposing (ratingButtons)
import Ternary exposing (..)


commentForm : String -> Html Msg
commentForm defaultText =
    div [] []


commentDetails : Comment -> Maybe Date -> Bool -> Html Msg
commentDetails comment now isCollapsed =
    let
        submittedAgo =
            case now of
                Just now ->
                    Date.Distance.inWords comment.submittedAt now

                Nothing ->
                    "???"
    in
        div
            [ css
                [ fontSize (px textSmSize)
                , color mutedTextColor
                , paddingTop (px 6)
                , marginBottom (px 4)
                ]
            ]
            [ span
                [ css
                    [ marginRight (px 8)
                    , cursor pointer
                    , hover [ textDecoration underline ]
                    ]
                ]
                [ text ("[ " ++ (isCollapsed ? "+" <| "-") ++ " ]") ]
            , linkTo (routeToString (UserRoute comment.user.id)) [] [ text comment.user.username ]
            , span
                [ css
                    [ fontWeight bold
                    , color defaultTextColor
                    ]
                ]
                [ text (" " ++ (toString comment.rating) ++ " points ") ]
            , span []
                [ text (submittedAgo ++ " ago") ]
            ]


commentText : Bool -> Comment -> Html Msg
commentText isEditMode comment =
    let
        content =
            case isEditMode of
                True ->
                    commentForm comment.text

                False ->
                    span []
                        [ text comment.text ]
    in
        div []
            [ content ]


commentActionButtons : Model -> Comment -> Html Msg
commentActionButtons model comment =
    let
        actionLink =
            span
                [ css
                    [ fontSize (px textSmSize)
                    , fontWeight bold
                    , color mutedTextColor
                    , paddingTop (px 8)
                    , marginBottom (px 6)
                    , marginRight (px 6)
                    , cursor pointer
                    ]
                ]

        currentUserId =
            case model.sessionUser of
                Just { id } ->
                    id

                Nothing ->
                    -1

        ownCommentActions =
            if comment.user.id == currentUserId then
                [ span []
                    [ actionLink [ text "Edit" ]
                    , actionLink [ text "Delete" ]
                    ]
                ]
            else
                []
    in
        span []
            [ span []
                (List.concat
                    [ [ actionLink [ text "Reply" ] ]
                    , ownCommentActions
                    ]
                )
            ]


commentReplyForm : Bool -> Html Msg
commentReplyForm showReplyForm =
    case showReplyForm of
        True ->
            commentForm ""

        False ->
            text ""


commentItem : Model -> List Comment -> Bool -> Bool -> Bool -> Comment -> Html Msg
commentItem model allComments isNested isCollapsed disableNesting comment =
    div
        [ css
            [ displayFlex
            , marginTop (px (isNested ? 8 <| 20))
            , firstChild [ marginTop (px 0) ]
            ]
        ]
        [ ratingButtons model.sessionUser comment.id comment.rating comment.userRating True False
        , div []
            [ commentDetails comment model.now isCollapsed
            , div [ css (isCollapsed ? [ display none ] <| []) ]
                [ div []
                    [ commentText False comment
                    , commentActionButtons model comment
                    , commentReplyForm False
                    , disableNesting
                        ? text ""
                      <|
                        div
                            [ css
                                [ borderLeft3 (px 1) solid defaultBorderColor
                                , paddingLeft (px 16)
                                ]
                            ]
                            (List.filter (\c -> (Maybe.withDefault 0 c.parentCommentId) == comment.id) allComments
                                |> List.map (commentItem model allComments True isCollapsed disableNesting)
                            )
                    ]
                ]
            ]
        ]
