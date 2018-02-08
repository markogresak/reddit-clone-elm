module Views.Menu exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Models exposing (Model)
import Msgs exposing (..)
import StyleVariables exposing (..)
import Routing exposing (..)
import Views.LinkTo exposing (linkTo)


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
                span []
                    [ span [ css [ marginRight (px 8) ] ]
                        [ text "Logged in as "
                        , linkTo (userProfilePath userId)
                            []
                            [ text username ]
                        ]
                    , linkTo "#"
                        []
                        [ text "Logout" ]
                    ]
            else
                div []
                    [ span [ css [ marginRight (px 16) ] ]
                        [ linkTo registerPath
                            []
                            [ text "Register" ]
                        ]
                    , span []
                        [ linkTo loginPath
                            []
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
            [ span [ css [ marginRight auto ] ]
                [ linkTo homePath
                    []
                    [ text "Home" ]
                ]
            , menuRightLinks
            ]
