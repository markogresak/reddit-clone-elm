module Posts.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, href)
import Models exposing (Post)
import Msgs exposing (Msg)
import Routing exposing (postsPath)


view : Post -> Html.Html Msg
view model =
    div []
        [ nav model
        , form model
        ]


nav : Post -> Html.Html Msg
nav model =
    div [ class "clearfix mb2 white bg-black p1" ]
        [ listBtn ]


form : Post -> Html.Html Msg
form post =
    div [ class "m3" ]
        [ h1 [] [ text post.title ]
        , formLevel post
        ]


formLevel : Post -> Html.Html Msg
formLevel post =
    div
        [ class "clearfix py1"
        ]
        [ div [ class "col col-5" ] [ text "Level" ]
        , div [ class "col col-7" ]
            [ span [ class "h2 bold" ] [ text (toString 0) ]
            ]
        ]


listBtn : Html Msg
listBtn =
    a
        [ class "btn regular"
        , href postsPath
        ]
        [ i [ class "fa fa-chevron-left mr1" ] [], text "List" ]
