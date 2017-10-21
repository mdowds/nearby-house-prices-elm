module NearbyHousePrices exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


main =
    view model



-- MODEL


type alias Model =
    { averagePrice : String
    , numberOfTransactions : String
    , detachedAverage : String
    , flatAverage : String
    , semiDetachedAverage : String
    , terracedAverage : String
    }


model : Model
model =
    Model "Loading" "Loading" "Loading" "Loading" "Loading" "Loading"



-- VIEW


view : Model -> Html msg
view model =
    div []
        [ loadingIndicator
        , mainStatsTable model
        , typeStats model
        ]


loadingIndicator : Html msg
loadingIndicator =
    h2 [ id "location" ]
        [ span [ class "loading" ] [ text "Waiting for location..." ] ]


mainStatsTable : Model -> Html msg
mainStatsTable model =
    table [ class "main-stats" ]
        [ tr []
            [ td [] [ img [ src "img/pound.svg" ] [] ]
            , td [] [ text "Average price" ]
            , td [ class "value" ] [ text model.averagePrice ]
            ]
        , tr []
            [ td [] [ img [ src "img/houses.svg" ] [] ]
            , td [] [ text "Number of transactions" ]
            , td [ class "value" ] [ text model.numberOfTransactions ]
            ]
        ]


typeStats : Model -> Html msg
typeStats model =
    table [ class "type-stats" ]
        [ tr []
            [ td [] [ text "Average price of detached house" ]
            , td [ class "value" ] [ text model.detachedAverage ]
            ]
        , tr []
            [ td [] [ text "Average price of flat" ]
            , td [ class "value" ] [ text model.flatAverage ]
            ]
        , tr []
            [ td [] [ text "Average price of semi-detached house" ]
            , td [ class "value" ] [ text model.semiDetachedAverage ]
            ]
        , tr []
            [ td [] [ text "Average price of terraced house" ]
            , td [ class "value" ] [ text model.terracedAverage ]
            ]
        ]
