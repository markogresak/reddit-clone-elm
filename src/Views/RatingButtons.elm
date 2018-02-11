module Views.RatingButtons exposing (ratingButtons)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import StyleVariables exposing (..)
import Model exposing (..)
import List exposing (concat)
import Ternary exposing ((?))


voteButton : Int -> Bool -> Bool -> Bool -> Html msg
voteButton userRating isDownButton isComment isDisabled =
    let
        arrowSize =
            px (isComment ? 8 <| 10)

        buttonStyle =
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
                , buttonStyle arrowSize solid (voteButtonColor isDownButton userRating)
                , cursor (isDisabled ? notAllowed <| pointer)
                ]
            ]
            []


ratingButtons : Int -> Int -> Bool -> Bool -> Html Msg
ratingButtons rating userRating isComment isCollapsed =
    let
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
            [ voteButton userRating False isComment False
            , buttonSpacer
            , voteButton userRating True isComment False
            ]
