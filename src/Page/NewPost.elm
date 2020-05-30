module Page.NewPost exposing (ExternalMsg(..), initialModel, update, view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (cols, css, for, id, name, rows, type_)
import Html.Styled.Events exposing (onInput, onSubmit)
import Http
import Model exposing (..)
import Request.Post
import Route exposing (modifyUrl, postTypeToString)
import Views.ApiErrors exposing (apiErrors)


initialModel : ApiBase -> Maybe Session -> PostType -> NewPostModel
initialModel apiBase session postType =
    { postType = postType
    , title = ""
    , url = Nothing
    , text = Nothing
    , errors = []
    , apiBase = apiBase
    , session = session
    , isLoading = False
    }


view : NewPostModel -> Html NewPostMsg
view model =
    let
        postTypeForm =
            case model.postType of
                LinkPost ->
                    formGroup
                        [ newPostLabel [ for "url" ] [ text "Link" ]
                        , newPostInput [ type_ "text", name "url", id "url", onInput OnUrlChange ]
                        ]

                TextPost ->
                    formGroup
                        [ newPostLabel [ for "text" ] [ text "Text" ]
                        , textarea
                            [ css [ width (pct 100), height (px 100) ]
                            , name "text"
                            , id "text"
                            , cols 1
                            , rows 1
                            , Html.Styled.Attributes.required True
                            , onInput OnTextChange
                            ]
                            []
                        ]

                Model.UnknownPost ->
                    text ""
    in
    div
        [ css
            [ maxWidth (px 500)
            , margin3 (px 20) auto (px 0)
            ]
        ]
        [ h1 [] [ text ("Add new " ++ postTypeToString model.postType ++ " post") ]
        , apiErrors model.errors
        , div []
            [ form [ onSubmit OnNewPostSubmit ]
                [ formGroup
                    [ newPostLabel [ for "title" ] [ text "Title" ]
                    , newPostInput [ type_ "text", name "title", id "title", onInput OnTitleChange ]
                    ]
                , postTypeForm
                , button [ type_ "submit", Html.Styled.Attributes.disabled model.isLoading ]
                    [ text
                        (if model.isLoading then
                            "Saving post..."

                         else
                            "Save post"
                        )
                    ]
                ]
            ]
        ]


formGroup : List (Html msg) -> Html msg
formGroup =
    div [ css [ marginBottom (px 16) ] ]


newPostLabel : List (Attribute msg) -> List (Html msg) -> Html msg
newPostLabel attributes =
    label
        (css
            [ fontWeight bold
            , display inlineBlock
            , paddingBottom (px 6)
            ]
            :: attributes
        )


newPostInput : List (Attribute msg) -> Html msg
newPostInput attributes =
    input (css [ width (pct 100) ] :: Html.Styled.Attributes.required True :: attributes) []


type ExternalMsg
    = NoOp
    | OnAddNewPost Post


update : NewPostMsg -> NewPostModel -> ( ( NewPostModel, Cmd NewPostMsg ), ExternalMsg )
update msg model =
    case msg of
        OnNewPostSubmit ->
            ( ( { model | isLoading = True }
              , Http.send OnAddNewPostCompleted (Request.Post.create model.apiBase model.session model)
              )
            , NoOp
            )

        OnTitleChange title ->
            ( ( { model | title = title }, Cmd.none ), NoOp )

        OnUrlChange url ->
            ( ( { model | url = Just url }, Cmd.none ), NoOp )

        OnTextChange text ->
            ( ( { model | text = Just text }, Cmd.none ), NoOp )

        OnAddNewPostCompleted (Err error) ->
            let
                errorMessages =
                    [ "An error occured while trying to create a new post." ]
            in
            ( ( { model | errors = errorMessages, isLoading = False }, Cmd.none ), NoOp )

        OnAddNewPostCompleted (Ok newPost) ->
            ( ( { model | errors = [], isLoading = False }
              , Route.modifyUrl (PostRoute newPost.id)
              )
            , OnAddNewPost newPost
            )
