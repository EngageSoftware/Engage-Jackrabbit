module Views.Elm.File.Model exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Json.Encode as Encode
import Views.Elm.Ajax exposing (HttpVerb, HttpInfo)


type FileType
    = JavaScript
    | CSS
    | Default


type alias FileData =
    { fileType : FileType
    , id : Maybe Int
    , pathPrefixName : String
    , filePath : String
    , provider : String
    , priority : Int
    }


type alias Model =
    { file : FileData
    , originalFile : FileData
    , editing : Bool
    , httpInfo : HttpInfo
    , localization : Dict String String
    }


init : FileType -> Maybe Int -> String -> String -> String -> Int -> Bool -> HttpInfo -> Dict String String -> Model
init fileType id pathPrefixName filePath provider priority editing httpInfo localization =
    let
        file =
            FileData fileType
                id
                pathPrefixName
                filePath
                provider
                priority
    in
        Model file
            file
            editing
            httpInfo
            localization


encodeFile : FileData -> Encode.Value
encodeFile file =
    Encode.object
        [ ( "fileType", Encode.string (toString file.fileType) )
        , ( "pathPrefixName", Encode.string file.pathPrefixName )
        , ( "filePath", Encode.string file.filePath )
        , ( "provider", Encode.string file.provider )
        , ( "priority", Encode.int file.priority )
        ]


listFileDecoder : Decode.Decoder (List FileData)
listFileDecoder =
    Decode.list fileDecoder


fileDecoder : Decode.Decoder FileData
fileDecoder =
    decode FileData
        |> required "FileType" fileTypeDecoder
        |> required "Id" (Decode.maybe Decode.int)
        |> required "PathPrefixName" Decode.string
        |> required "FilePath" Decode.string
        |> required "Provider" Decode.string
        |> required "Priority" Decode.int


typeIdToFileType : Int -> Result String FileType
typeIdToFileType typeId =
    case typeId of
        0 ->
            Result.Ok JavaScript

        1 ->
            Result.Ok CSS

        _ ->
            Result.Err ("Invalid file type: " ++ (toString typeId))


fileTypeDecoder : Decode.Decoder FileType
fileTypeDecoder =
    Decode.customDecoder Decode.int typeIdToFileType


compareModels : Dict String Int -> Model -> Model -> Basics.Order
compareModels providers first second =
    case compareFiles providers first.file second.file of
        LT ->
            LT

        GT ->
            GT

        EQ ->
            compareFiles providers first.originalFile second.originalFile


compareFiles : Dict String Int -> FileData -> FileData -> Basics.Order
compareFiles providers first second =
    let
        firstProviderOrder =
            providers |> Dict.get first.provider |> Maybe.withDefault 0

        secondProviderOrder =
            providers |> Dict.get second.provider |> Maybe.withDefault 0
    in
        case compare firstProviderOrder secondProviderOrder of
            LT ->
                LT

            GT ->
                GT

            EQ ->
                case compare first.priority second.priority of
                    LT ->
                        LT

                    GT ->
                        GT

                    EQ ->
                        compare first.filePath second.filePath
