module Route exposing (..)

import Model exposing (..)
import Browser.Navigation as Nav
import Url
import Url.Parser exposing (Parser, (</>), int, map, oneOf, s, string, top, parse)


postTypeToString : PostType -> String
postTypeToString postType =
    case postType of
        LinkPost ->
            "link"

        TextPost ->
            "text"

        UnknownPost ->
            ""


stringToPostType : String -> PostType
stringToPostType postTypeName =
    case postTypeName of
        "link" ->
            LinkPost

        "text" ->
            TextPost

        _ ->
            UnknownPost


userTabTypeToString : UserTabType -> String
userTabTypeToString userTabType =
    case userTabType of
        PostsTab ->
            "posts"

        CommentsTab ->
            "comments"

        UnknownTab ->
            ""


stringToUserTabType : String -> UserTabType
stringToUserTabType userTabTypeName =
    case userTabTypeName of
        "posts" ->
            PostsTab

        "comments" ->
            CommentsTab

        _ ->
            UnknownTab


routeToString : Route -> String
routeToString route =
    case route of
        PostsRoute ->
            "/"

        PostRoute postId ->
            "/posts/" ++ String.fromInt postId

        NewPostRoute postType ->
            "/posts/new/" ++ postType

        UserRoute userId tab ->
            "/users/" ++ String.fromInt userId ++ "/" ++ tab

        LoginRoute ->
            "/login"

        LogoutRoute ->
            "/logout"

        RegisterRoute ->
            "/register"

        NotFoundRoute ->
            "/not-found"


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map PostsRoute top
        , map NewPostRoute (s "posts" </> s "new" </> string)
        , map PostRoute (s "posts" </> int)
        , map UserRoute (s "users" </> int </> string)
        , map LoginRoute (s "login")
        , map LogoutRoute (s "logout")
        , map RegisterRoute (s "register")
        ]


parseLocation : Url.Url -> Route
parseLocation location =
    Maybe.withDefault NotFoundRoute (parse matchers location)


modifyUrl : Nav.Key -> Route -> Cmd msg
modifyUrl key route =
    Nav.pushUrl key (routeToString route)