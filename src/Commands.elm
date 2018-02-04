module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Msgs exposing (Msg)
import Models exposing (PostId, Post)
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
    apiBase ++ "/posts/" ++ (toString postId)


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
    (savePostRequest apiBase post)
        |> Http.send Msgs.OnPostSave


postsDecoder : Decode.Decoder (List Post)
postsDecoder =
    Decode.at [ "data" ] (Decode.list postDecoder)


postDecoder : Decode.Decoder Post
postDecoder =
    decode Post
        |> required "id" Decode.int
        |> required "title" Decode.string


postEncoder : Post -> Encode.Value
postEncoder post =
    let
        attributes =
            [ ( "id", Encode.int post.id )
            , ( "title", Encode.string post.title )
            ]
    in
        Encode.object attributes
