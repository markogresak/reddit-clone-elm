module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode
import Models exposing (..)
import Msgs exposing (Msg)
import RemoteData


fetchPosts : String -> Cmd Msg
fetchPosts apiBase =
    Http.get (postsUrl apiBase) postListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnfetchPosts


fetchPost : String -> PostId -> Cmd Msg
fetchPost apiBase postId =
    Http.get (postUrl apiBase postId) postItemDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnfetchCurrentPost


postsUrl : String -> String
postsUrl apiBase =
    apiBase ++ "/posts"


postUrl : String -> PostId -> String
postUrl apiBase postId =
    postsUrl apiBase ++ "/" ++ toString postId


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
        |> required "user" userDecoder
        |> optional "comments" (Decode.list commentDecoder) []


userDecoder : Decode.Decoder User
userDecoder =
    decode User
        |> required "id" Decode.int
        |> required "username" Decode.string


commentListDecoder : Decode.Decoder (List Comment)
commentListDecoder =
    Decode.at [ "data" ] (Decode.list commentDecoder)


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
        |> required "user" userDecoder


postEncoder : Post -> Encode.Value
postEncoder post =
    let
        attributes =
            [ ( "id", Encode.int post.id )
            , ( "title", Encode.string post.title )
            ]
    in
        Encode.object attributes
