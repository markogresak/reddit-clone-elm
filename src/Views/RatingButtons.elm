module Views.RatingButtons exposing (ratingButtons)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import StyleVariables exposing (..)
import Msgs exposing (..)
import Models exposing (Post)
import List exposing (concat)
import Ternary exposing ((?))


type alias RatingButtonOptions =
    { isComment : Bool
    , isCollapsed : Bool
    }


type alias VoteButtonOptions =
    { isDownButton : Bool
    , isComment : Bool
    , isDisabled : Bool
    }


voteButton : Int -> VoteButtonOptions -> Html msg
voteButton userRating { isDownButton, isComment, isDisabled } =
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


ratingButtons : Post -> RatingButtonOptions -> Html Msg
ratingButtons post options =
    let
        commentStyles : List Css.Style
        commentStyles =
            options.isComment
                ? [ marginTop (px 10)
                  , marginRight (px 8)
                  , flexBasis auto
                  ]
            <|
                []

        collapsedStyles : List Css.Style
        collapsedStyles =
            options.isCollapsed ? [ visibility hidden ] <| []

        buttonSpacer =
            case options.isComment of
                True ->
                    div [ css [ height (px 8) ] ] []

                False ->
                    div
                        [ css
                            [ color (ratingColor post.userRating)
                            , margin2 (px ratingButtonsTextSpacing) (px 0)
                            ]
                        ]
                        [ text (toString post.rating) ]
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
            [ voteButton post.userRating { isDownButton = False, isComment = options.isComment, isDisabled = False }
            , buttonSpacer
            , voteButton post.userRating { isDownButton = True, isComment = options.isComment, isDisabled = False }
            ]
