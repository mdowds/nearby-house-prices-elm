module NearbyHousePrices exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)


main =
    Html.program
        { init = init "E1"
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { areaName : String
    , averagePrice : String
    , numberOfTransactions : String
    , detachedAverage : String
    , flatAverage : String
    , semiDetachedAverage : String
    , terracedAverage : String
    }


loadingModel : Model
loadingModel =
    Model "Waiting for location..." "Loading" "Loading" "Loading" "Loading" "Loading" "Loading"


init outcode =
    ( loadingModel, getPrices outcode )



-- UPDATE


type Msg
    = ReceivedPrices (Result Http.Error Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedPrices (Ok newModel) ->
            ( newModel, Cmd.none )

        ReceivedPrices (Err _) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html msg
view model =
    div []
        [ loadingIndicator model
        , mainStatsTable model
        , typeStats model
        ]


loadingIndicator : Model -> Html msg
loadingIndicator model =
    h2 [ id "location" ]
        [ text model.areaName ]


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



-- HTTP


getPrices : String -> Cmd Msg
getPrices outcode =
    let
        url =
            "https://mdowds.com/nearbyhouseprices/api/prices/outcode/" ++ outcode

        request =
            Http.get url decodePricesData
    in
        Http.send ReceivedPrices request


decodePricesData : Decode.Decoder Model
decodePricesData =
    Decode.map8
        parseToModel
        (Decode.at [ "areaName" ] Decode.string)
        (Decode.at [ "outcode" ] Decode.string)
        (Decode.at [ "averagePrice" ] Decode.int)
        (Decode.at [ "transactionCount" ] Decode.int)
        (Decode.maybe (Decode.at [ "detachedAverage" ] Decode.int))
        (Decode.maybe (Decode.at [ "semiDetachedAverage" ] Decode.int))
        (Decode.maybe (Decode.at [ "flatAverage" ] Decode.int))
        (Decode.maybe (Decode.at [ "terracedAverage" ] Decode.int))



-- PARSERS


parseToModel : String -> String -> Int -> Int -> Maybe Int -> Maybe Int -> Maybe Int -> Maybe Int -> Model
parseToModel areaName outcode averagePrice numberOfTransactions detachedAverage semiDetachedAverage flatAverage terracedAverage =
    Model
        (parseTitle areaName outcode)
        (parseToCurrency averagePrice)
        (toString numberOfTransactions)
        (parseOptionalInt detachedAverage)
        (parseOptionalInt semiDetachedAverage)
        (parseOptionalInt flatAverage)
        (parseOptionalInt terracedAverage)


parseOptionalInt : Maybe Int -> String
parseOptionalInt optionalInt =
    case optionalInt of
        Just int ->
            parseToCurrency int

        Nothing ->
            "No data"


parseToCurrency : Int -> String
parseToCurrency int =
    "£" ++ format { usLocale | decimals = 0 } (toFloat int)


parseTitle : String -> String -> String
parseTitle areaName outcode =
    areaName ++ " (" ++ outcode ++ ")"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
