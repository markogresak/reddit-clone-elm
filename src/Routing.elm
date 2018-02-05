module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (PostId, Route(..))
import UrlParser exposing (..)
import Regex exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map PostsRoute top
        , map PostsRoute (s "posts")
        , map PostRoute (s "posts" </> int)
        ]


removeProductionPathname : String -> String
removeProductionPathname =
    replace (AtMost 1) (regex "^/reddit-clone-elm/") (\_ -> "/")


parseLocation : Location -> Route
parseLocation location =
    case (parsePath matchers { location | pathname = removeProductionPathname location.pathname }) of
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
