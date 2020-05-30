module Page.Login exposing (ExternalMsg(..), authInput, authLabel, initialModel, update, view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, for, id, name, type_)
import Html.Styled.Events exposing (onCheck, onInput, onSubmit)
import Http
import Model exposing (..)
import Request.User exposing (login, loginErrorDecoder)
import Route exposing (modifyUrl)
import StyleVariables exposing (..)
import Util.AccessToken as AccessToken
import Util.Ports as Ports
import Views.ApiErrors exposing (apiErrors)


initialModel : ApiBase -> LoginModel
initialModel apiBase =
    { username = ""
    , password = ""
    , rememberMe = True
    , errors = []
    , apiBase = apiBase
    , isLoading = False
    , registerSuccess = False
    }


view : LoginModel -> Html LoginMsg
view model =
    let
        isError =
            List.length model.errors > 0

        registerSuccessText =
            if model.registerSuccess then
                strong [ css [ margin2 (px 16) (px 0), color successColor ] ]
                    [ text "The registration was successful. You can now login with the chosen username and password." ]

            else
                text ""
    in
    div
        [ css
            [ width (vw 100)
            , height (calc (vh 100) minus (px menuHeight))
            , displayFlex
            , alignItems center
            , justifyContent center
            ]
        ]
        [ form [ onSubmit OnLoginSubmit ]
            [ div
                [ css
                    [ displayFlex
                    , flexDirection column
                    , alignItems center
                    , justifyContent spaceBetween
                    , width (px authFormWidth)
                    ]
                ]
                [ apiErrors model.errors
                , registerSuccessText
                , authLabel isError [ for "username" ] [ text "Username" ]
                , authInput isError [ type_ "text", name "username", onInput OnUsernameChange ]
                , authLabel isError [ for "password" ] [ text "Password" ]
                , authInput isError [ type_ "password", name "password", onInput OnPasswordChange ]
                , authLabel isError
                    [ css [ marginBottom (px authInputMarginBottom) ] ]
                    [ input
                        [ type_ "checkbox"
                        , name "rememberMe"
                        , id "rememberMe"
                        , onCheck OnRememberMeChange
                        , Html.Styled.Attributes.checked model.rememberMe
                        ]
                        []
                    , label [ for "rememberMe", css [ marginLeft (px 8) ] ] [ text "Remember me" ]
                    ]
                , button
                    [ type_ "submit", Html.Styled.Attributes.disabled model.isLoading ]
                    [ text
                        (if model.isLoading then
                            "Logging in..."

                         else
                            "Login"
                        )
                    ]
                ]
            ]
        ]


type ExternalMsg
    = NoOp
    | SetSession Session


update : LoginMsg -> LoginModel -> ( ( LoginModel, Cmd LoginMsg ), ExternalMsg )
update msg model =
    case msg of
        OnLoginSubmit ->
            ( ( { model | isLoading = True }
              , Http.send OnLoginCompleted (Request.User.login model.apiBase model)
              )
            , NoOp
            )

        OnUsernameChange username ->
            ( ( { model | username = username }, Cmd.none ), NoOp )

        OnPasswordChange password ->
            ( ( { model | password = password }, Cmd.none ), NoOp )

        OnRememberMeChange rememberMe ->
            ( ( { model | rememberMe = rememberMe }, Cmd.none ), NoOp )

        OnLoginCompleted (Err error) ->
            let
                errorMessages =
                    case error of
                        Http.BadStatus response ->
                            loginErrorDecoder response.body

                        _ ->
                            [ "Could not login" ]
            in
            ( ( { model | errors = errorMessages, isLoading = False }, Cmd.none ), NoOp )

        OnLoginCompleted (Ok sessionUser) ->
            let
                encodedSession =
                    AccessToken.encode (Just { sessionUser | rememberMe = model.rememberMe })
            in
            ( ( { model | errors = [], isLoading = False }
              , Cmd.batch [ Ports.storeSession encodedSession, Route.modifyUrl PostsRoute ]
              )
            , SetSession sessionUser
            )


authLabel : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
authLabel isError attributes =
    label
        (css
            [ alignSelf left
            , marginBottom (px (authInputMarginBottom / 2))
            , marginLeft (px -8)
            , color (isErrorColor isError)
            ]
            :: Html.Styled.Attributes.required True
            :: attributes
        )


authInput : Bool -> List (Attribute msg) -> Html msg
authInput isError attributes =
    input
        (css
            [ border3 (px 1) solid defaultBorderColor
            , borderRadius (px 4)
            , padding (px 8)
            , width (pct 100)
            , marginBottom (px authInputMarginBottom)
            , color (isErrorColor isError)
            ]
            :: attributes
        )
        []


isErrorColor : Bool -> Color
isErrorColor isError =
    if isError then
        dangerColor

    else
        defaultTextColor
