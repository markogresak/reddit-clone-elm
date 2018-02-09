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
    Http.get (fetchPostsUrl apiBase) postsDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnfetchPosts


fetchPostsUrl : String -> String
fetchPostsUrl apiBase =
    apiBase ++ "/posts"


savePostUrl : String -> PostId -> String
savePostUrl apiBase postId =
    apiBase ++ "/posts/" ++ toString postId


savePostRequest : String -> Post -> Http.Request Post
savePostRequest apiBase post =
    Http.request
        { body = postEncoder post |> Http.jsonBody
        , expect = Http.expectJson postDecoder
        , headers = []
        , method = "PATCH"
        , timeout = Nothing
        , url = savePostUrl apiBase post.id
        , withCredentials = False
        }


savePostCmd : String -> Post -> Cmd Msg
savePostCmd apiBase post =
    savePostRequest apiBase post
        |> Http.send Msgs.OnPostSave


postsDecoder : Decode.Decoder (List Post)
postsDecoder =
    Decode.at [ "data" ] (Decode.list postDecoder)


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


userDecoder : Decode.Decoder User
userDecoder =
    decode User
        |> required "id" Decode.int
        |> required "username" Decode.string


postEncoder : Post -> Encode.Value
postEncoder post =
    let
        attributes =
            [ ( "id", Encode.int post.id )
            , ( "title", Encode.string post.title )
            ]
    in
        Encode.object attributes
