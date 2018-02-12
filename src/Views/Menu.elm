module Views.Menu exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Model exposing (..)
import StyleVariables exposing (..)
import Route exposing (..)
import Views.LinkTo exposing (linkTo)


view : Model -> Html Msg
view model =
    let
        menuRightLinks =
            case model.sessionUser of
                Just sessionUser ->
                    span []
                        [ span [ css [ marginRight (px 8) ] ]
                            [ text "Logged in as "
                            , linkTo (routeToString (UserRoute sessionUser.id))
                                []
                                [ text sessionUser.username ]
                            ]
                        , linkTo (routeToString LogoutRoute)
                            []
                            [ text "Logout" ]
                        ]

                Nothing ->
                    div []
                        [ span [ css [ marginRight (px 16) ] ]
                            [ linkTo (routeToString RegisterRoute)
                                []
                                [ text "Register" ]
                            ]
                        , span []
                            [ linkTo (routeToString LoginRoute)
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
                [ linkTo (routeToString PostsRoute)
                    []
                    [ text "Home" ]
                ]
            , menuRightLinks
            ]
