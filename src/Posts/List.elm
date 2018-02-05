module Posts.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Models exposing (Post)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Routing exposing (postPath)


view : WebData (List Post) -> Html Msg
view response =
    div []
        [ nav
        , maybeList response
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Posts" ] ]


maybeList : WebData (List Post) -> Html Msg
maybeList response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success posts ->
            list posts

        RemoteData.Failure error ->
            text (toString error)


list : List Post -> Html Msg
list posts =
    div [ class "p2" ]
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Id" ]
                    , th [] [ text "Name" ]
                    , th [] [ text "Actions" ]
                    ]
                ]
            , tbody [] (List.map postRow posts)
            ]
        ]


postRow : Post -> Html Msg
postRow post =
    tr []
        [ td [] [ text (toString post.id) ]
        , td [] [ text post.title ]
        , td []
            [ editBtn post ]
        ]


editBtn : Post -> Html.Html Msg
editBtn post =
    let
        path =
            postPath post.id
    in
        a
            [ class "btn regular"
            , href path
            ]
            [ i [ class "fa fa-pencil mr1" ] [], text "View" ]
