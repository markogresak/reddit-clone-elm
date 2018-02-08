module Views.LinkTo exposing (linkTo)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (href)
import Html.Styled.Events exposing (onWithOptions)
import Msgs exposing (..)
import List exposing (concat)
import Json.Decode


preventDefaultAndNavigateTo : String -> Attribute Msg
preventDefaultAndNavigateTo route =
    onWithOptions
        "click"
        { stopPropagation = True, preventDefault = True }
        (Json.Decode.succeed (NavigateTo route))


linkTo : String -> List (Attribute Msg) -> List (Html Msg) -> Html Msg
linkTo route attributes children =
    a
        (concat
            [ attributes
            , [ href route ]
            , [ preventDefaultAndNavigateTo route ]
            ]
        )
        children
