module Parsers exposing (..)

import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)


parseOptionalInt : (Int -> String) -> Maybe Int -> String -> String
parseOptionalInt intParser optionalInt default =
    case optionalInt of
        Just int ->
            intParser int

        Nothing ->
            default


parseToCurrency : Int -> String
parseToCurrency int =
    "£" ++ format { usLocale | decimals = 0 } (toFloat int)


parseTitle : String -> String -> String
parseTitle areaName outcode =
    areaName ++ " (" ++ outcode ++ ")"
