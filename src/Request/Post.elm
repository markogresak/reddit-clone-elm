module Request.Post
    exposing
        ( list
        , get
        , create
        , rate
        , updatePostRating
        , updateCommentRating
        , createComment
        )

import Http
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, optional, required, hardcoded)
import Json.Encode as Encode
import Json.Encode.Extra exposing (maybe)
import Model exposing (..)
import RemoteData
import HttpBuilder
import Util.AccessToken exposing (withAccessToken)
import Ternary exposing ((?))


list : String -> Maybe Session -> Cmd Msg
list apiBase session =
    HttpBuilder.get (postsUrl apiBase)
        |> withAccessToken session
        |> HttpBuilder.withExpect (Http.expectJson postListDecoder)
        |> HttpBuilder.toRequest
        |> RemoteData.sendRequest
        |> Cmd.map OnfetchPosts


get : String -> Maybe Session -> PostId -> Cmd Msg
get apiBase session postId =
    HttpBuilder.get (postUrl apiBase postId)
        |> withAccessToken session
        |> HttpBuilder.withExpect (Http.expectJson postItemDecoder)
        |> HttpBuilder.toRequest
        |> RemoteData.sendRequest
        |> Cmd.map OnfetchCurrentPost


create : String -> Maybe Session -> NewPostModel -> Http.Request Post
create apiBase session newPostModel =
    let
        post =
            Encode.object
                [ ( "title", Encode.string newPostModel.title )
                , ( "url", maybe Encode.string newPostModel.url )
                , ( "text", maybe Encode.string newPostModel.text )
                ]

        body =
            Encode.object [ ( "post", post ) ]
                |> Http.jsonBody
    in
        HttpBuilder.post (postsUrl apiBase)
            |> withAccessToken session
            |> HttpBuilder.withBody body
            |> HttpBuilder.withExpect (Http.expectJson (Decode.at [ "data" ] postDecoder))
            |> HttpBuilder.toRequest


rate : String -> Maybe Session -> Int -> Int -> RatingType -> Http.Request Rating
rate apiBase session id rating ratingType =
    let
        { keyName, endpoint, decoder } =
            case ratingType of
                PostRating ->
                    { keyName = "post_rating"
                    , endpoint = postUrl apiBase id
                    , decoder = postRatingDecoder
                    }

                CommentRating ->
                    { keyName = "comment_rating"
                    , endpoint = commentUrl apiBase id
                    , decoder = commentRatingDecoder
                    }

        body =
            Encode.object [ ( keyName, Encode.object [ ( "rating", Encode.int rating ) ] ) ]
    in
        HttpBuilder.put (endpoint ++ "/rate")
            |> withAccessToken session
            |> HttpBuilder.withBody (Http.jsonBody body)
            |> HttpBuilder.withExpect (Http.expectJson (Decode.at [ "data" ] decoder))
            |> HttpBuilder.toRequest


createComment : String -> Maybe Session -> CommentFormModel -> Http.Request Comment
createComment apiBase session newCommentModel =
    let
        isEdit =
            newCommentModel.isEditMode

        endpoint =
            isEdit ? (commentUrl apiBase newCommentModel.comment.id) <| (commentsUrl apiBase)

        comment =
            Encode.object
                [ ( "post_id", Encode.int newCommentModel.comment.postId )
                , ( "text", Encode.string newCommentModel.commentText )
                , ( "parent_comment_id", Encode.int newCommentModel.comment.id )
                ]

        body =
            Encode.object [ ( "comment", comment ) ]
                |> Http.jsonBody
    in
        (isEdit ? HttpBuilder.patch <| HttpBuilder.post) endpoint
            |> withAccessToken session
            |> HttpBuilder.withBody body
            |> HttpBuilder.withExpect (Http.expectJson (Decode.at [ "data" ] commentDecoder))
            |> HttpBuilder.toRequest


postsUrl : String -> String
postsUrl apiBase =
    apiBase ++ "/posts"


postUrl : String -> PostId -> String
postUrl apiBase postId =
    postsUrl apiBase ++ "/" ++ toString postId


commentsUrl : String -> String
commentsUrl apiBase =
    apiBase ++ "/comments"


commentUrl : String -> CommentId -> String
commentUrl apiBase commentId =
    commentsUrl apiBase ++ "/" ++ toString commentId


postListDecoder : Decode.Decoder (List Post)
postListDecoder =
    Decode.at [ "data" ] (Decode.list postDecoder)


postItemDecoder : Decode.Decoder Post
postItemDecoder =
    Decode.at [ "data" ] postDecoder


postDecoder : Decode.Decoder Post
postDecoder =
    decode Post
        |> required "id" Decode.int
        |> required "title" Decode.string
        |> required "url" (Decode.nullable Decode.string)
        |> optional "text" Decode.string ""
        |> required "comment_count" Decode.int
        |> required "rating" Decode.int
        |> optional "user_post_rating" Decode.int 0
        |> required "submitted_at" date
        |> required "user" postUserDecoder
        |> optional "comments" (Decode.list commentDecoder) []


postUserDecoder : Decode.Decoder User
postUserDecoder =
    decode User
        |> required "id" Decode.int
        |> required "username" Decode.string


postRatingDecoder : Decode.Decoder Rating
postRatingDecoder =
    decode Rating
        |> required "post_id" Decode.int
        |> required "post_rating" Decode.int
        |> required "rating" Decode.int
        |> hardcoded PostRating


commentRatingDecoder : Decode.Decoder Rating
commentRatingDecoder =
    decode Rating
        |> required "comment_id" Decode.int
        |> required "comment_rating" Decode.int
        |> required "rating" Decode.int
        |> hardcoded CommentRating


commentDecoder : Decode.Decoder Comment
commentDecoder =
    decode Comment
        |> required "id" Decode.int
        |> required "text" Decode.string
        |> required "submitted_at" date
        |> required "rating" Decode.int
        |> required "post_id" Decode.int
        |> required "parent_comment_id" (Decode.nullable Decode.int)
        |> optional "user_comment_rating" Decode.int 0
        |> required "user" postUserDecoder


updatePostRating : Rating -> Post -> Post
updatePostRating rating post =
    (post.id == rating.id) ? { post | rating = rating.rating, userRating = rating.userRating } <| post


updateCommentRating : Rating -> Comment -> Comment
updateCommentRating rating comment =
    (comment.id == rating.id) ? { comment | rating = rating.rating, userRating = rating.userRating } <| comment
