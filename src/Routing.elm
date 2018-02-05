module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (PostId, Route(..))
import UrlParser exposing (..)


matchers : String -> Parser (Route -> a) a
matchers locationPrefix =
    oneOf
        [ map PostsRoute top
        , map PostRoute (s (locationPrefix ++ "posts") </> string)
        , map PostsRoute (s (locationPrefix ++ "posts"))
        ]


parseLocation : String -> Location -> Route
parseLocation locationPrefix location =
    case (parsePath (matchers locationPrefix) location) of
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
