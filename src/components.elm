module Components exposing (pageTitle, mainStatsTable, typeStatsTable)

import Html exposing (..)
import Html.Attributes exposing (..)


pageTitle : String -> Html msg
pageTitle title =
    h2 [ id "location" ]
        [ text title ]


mainStatsTable : String -> String -> Html msg
mainStatsTable averagePrice numberOfTransactions =
    table [ class "main-stats" ]
        [ mainStatsRow "pound" "Average price" averagePrice
        , mainStatsRow "houses" "Number of transactions" numberOfTransactions
        ]


mainStatsRow : String -> String -> String -> Html msg
mainStatsRow imgName label value =
    tr []
        [ td [] [ img [ src ("img/" ++ imgName ++ ".svg") ] [] ]
        , td [] [ text label ]
        , td [ class "value" ] [ text value ]
        ]


typeStatsTable : String -> String -> String -> String -> Html msg
typeStatsTable detachedAverage flatAverage semiDetachedAverage terracedAverage =
    table [ class "type-stats" ]
        [ typeStatsRow "detached house" detachedAverage
        , typeStatsRow "flat" flatAverage
        , typeStatsRow "semi-detached house" semiDetachedAverage
        , typeStatsRow "terraced house" terracedAverage
        ]


typeStatsRow : String -> String -> Html msg
typeStatsRow propertyType value =
    tr []
        [ td [] [ text ("Average price of " ++ propertyType) ]
        , td [ class "value" ] [ text value ]
        ]
