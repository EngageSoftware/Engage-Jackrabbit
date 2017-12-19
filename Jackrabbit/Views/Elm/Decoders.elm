module Views.Elm.Decoders exposing (..)

import Dict exposing (..)
import Json.Decode as Json exposing (..)
import Json.Decode.Pipeline exposing (decode, required, hardcoded, custom, optional)
import Views.Elm.Model exposing (..)
import Views.Elm.File.Model as File exposing (..)


initialDataDecoder : Json.Decoder InitialData
initialDataDecoder =
    decode InitialData
        |> required "files" listFileDecoder
        |> required "httpInfo" httpDecoder
        |> required "localization" decodeLocalization
        |> required "pathAliases" listPathAliasesDecoder


listPathAliasesDecoder : Json.Decoder (List String)
listPathAliasesDecoder =
    Json.list Json.string


decodeLocalization : Json.Decoder (Dict String String)
decodeLocalization =
    Json.dict Json.string


decodeHttpHeaders : Json.Decoder (List ( String, String ))
decodeHttpHeaders =
    Json.list stringTupleDecoder


stringTupleDecoder : Json.Decoder ( String, String )
stringTupleDecoder =
    Json.map2 (,)
        (Json.index 0 Json.string)
        (Json.index 1 Json.string)


httpDecoder : Json.Decoder InitialHttpInfo
httpDecoder =
    decode InitialHttpInfo
        |> required "baseUrl" Json.string
        |> required "headers" decodeHttpHeaders


listLibraryDecoder : Json.Decoder (List Library)
listLibraryDecoder =
    Json.list libraryDecoder


libraryDecoder : Json.Decoder Library
libraryDecoder =
    decode makeLibrary
        |> required "LibraryName" Json.string
        |> required "Version" Json.string


listFileDecoder : Json.Decoder (List JackrabbitFile)
listFileDecoder =
    Json.list fileDecoder


fileDecoder : Json.Decoder JackrabbitFile
fileDecoder =
    let
        fileTypeDecoder =
            decode identity
                |> required "FileType" Json.int
    in
        fileTypeDecoder |> Json.andThen jackrabbitFileDecoder


jackrabbitFileDecoder : Int -> Json.Decoder JackrabbitFile
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
            Json.fail ("Invalid file type: " ++ (toString typeId))


fileDataDecoder : Json.Decoder FileData
fileDataDecoder =
    decode FileData
        |> required "Id" (Json.maybe Json.int)
        |> required "PathPrefixName" Json.string
        |> required "FilePath" Json.string
        |> required "Provider" Json.string
        |> required "Priority" Json.int


libraryDataDecoder : Json.Decoder LibraryData
libraryDataDecoder =
    decode LibraryData
        |> required "LibraryName" Json.string
        |> required "Version" Json.string
        |> required "Specificity" specificityDecoder


specificityDecoder : Json.Decoder Specificity
specificityDecoder =
    Json.int
        |> Json.andThen intToSpecificity


intToSpecificity : Int -> Json.Decoder Specificity
intToSpecificity versionInt =
    case versionInt of
        0 ->
            Json.succeed Latest

        1 ->
            Json.succeed LatestMajor

        2 ->
            Json.succeed LatestMinor

        3 ->
            Json.succeed Exact

        _ ->
            Json.fail ("Invalid version type: " ++ toString versionInt)


listFileDecoderandSuggestedFiles : Json.Decoder ( List JackrabbitFile, Maybe (List String) )
listFileDecoderandSuggestedFiles =
    decode (,)
        |> required "items" listFileDecoder
        |> optional "suggestions" (Json.maybe (Json.list Json.string)) Nothing
