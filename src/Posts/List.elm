module Posts.List exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import StyleVariables exposing (..)
import Models exposing (Model, Post)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Views.PostItem exposing (postItem)
import Routing exposing (..)
import Views.LinkTo exposing (linkTo)


view : Model -> WebData (List Post) -> Html Msg
view model response =
    div []
        [ maybeList model response ]


maybeList : Model -> WebData (List Post) -> Html Msg
maybeList model response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success posts ->
            list model posts

        RemoteData.Failure error ->
            text (toString error)


newPostButton : PostType -> String -> Html Msg
newPostButton postType buttonText =
    div
        [ css
            [ marginRight (px 10) ]
        ]
        [ linkTo (newPostPath postType)
            []
            [ button [] [ text buttonText ]
            ]
        ]


list : Model -> List Post -> Html Msg
list model posts =
    div []
        [ div
            [ css
                [ marginTop (px 20)
                , marginRight (px 16)
                , displayFlex
                , justifyContent flexEnd
                ]
            ]
            [ newPostButton LinkPost "+ Add new link post"
            , newPostButton TextPost "+ Add new text post"
            ]
        , div
            [ css
                [ maxWidth (px contentWidth)
                , margin2 (px 0) auto
                , padding (px postsListSpacing)
                ]
            ]
            (List.map (postItem model) posts)
        ]
