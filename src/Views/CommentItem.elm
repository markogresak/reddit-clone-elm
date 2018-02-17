module Views.CommentItem exposing (initialModel, view, update, commentForm, ExternalMsg(..), mapCommentMsg)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, name, id, cols, rows, value, type_)
import Html.Styled.Events exposing (onClick, onInput, onSubmit)
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
import Request.Post
import Http
import Util.Ports as Ports


initialModel : Model -> Comment -> CommentFormModel
initialModel model comment =
    { commentText = ""
    , showReplyForm = False
    , isEditMode = False
    , isCollapsed = False
    , isConfirmMode = False
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
                , marginBottom (px 4)
                ]
            ]
            [ collapseButton isCollapsed
            , linkTo CommentFormMsgNavigateTo (routeToString (UserRoute comment.user.id (userTabTypeToString PostsTab))) [] [ text comment.user.username ]
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


commentActionButtons : CommentFormModel -> Comment -> Bool -> Html CommentFormMsg
commentActionButtons model comment areHidden =
    let
        actionLink msg =
            span
                [ css
                    [ fontSize (px textSmSize)
                    , fontWeight bold
                    , color mutedTextColor
                    , paddingTop (px 8)
                    , marginBottom (px 4)
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
        areHidden
            ? text ""
        <|
            span []
                [ span []
                    (List.concat
                        [ [ actionLink OnReplyClick [ text "Reply" ] ]
                        , ownCommentActions
                        ]
                    )
                ]


mapCommentMsg : CommentId -> Html CommentFormMsg -> Html Msg
mapCommentMsg id =
    Html.Styled.map (OnCommentFormMsg id)


view : List CommentFormModel -> Bool -> Bool -> Bool -> CommentFormModel -> Html Msg
view allCommentModels isNested disableNesting hideButtons model =
    let
        mapMsg =
            mapCommentMsg model.comment.id

        areActionButtonsHidden =
            model.session == Nothing || model.showReplyForm || hideButtons
    in
        div
            [ css
                [ displayFlex
                , marginTop (px (isNested ? 8 <| 20))
                , firstChild [ marginTop (px 0) ]
                ]
            ]
            [ (ratingButtons model.session CommentFormMsgOnRate model.comment.id model.comment.rating model.comment.userRating True model.isCollapsed) |> mapMsg
            , div []
                [ (commentDetails model.comment model.now model.isCollapsed) |> mapMsg
                , div [ css (model.isCollapsed ? [ display none ] <| []) ]
                    [ div []
                        [ (div []
                            [ (model.showReplyForm && model.isEditMode) ? (commentForm model True) <| span [] [ text model.comment.text ] ]
                          )
                            |> mapMsg
                        , (commentActionButtons model model.comment areActionButtonsHidden) |> mapMsg
                        , (model.showReplyForm && not model.isEditMode) ? ((commentForm model True) |> mapMsg) <| text ""
                        , disableNesting
                            ? text ""
                          <|
                            div
                                [ css
                                    [ borderLeft3 (px 1) solid defaultBorderColor
                                    , paddingLeft (px 16)
                                    ]
                                ]
                                (List.filter (\m -> (Maybe.withDefault 0 m.comment.parentCommentId) == model.comment.id) allCommentModels
                                    |> List.map (view allCommentModels True disableNesting hideButtons)
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
            [ form [ onSubmit OnCommentSubmit ]
                [ textarea
                    [ css [ maxWidth (pct 100), width (px 500), height (px 100) ]
                    , name "text"
                    , id "text"
                    , cols 1
                    , rows 1
                    , value model.commentText
                    , onInput OnCommentChange
                    ]
                    []
                , div [ css [ marginTop (px 10) ] ]
                    (List.concat
                        [ [ button
                                [ type_ "submit"
                                , Html.Styled.Attributes.disabled model.isLoading
                                ]
                                [ text (model.isEditMode ? "Edit comment" <| "Submit reply") ]
                          ]
                        , cancelButton
                        ]
                    )
                ]
            ]


type ExternalMsg
    = NoOp
    | OnAddNewComment Comment
    | OnEditComment Comment
    | OnDeleteComment CommentId
    | CommentFormNavigateTo String
    | CommentFormOnRate RatingType VoteId Bool Int


update : CommentFormMsg -> CommentFormModel -> ( ( CommentFormModel, Cmd CommentFormMsg ), ExternalMsg )
update msg model =
    case msg of
        OnCommentChange val ->
            ( ( { model | commentText = val }, Cmd.none ), NoOp )

        OnReplyClick ->
            ( ( { model | showReplyForm = True, isEditMode = False, commentText = "" }, Cmd.none ), NoOp )

        OnReplyCancel ->
            ( ( { model | showReplyForm = False, isEditMode = False }, Cmd.none ), NoOp )

        OnEditClick ->
            ( ( { model | showReplyForm = True, isEditMode = True, commentText = model.comment.text }, Cmd.none ), NoOp )

        OnCollapseClick ->
            ( ( { model | isCollapsed = not model.isCollapsed }, Cmd.none ), NoOp )

        Model.CommentFormMsgNavigateTo route ->
            ( ( model, Cmd.none ), CommentFormNavigateTo route )

        Model.CommentFormMsgOnRate ratingType id isDownButton userRating ->
            ( ( model, Cmd.none ), CommentFormOnRate ratingType id isDownButton userRating )

        OnCommentSubmit ->
            ( ( { model | isLoading = True }
              , Http.send OnCommentSubmitCompleted (Request.Post.createComment model.apiBase model.session model)
              )
            , NoOp
            )

        OnCommentSubmitCompleted (Err error) ->
            let
                errorMessages =
                    [ "An error occured while trying to create a new post." ]
            in
                ( ( { model | errors = errorMessages, isLoading = False }, Cmd.none ), NoOp )

        OnCommentSubmitCompleted (Ok newComment) ->
            ( ( { model | errors = [], isLoading = False, showReplyForm = False, isEditMode = False, commentText = "" }, Cmd.none )
            , (model.isEditMode ? OnEditComment <| OnAddNewComment) newComment
            )

        OnDeleteClick ->
            ( ( { model | isConfirmMode = True }, Ports.confirm "Are you sure you wish to delete this comment?" ), NoOp )

        OnDeleteConfirm result ->
            let
                nextModel =
                    { model | isConfirmMode = False }
            in
                case result of
                    True ->
                        ( ( nextModel
                          , Http.send OnCommentDeleteCompleted (Request.Post.deleteComment model.apiBase model.session model)
                          )
                        , NoOp
                        )

                    False ->
                        ( ( nextModel, Cmd.none ), NoOp )

        OnCommentDeleteCompleted (Err _) ->
            ( ( model, Cmd.none ), NoOp )

        OnCommentDeleteCompleted (Ok _) ->
            ( ( model, Cmd.none ), OnDeleteComment model.comment.id )
