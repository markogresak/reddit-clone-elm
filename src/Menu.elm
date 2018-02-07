module Menu exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Models exposing (Model)
import Msgs exposing (Msg)
import StyleVariables exposing (..)
import Routing exposing (..)


view : Model -> Html Msg
view model =
    let
        userId =
            123

        username =
            "kek"

        isUserLoggedIn =
            True

        menuRightLinks =
            if isUserLoggedIn then
                span
                    []
                    [ span
                        [ css
                            [ marginRight (px 8) ]
                        ]
                        [ text "Logged in as "
                        , a
                            [ href (userProfilePath userId) ]
                            [ text username ]
                        ]
                    , a
                        [ href "#" ]
                        [ text "Logout" ]
                    ]
            else
                div
                    []
                    [ span
                        [ css
                            [ marginRight (px 16) ]
                        ]
                        [ a
                            [ href (registerPath) ]
                            [ text "Register" ]
                        ]
                    , span
                        []
                        [ a
                            [ href (loginPath) ]
                            [ text "Login" ]
                        ]
                    ]
    in
        div
            [ css
                [ displayFlex
                , justifyContent flexEnd
                , padding2 (px 10) (px 16)
                , borderBottom3 (px 1) solid defaultBorderColor
                , height (px menuHeight)
                , boxSizing borderBox
                ]
            ]
            [ span
                [ css
                    [ marginRight auto ]
                ]
                [ a
                    [ href homePath ]
                    [ text "Home" ]
                ]
            , menuRightLinks
            ]
