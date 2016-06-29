module Views.Elm.Utility exposing (..)

import Dict exposing (Dict)
import Html exposing (text)
import Json.Decode as Decode
import Json.Encode as Encode


emptyElement : Html.Html msg
emptyElement =
    text ""


localizeString : String -> Dict String String -> String
localizeString key localization =
    localization
        |> Dict.get key
        |> Maybe.withDefault ""


createLocalizationDict : Encode.Value -> Dict String String
createLocalizationDict dictJson =
    Decode.decodeValue (Decode.dict Decode.string) dictJson
        |> Result.withDefault Dict.empty
