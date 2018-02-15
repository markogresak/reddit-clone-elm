module Views.CommentItem exposing (initialModel, view, update, commentForm)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, name, id, cols, rows, value, type_)
import Html.Styled.Events exposing (onClick, onInput)
import Model exposing (..)
import Route exposing (..)
import StyleVariables exposing (..)
import Route exposing (..)
import Date.Distance
import Date exposing (Date)
import List
import Ternary exposing (..)
import Views.LinkTo exposing (linkTo)
import Views.RatingButtons exposing (ratingButtons)


initialModel : Model -> Comment -> CommentFormModel
initialModel model comment =
    { commentText = ""
    , showReplyForm = False
    , isEditMode = False
    , isCollapsed = False
    , errors = []
    , isLoading = False
    , apiBase = model.apiBase
    , session = model.sessionUser
    , now = model.now
    , comment = comment
    }


collapseButton : Bool -> Html CommentFormMsg
collapseButton isCollapsed =
    span
        [ css
            [ marginRight (px 8)
            , cursor pointer
            , hover [ textDecoration underline ]
            ]
        , onClick OnCollapseClick
        ]
        [ text ("[ " ++ (isCollapsed ? "+" <| "-") ++ " ]") ]


commentDetails : Comment -> Maybe Date -> Bool -> Html CommentFormMsg
commentDetails comment now isCollapsed =
    let
        submittedAgo =
            case now of
                Just now ->
                    Date.Distance.inWords comment.submittedAt now

                Nothing ->
                    ""
    in
        div
            [ css
                [ fontSize (px textSmSize)
                , color mutedTextColor
                , paddingTop (px 6)
                , marginBottom (px 6)
                ]
            ]
            [ collapseButton isCollapsed
            , linkTo CommentFormMsgNavigateTo (routeToString (UserRoute comment.user.id)) [] [ text comment.user.username ]
            , span
                [ css
                    [ fontWeight bold
                    , color defaultTextColor
                    ]
                ]
                [ text (" " ++ (toString comment.rating) ++ " points ") ]
            , span []
                [ text (submittedAgo ++ " ago") ]
            ]


commentActionButtons : CommentFormModel -> Comment -> Html CommentFormMsg
commentActionButtons model comment =
    let
        actionLink msg =
            span
                [ css
                    [ fontSize (px textSmSize)
                    , fontWeight bold
                    , color mutedTextColor
                    , paddingTop (px 8)
                    , marginBottom (px 6)
                    , marginRight (px 6)
                    , cursor pointer
                    ]
                , onClick msg
                ]

        currentUserId =
            case model.session of
                Just { id } ->
                    id

                Nothing ->
                    -1

        ownCommentActions =
            if comment.user.id == currentUserId then
                [ span []
                    [ actionLink OnEditClick [ text "Edit" ]
                    , actionLink OnDeleteClick [ text "Delete" ]
                    ]
                ]
            else
                []
    in
        span []
            [ span []
                (List.concat
                    [ [ actionLink OnReplyClick [ text "Reply" ] ]
                    , ownCommentActions
                    ]
                )
            ]


view : List CommentFormModel -> Bool -> Bool -> CommentFormModel -> Html CommentFormMsg
view allCommentModels isNested disableNesting model =
    let
        allComments =
            List.map .comment allCommentModels
    in
        div
            [ css
                [ displayFlex
                , marginTop (px (isNested ? 8 <| 20))
                , firstChild [ marginTop (px 0) ]
                ]
            ]
            [ ratingButtons model.session CommentFormMsgOnRate model.comment.id model.comment.rating model.comment.userRating True model.isCollapsed
            , div []
                [ commentDetails model.comment model.now model.isCollapsed
                , div [ css (model.isCollapsed ? [ display none ] <| []) ]
                    [ div []
                        [ div [] [ (model.showReplyForm && model.isEditMode) ? (commentForm model True) <| span [] [ text model.comment.text ] ]
                        , commentActionButtons model model.comment
                        , (model.showReplyForm && not model.isEditMode) ? (commentForm model True) <| text ""
                        , disableNesting
                            ? text ""
                          <|
                            div
                                [ css
                                    [ borderLeft3 (px 1) solid defaultBorderColor
                                    , paddingLeft (px 16)
                                    ]
                                ]
                                (List.filter (\c -> (Maybe.withDefault 0 c.parentCommentId) == model.comment.id) allComments
                                    |> List.map (\c -> view allCommentModels True disableNesting { model | comment = c })
                                )
                        ]
                    ]
                ]
            ]


commentForm : CommentFormModel -> Bool -> Html CommentFormMsg
commentForm model withCancelButton =
    let
        cancelButton =
            withCancelButton
                ? [ button
                        [ css [ marginLeft (px 10) ]
                        , type_ "button"
                        , Html.Styled.Attributes.disabled model.isLoading
                        , onClick OnReplyCancel
                        ]
                        [ text "Cancel" ]
                  ]
            <|
                []
    in
        div
            [ css
                [ marginTop (px 16)
                , marginBottom (px 16)
                ]
            ]
            [ form []
                [ textarea
                    [ css [ width (px 500), height (px 100) ]
                    , name "text"
                    , id "text"
                    , cols 1
                    , rows 1
                    , onInput OnCommentChange
                    ]
                    [ text model.commentText ]
                , div [ css [ marginTop (px 10) ] ]
                    (List.concat
                        [ [ button
                                [ type_ "submit"
                                , Html.Styled.Attributes.disabled model.isLoading
                                ]
                                [ text "Submit reply" ]
                          ]
                        , cancelButton
                        ]
                    )
                ]
            ]


type ExternalMsg
    = NoOp
    | OnAddNewComment Comment


update : CommentFormMsg -> CommentFormModel -> ( ( CommentFormModel, Cmd CommentFormMsg ), ExternalMsg )
update msg model =
    case msg of
        OnCommentChange val ->
            ( ( { model | commentText = val }, Cmd.none ), NoOp )

        OnCommentSubmit ->
            Debug.crash "TODO"

        OnReplyClick ->
            ( ( { model | showReplyForm = True, isEditMode = False, commentText = "" }, Cmd.none ), NoOp )

        OnReplyCancel ->
            ( ( { model | showReplyForm = False, isEditMode = False }, Cmd.none ), NoOp )

        OnEditClick ->
            ( ( { model | showReplyForm = True, isEditMode = True, commentText = model.comment.text }, Cmd.none ), NoOp )

        OnDeleteClick ->
            Debug.crash "TODO"

        OnCollapseClick ->
            ( ( { model | isCollapsed = not model.isCollapsed }, Cmd.none ), NoOp )

        Model.CommentFormMsgNavigateTo _ ->
            Debug.crash "TODO"

        Model.CommentFormMsgOnRate _ _ _ _ ->
            Debug.crash "TODO"
