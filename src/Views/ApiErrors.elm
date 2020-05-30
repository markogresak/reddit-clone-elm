module Views.ApiErrors exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import StyleVariables exposing (..)


apiErrors : List String -> Html msg
apiErrors errors =
    let
        errorContent =
            case List.length errors of
                1 ->
                    span [] [ text ("Error: " ++ Maybe.withDefault "" (List.head errors)) ]

                _ ->
                    div []
                        [ strong [] [ text "Errors:" ]
                        , ul [] (List.map (\err -> li [] [ text err ]) errors)
                        ]

        wrapperElement =
            case List.length errors of
                0 ->
                    text ""

                _ ->
                    div
                        [ css
                            [ marginBottom (px 16)
                            , color dangerColor
                            ]
                        ]
                        [ errorContent
                        ]
    in
    wrapperElement
