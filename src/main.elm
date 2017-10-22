module NearbyHousePrices exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode
import Parsers exposing (..)
import Components


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
        [ Components.pageTitle model.areaName
        , Components.mainStatsTable model.averagePrice model.numberOfTransactions
        , Components.typeStatsTable model.detachedAverage model.flatAverage model.semiDetachedAverage model.terracedAverage
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
    let
        noDataLabel =
            "No data"
    in
        Model
            (parseTitle areaName outcode)
            (parseToCurrency averagePrice)
            (toString numberOfTransactions)
            (parseOptionalInt parseToCurrency detachedAverage noDataLabel)
            (parseOptionalInt parseToCurrency semiDetachedAverage noDataLabel)
            (parseOptionalInt parseToCurrency flatAverage noDataLabel)
            (parseOptionalInt parseToCurrency terracedAverage noDataLabel)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
