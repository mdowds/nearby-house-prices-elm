module NearbyHousePrices exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode
import Parsers exposing (..)
import Components
import Geolocation
import Task


main =
    Html.program
        { init = init
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


init =
    ( loadingModel, getLocation )



-- UPDATE


type Msg
    = PricesReceived (Result Http.Error ReceievedData)
    | LocationUpdated (Result Geolocation.Error Geolocation.Location)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PricesReceived (Ok receivedData) ->
            ( (parseToModel receivedData), Cmd.none )

        PricesReceived (Err _) ->
            ( model, Cmd.none )

        LocationUpdated (Ok location) ->
            ( model, getPrices location )

        LocationUpdated (Err _) ->
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


getPrices : Geolocation.Location -> Cmd Msg
getPrices location =
    let
        lat =
            toString location.latitude

        long =
            toString location.longitude

        url =
            "https://mdowds.com/nearbyhouseprices/api/prices/position?lat=" ++ lat ++ "&long=" ++ long

        request =
            Http.get url decodePricesData
    in
        Http.send PricesReceived request


type alias ReceievedData =
    { areaName : String
    , outcode : String
    , averagePrice : Int
    , numberOfTransactions : Int
    , detachedAverage : Maybe Int
    , flatAverage : Maybe Int
    , semiDetachedAverage : Maybe Int
    , terracedAverage : Maybe Int
    }


decodePricesData : Decode.Decoder ReceievedData
decodePricesData =
    Decode.map8
        ReceievedData
        (Decode.at [ "areaName" ] Decode.string)
        (Decode.at [ "outcode" ] Decode.string)
        (Decode.at [ "averagePrice" ] Decode.int)
        (Decode.at [ "transactionCount" ] Decode.int)
        (Decode.maybe (Decode.at [ "detachedAverage" ] Decode.int))
        (Decode.maybe (Decode.at [ "semiDetachedAverage" ] Decode.int))
        (Decode.maybe (Decode.at [ "flatAverage" ] Decode.int))
        (Decode.maybe (Decode.at [ "terracedAverage" ] Decode.int))



-- PARSERS


parseToModel : ReceievedData -> Model
parseToModel receivedData =
    let
        noDataLabel =
            "No data"
    in
        Model
            (parseTitle receivedData.areaName receivedData.outcode)
            (parseToCurrency receivedData.averagePrice)
            (toString receivedData.numberOfTransactions)
            (parseOptionalInt parseToCurrency receivedData.detachedAverage noDataLabel)
            (parseOptionalInt parseToCurrency receivedData.semiDetachedAverage noDataLabel)
            (parseOptionalInt parseToCurrency receivedData.flatAverage noDataLabel)
            (parseOptionalInt parseToCurrency receivedData.terracedAverage noDataLabel)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


getLocation : Cmd Msg
getLocation =
    Task.attempt LocationUpdated Geolocation.now
