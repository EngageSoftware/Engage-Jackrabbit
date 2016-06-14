module Views.Elm.Utility exposing (..)

import Dict exposing (Dict)
import Html exposing (text)
import Json.Decode as Decode
import Json.Encode as Encode


{-| Based on https://github.com/elm-lang/core/blob/15622175428772e98b84671c5ec0e98f8de4e2b7/src/List.elm#L418-L428

    unzip [(0, True, "a"), (17, False, "b"), (1337, True, "c")] == ([0,17,1337], [True,False,True], ["a","b","c"])
-}
unzip3 : List ( a, b, c ) -> ( List a, List b, List c )
unzip3 tuples =
    let
        step ( x, y, z ) ( xs, ys, zs ) =
            ( x :: xs, y :: ys, z :: zs )
    in
        List.foldr step ( [], [], [] ) tuples


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
