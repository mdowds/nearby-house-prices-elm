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
    ( loadingModel, getLocation )



-- UPDATE


type Msg
    = PricesReceived (Result Http.Error Model)
    | LocationUpdated (Result Geolocation.Error Geolocation.Location)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PricesReceived (Ok newModel) ->
            ( newModel, Cmd.none )

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


getLocation : Cmd Msg
getLocation =
    Task.attempt LocationUpdated Geolocation.now
