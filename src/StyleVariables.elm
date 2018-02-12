module StyleVariables exposing (..)

import Css exposing (hex)
import Ternary exposing ((?))


defaultTextColor : Css.Color
defaultTextColor =
    hex "111"


voteDefaultColor : Css.Color
voteDefaultColor =
    hex "C6C6C6"


voteUpColor : Css.Color
voteUpColor =
    hex "FF8B60"


voteDownColor : Css.Color
voteDownColor =
    hex "9494FF"


mutedTextColor : Css.Color
mutedTextColor =
    hex "888"


linkColor : Css.Color
linkColor =
    hex "0074D9"


textBlockBackground : Css.Color
textBlockBackground =
    hex "f7f7f7"


textBlockBorder : Css.Color
textBlockBorder =
    hex "DDD"


dangerColor : Css.Color
dangerColor =
    hex "e53935"


successColor : Css.Color
successColor =
    hex "7CB342"


defaultBorderColor : Css.Color
defaultBorderColor =
    hex "E0E0E0"


ratingColor : Int -> Css.Color
ratingColor userRating =
    if userRating > 0 then
        voteUpColor
    else if userRating < 0 then
        voteDownColor
    else
        voteDefaultColor


voteButtonColor : Bool -> Int -> Css.Color
voteButtonColor isDownButton userRating =
    case userRating of
        0 ->
            voteDefaultColor

        _ ->
            isDownButton ? voteDownColor <| voteUpColor


textSmSize : Float
textSmSize =
    12


textXsSize : Float
textXsSize =
    10


postsListSpacing : Float
postsListSpacing =
    20


postHeight : Float
postHeight =
    50


postSpacing : Float
postSpacing =
    15


ratingButtonsWidth : Float
ratingButtonsWidth =
    50


ratingButtonsTextSpacing : Float
ratingButtonsTextSpacing =
    6


contentWidth : Float
contentWidth =
    960


menuHeight : Float
menuHeight =
    40


authFormWidth : Float
authFormWidth =
    220


authInputMarginBottom : Float
authInputMarginBottom =
    12
