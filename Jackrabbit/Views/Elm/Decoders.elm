module Views.Elm.Decoders exposing (..)

import Dict exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, hardcoded, custom, optional)
import Views.Elm.Model exposing (..)
import Views.Elm.File.Model as File exposing (..)


initialDataDecoder : Decode.Decoder InitialData
initialDataDecoder =
    decode InitialData
        |> required "files" listFileDecoder
        |> required "httpInfo" httpDecoder
        |> required "localization" decodeLocalization
        |> required "pathAliases" listPathAliasesDecoder


listPathAliasesDecoder : Decode.Decoder (List String)
listPathAliasesDecoder =
    Decode.list Decode.string


decodeLocalization : Decode.Decoder (Dict String String)
decodeLocalization =
    Decode.dict Decode.string


decodeHttpHeaders : Decode.Decoder (List ( String, String ))
decodeHttpHeaders =
    Decode.list stringTupleDecoder


stringTupleDecoder : Decode.Decoder ( String, String )
stringTupleDecoder =
    Decode.tuple2 (,) Decode.string Decode.string


httpDecoder : Decode.Decoder InitialHttpInfo
httpDecoder =
    decode InitialHttpInfo
        |> required "baseUrl" Decode.string
        |> required "headers" decodeHttpHeaders


listLibraryDecoder : Decode.Decoder (List Library)
listLibraryDecoder =
    Decode.list libraryDecoder


libraryDecoder : Decode.Decoder Library
libraryDecoder =
    decode makeLibrary
        |> required "LibraryName" Decode.string
        |> required "Version" Decode.string


listFileDecoder : Decode.Decoder (List JackrabbitFile)
listFileDecoder =
    Decode.list fileDecoder


fileDecoder : Decode.Decoder JackrabbitFile
fileDecoder =
    let
        fileTypeDecoder =
            decode identity
                |> required "FileType" Decode.int
    in
        fileTypeDecoder |> Decode.andThen jackrabbitFileDecoder


jackrabbitFileDecoder : Int -> Decode.Decoder JackrabbitFile
jackrabbitFileDecoder typeId =
    case typeId of
        0 ->
            decode JavaScriptFile
                |> custom fileDataDecoder

        1 ->
            decode CssFile
                |> custom fileDataDecoder

        2 ->
            decode JavaScriptLibrary
                |> custom fileDataDecoder
                |> custom libraryDataDecoder

        _ ->
            Decode.fail ("Invalid file type: " ++ (toString typeId))


fileDataDecoder : Decode.Decoder FileData
fileDataDecoder =
    decode FileData
        |> required "Id" (Decode.maybe Decode.int)
        |> required "PathPrefixName" Decode.string
        |> required "FilePath" Decode.string
        |> required "Provider" Decode.string
        |> required "Priority" Decode.int


libraryDataDecoder : Decode.Decoder LibraryData
libraryDataDecoder =
    decode LibraryData
        |> required "LibraryName" Decode.string
        |> required "Version" Decode.string
        |> required "Specificity" specificityDecoder


specificityDecoder : Decode.Decoder Specificity
specificityDecoder =
    Decode.customDecoder Decode.int intToSpecificity


listFileDecoderandSuggestedFiles : Decode.Decoder ( List JackrabbitFile, Maybe (List String) )
listFileDecoderandSuggestedFiles =
    decode (,)
        |> required "items" listFileDecoder
        |> optional "suggestions" (Decode.maybe (Decode.list Decode.string)) Nothing
