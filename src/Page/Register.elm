module Page.Register exposing (ExternalMsg(..), initialModel, update, view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, for, id, name, type_)
import Html.Styled.Events exposing (onCheck, onInput, onSubmit)
import Http
import Model exposing (..)
import Page.Login exposing (authInput, authLabel)
import Request.User exposing (register, registerErrorsDecoder)
import StyleVariables exposing (..)
import Views.ApiErrors exposing (apiErrors)


initialModel : ApiBase -> RegisterModel
initialModel apiBase =
    { username = ""
    , password = ""
    , passwordConfirm = ""
    , errors = []
    , apiBase = apiBase
    , isLoading = False
    , passwordConfirmError = False
    }


view : RegisterModel -> Html RegisterMsg
view model =
    let
        isError =
            List.length model.errors > 0

        passConfirmError =
            isError || model.passwordConfirmError

        passwordError =
            if model.passwordConfirmError then
                Html.Styled.small
                    [ css
                        [ maxWidth (pct 100)
                        , width (px 200)
                        , color dangerColor
                        , marginTop (px -(authInputMarginBottom / 2))
                        , marginBottom (px authInputMarginBottom)
                        ]
                    ]
                    [ text "Password confirmation must match the value for Password." ]

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
        [ form [ onSubmit OnRegisterSubmit ]
            [ div
                [ css
                    [ displayFlex
                    , flexDirection column
                    , alignItems center
                    , justifyContent spaceBetween
                    , maxWidth (pct 100)
                    , width (px authFormWidth)
                    ]
                ]
                [ apiErrors model.errors
                , authLabel isError [ for "username" ] [ text "Username" ]
                , authInput isError [ type_ "text", name "username", onInput OnRegisterUsernameChange ]
                , authLabel isError [ for "password" ] [ text "Password" ]
                , authInput isError [ type_ "password", name "password", onInput OnRegisterPasswordChange ]
                , authLabel passConfirmError [ for "password" ] [ text "Password confirmation" ]
                , authInput passConfirmError [ type_ "password", name "password_confirmation", onInput OnRegisterPasswordConfirmChange ]
                , passwordError
                , button
                    [ type_ "submit", Html.Styled.Attributes.disabled model.isLoading ]
                    [ text
                        (if model.isLoading then
                            "Logging in..."

                         else
                            "Register"
                        )
                    ]
                ]
            ]
        ]


type ExternalMsg
    = NoOp
    | OnRegisterSuccess


update : RegisterMsg -> RegisterModel -> ( ( RegisterModel, Cmd RegisterMsg ), ExternalMsg )
update msg model =
    case msg of
        OnRegisterSubmit ->
            let
                modelWithErrors =
                    { model | passwordConfirmError = model.password /= model.passwordConfirm }

                action =
                    if modelWithErrors.passwordConfirmError then
                        Cmd.none

                    else
                        Http.send OnRegisterCompleted (Request.User.register model.apiBase model)
            in
            ( ( modelWithErrors, action ), NoOp )

        OnRegisterUsernameChange username ->
            ( ( { model | username = username }, Cmd.none ), NoOp )

        OnRegisterPasswordChange password ->
            ( ( { model | password = password }, Cmd.none ), NoOp )

        OnRegisterPasswordConfirmChange passwordConfirm ->
            ( ( { model | passwordConfirm = passwordConfirm }, Cmd.none ), NoOp )

        OnRegisterCompleted (Err error) ->
            let
                errorMessages =
                    case error of
                        Http.BadStatus response ->
                            registerErrorsDecoder response.body

                        _ ->
                            [ "Could not register" ]
            in
            ( ( { model | errors = errorMessages, isLoading = False }, Cmd.none ), NoOp )

        OnRegisterCompleted (Ok _) ->
            ( ( { model | errors = [], isLoading = False }, Cmd.none ), OnRegisterSuccess )
