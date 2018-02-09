module Views.PostItem exposing (postItem)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Models exposing (..)
import Route exposing (..)
import Msgs exposing (..)
import StyleVariables exposing (..)
import Route exposing (..)
import Date.Distance
import Date exposing (Date)
import Regex exposing (..)
import List
import Views.LinkTo exposing (linkTo)
import Views.RatingButtons exposing (ratingButtons)
import Ternary exposing ((?:))


postTitleUrl : String -> Html Msg
postTitleUrl url =
    let
        urlAuthority =
            case List.head (find (AtMost 1) (regex ":\\/\\/(.[^/]+)(.*)") url) of
                Just { submatches } ->
                    List.head submatches ?: Nothing ?: ""

                Nothing ->
                    ""
    in
        Html.Styled.small
            [ css
                [ marginLeft (px 6)
                , color mutedTextColor
                , fontSize (px textXsSize)
                , before [ property "content" "'('" ]
                , after [ property "content" "')'" ]
                ]
            ]
            [ text urlAuthority ]


postTitle : Post -> Html Msg
postTitle post =
    case post.url of
        Just url ->
            span []
                [ a [ href url ] [ text post.title ]
                , postTitleUrl url
                ]

        Nothing ->
            linkTo (routeToString (PostRoute post.id)) [] [ text post.title ]


details : Post -> Maybe Date -> Html Msg
details post now =
    let
        submittedAgo =
            case now of
                Just now ->
                    Date.Distance.inWords post.submittedAt now

                Nothing ->
                    "???"
    in
        div
            [ css
                [ fontSize (px textSmSize)
                , color mutedTextColor
                , paddingTop (px 6)
                ]
            ]
            [ span []
                [ text ("Submitted " ++ submittedAgo ++ " ago by ")
                , linkTo (routeToString (UserRoute post.user.id))
                    []
                    [ text post.user.username ]
                ]
            ]


commentCount : Post -> Html Msg
commentCount post =
    div []
        [ linkTo (routeToString (PostRoute post.id))
            [ css
                [ fontSize (px textSmSize)
                , fontWeight bold
                , color mutedTextColor
                ]
            ]
            [ text ((toString post.commentCount) ++ " comments") ]
        ]


postItem : Model -> Post -> Html Msg
postItem model post =
    div
        [ css
            [ displayFlex
            , marginTop (px postSpacing)
            , minHeight (px postHeight)
            ]
        ]
        [ ratingButtons post.rating post.userRating False False
        , div
            [ css
                [ displayFlex
                , flexDirection column
                , justifyContent spaceBetween
                , flexBasis (calc (pct 100) minus (px ratingButtonsWidth))
                ]
            ]
            [ postTitle post
            , details post model.now
            , commentCount post
            ]
        ]
