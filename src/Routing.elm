module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (PostId, UserId, Route(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map PostsRoute top
        , map PostsRoute (s "posts")
        , map PostRoute (s "posts" </> int)
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parsePath matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


homePath : String
homePath =
    "/"


postsPath : String
postsPath =
    "/posts"


postPath : PostId -> String
postPath id =
    postsPath ++ "/" ++ (toString id)


type PostType
    = LinkPost
    | TextPost


newPostPath : PostType -> String
newPostPath postType =
    let
        postTypeValue =
            case postType of
                LinkPost ->
                    "link"

                TextPost ->
                    "text"
    in
        postsPath ++ "/new/" ++ postTypeValue


userProfilePath : UserId -> String
userProfilePath id =
    "/users/" ++ (toString id)


registerPath : String
registerPath =
    "/register"


loginPath : String
loginPath =
    "/login"
