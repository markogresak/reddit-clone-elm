module Views.LinkTo exposing (linkTo)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (href)
import Html.Styled.Events exposing (onWithOptions)
import List exposing (concat)
import Json.Decode


linkTo : (String -> m) -> String -> List (Attribute m) -> List (Html m) -> Html m
linkTo msg route attributes children =
    a
        (concat
            [ attributes
            , [ href route ]
            , [ onWithOptions "click" { stopPropagation = True, preventDefault = True } (Json.Decode.succeed (msg route)) ]
            ]
        )
        children
