module Request.Post exposing (list, get, create)

import Http
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode
import Json.Encode.Extra exposing (maybe)
import Model exposing (..)
import RemoteData
import HttpBuilder
import Util.AccessToken exposing (withAccessToken)


list : String -> Cmd Msg
list apiBase =
    Http.get (postsUrl apiBase) postListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map OnfetchPosts


get : String -> PostId -> Cmd Msg
get apiBase postId =
    Http.get (postUrl apiBase postId) postItemDecoder
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
        postsUrl apiBase
            |> HttpBuilder.post
            |> withAccessToken session
            |> HttpBuilder.withBody body
            |> HttpBuilder.withExpect (Http.expectJson (Decode.at [ "data" ] postDecoder))
            |> HttpBuilder.toRequest


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
        |> required "user" postUserDecoder
        |> optional "comments" (Decode.list commentDecoder) []


postUserDecoder : Decode.Decoder User
postUserDecoder =
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
        |> required "user" postUserDecoder
