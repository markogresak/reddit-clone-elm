module Views.RatingButtons exposing (ratingButtons)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import StyleVariables exposing (..)
import Model exposing (..)
import List exposing (concat)
import Ternary exposing ((?))


voteButton : VoteId -> Int -> Bool -> Bool -> Bool -> Html Msg
voteButton id userRating isDownButton isComment voteNotAllowed =
    let
        arrowSize =
            px (isComment ? 8 <| 10)

        arrowDirection =
            isDownButton ? borderTop3 <| borderBottom3
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
                , cursor (voteNotAllowed ? notAllowed <| pointer)
                ]
            , onClick (OnRate (isComment ? CommentRating <| PostRating) id isDownButton userRating)
            , Html.Styled.Attributes.disabled voteNotAllowed
            ]
            []


ratingButtons : Maybe Session -> VoteId -> Int -> Int -> Bool -> Bool -> Html Msg
ratingButtons session id rating userRating isComment isCollapsed =
    let
        voteNotAllowed =
            session == Nothing

        commentStyles : List Css.Style
        commentStyles =
            isComment
                ? [ marginTop (px 10)
                  , marginRight (px 8)
                  , flexBasis auto
                  ]
            <|
                []

        collapsedStyles : List Css.Style
        collapsedStyles =
            isCollapsed ? [ visibility hidden ] <| []

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
            [ voteButton id userRating False isComment voteNotAllowed
            , buttonSpacer
            , voteButton id userRating True isComment voteNotAllowed
            ]
