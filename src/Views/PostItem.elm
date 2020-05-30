module Views.PostItem exposing (postItem)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import List
import Model exposing (..)
import Regex exposing (..)
import Route exposing (..)
import StyleVariables exposing (..)
import Time.Distance
import Views.LinkTo exposing (linkTo)
import Views.RatingButtons exposing (ratingButtons)


postTitleUrl : String -> Html Msg
postTitleUrl url =
    let
        urlAuthority =
            case List.head (find (AtMost 1) (regex ":\\/\\/(.[^/]+)(.*)") url) of
                Just { submatches } ->
                    Maybe.withDefault "" (List.head submatches)

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
            linkTo NavigateTo (routeToString (PostRoute post.id)) [] [ text post.title ]


details : Post -> Maybe Date -> Html Msg
details post now =
    let
        submittedAgo =
            case now of
                Just now ->
                    Time.Distance.inWords (Date.toTime post.submittedAt) now

                Nothing ->
                    ""
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
            , linkTo NavigateTo
                (routeToString (UserRoute post.user.id (userTabTypeToString PostsTab)))
                []
                [ text post.user.username ]
            ]
        ]


commentCount : Post -> Html Msg
commentCount post =
    div []
        [ linkTo NavigateTo
            (routeToString (PostRoute post.id))
            [ css
                [ fontSize (px textSmSize)
                , fontWeight bold
                , color mutedTextColor
                ]
            ]
            [ text (toString post.commentCount ++ " comments") ]
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
        [ ratingButtons model.sessionUser OnRate post.id post.rating post.userRating False False
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
