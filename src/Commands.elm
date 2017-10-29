module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Msgs exposing (Msg)
import Models exposing (PostId, Post)
import RemoteData


apiBase : String
apiBase =
    "http://localhost:4000/api"


fetchPosts : Cmd Msg
fetchPosts =
    Http.get fetchPostsUrl postsDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnfetchPosts


fetchPostsUrl : String
fetchPostsUrl =
    apiBase ++ "/posts"


savePostUrl : PostId -> String
savePostUrl postId =
    apiBase ++ "/posts/" ++ (toString postId)


savePostRequest : Post -> Http.Request Post
savePostRequest post =
    Http.request
        { body = postEncoder post |> Http.jsonBody
        , expect = Http.expectJson postDecoder
        , headers = []
        , method = "PATCH"
        , timeout = Nothing
        , url = savePostUrl post.id
        , withCredentials = False
        }


savePostCmd : Post -> Cmd Msg
savePostCmd post =
    savePostRequest post
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
