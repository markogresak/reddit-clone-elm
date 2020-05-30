module Views.RatingButtons exposing (ratingButtons)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import List exposing (concat)
import Model exposing (..)
import StyleVariables exposing (..)


voteButton : (RatingType -> VoteId -> Bool -> Int -> m) -> VoteId -> Int -> Bool -> Bool -> Bool -> Html m
voteButton msg id userRating isDownButton isComment voteNotAllowed =
    let
        arrowSize =
            px
                (if isComment then
                    8

                 else
                    10
                )

        arrowDirection =
            if isDownButton then
                borderTop3

            else
                borderBottom3
    in
    button
        [ css
            [ property "background" "none"
            , borderWidth inherit
            , padding (px 0)
            , width (px 0)
            , height (px 0)
            , borderLeft3 arrowSize solid transparent
            , borderRight3 arrowSize solid transparent
            , arrowDirection arrowSize solid (voteButtonColor isDownButton userRating)
            , cursor
                (if voteNotAllowed then
                    notAllowed

                 else
                    pointer
                )
            ]
        , onClick
            (msg
                (if isComment then
                    CommentRating

                 else
                    PostRating
                )
                id
                isDownButton
                userRating
            )
        , Html.Styled.Attributes.disabled voteNotAllowed
        ]
        []


ratingButtons :
    Maybe Session
    -> (RatingType -> VoteId -> Bool -> Int -> m)
    -> VoteId
    -> Int
    -> Int
    -> Bool
    -> Bool
    -> Html m
ratingButtons session msg id rating userRating isComment isCollapsed =
    let
        voteNotAllowed =
            session == Nothing

        commentStyles : List Css.Style
        commentStyles =
            if isComment then
                [ marginTop (px 10)
                , marginRight (px 8)
                , flexBasis auto
                ]

            else
                []

        collapsedStyles : List Css.Style
        collapsedStyles =
            if isCollapsed then
                [ visibility hidden ]

            else
                []

        buttonSpacer =
            case isComment of
                True ->
                    div [ css [ height (px 8) ] ] []

                False ->
                    div
                        [ css
                            [ color (ratingColor userRating)
                            , margin2 (px ratingButtonsTextSpacing) (px 0)
                            ]
                        ]
                        [ text (toString rating) ]
    in
    div
        [ css
            (concat
                [ [ displayFlex
                  , flexDirection column
                  , alignItems center
                  , flexBasis (px ratingButtonsWidth)
                  ]
                , commentStyles
                , collapsedStyles
                ]
            )
        ]
        [ voteButton msg id userRating False isComment voteNotAllowed
        , buttonSpacer
        , voteButton msg id userRating True isComment voteNotAllowed
        ]
