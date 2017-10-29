module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (PostId, Route(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map PostsRoute top
        , map PostRoute (s "posts" </> string)
        , map PostsRoute (s "posts")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


postsPath : String
postsPath =
    "posts"


postPath : PostId -> String
postPath id =
    postsPath ++ "/" ++ (toString id)
