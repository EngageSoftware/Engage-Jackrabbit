module Views.Elm.File.Model exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Json.Encode as Encode
import Views.Elm.Ajax exposing (HttpVerb, HttpInfo)


type ThingToLoad
    = JavaScriptFile FileData
    | CssFile FileData
    | Default FileData


type alias FileData =
    { id : Maybe Int
    , pathPrefixName : String
    , filePath : String
    , provider : String
    , priority : Int
    }


type alias Model =
    { file : ThingToLoad
    , originalFile : ThingToLoad
    , editing : Bool
    , httpInfo : HttpInfo
    , localization : Dict String String
    }


fromThing : ThingToLoad -> Bool -> HttpInfo -> Dict String String -> Model
fromThing thing editing httpInfo localization =
    Model thing thing editing httpInfo localization


init : (FileData -> ThingToLoad) -> Maybe Int -> String -> String -> String -> Int -> Bool -> HttpInfo -> Dict String String -> Model
init makeThing id pathPrefixName filePath provider priority editing httpInfo localization =
    let
        file =
            FileData
                id
                pathPrefixName
                filePath
                provider
                priority

        thingToLoad =
            makeThing file
    in
        fromThing thingToLoad editing httpInfo localization


encodeFile : ThingToLoad -> Encode.Value
encodeFile thing =
    let
        file =
            getFile thing
    in
        Encode.object
            [ ( "fileType", Encode.int (fileTypeToTypeId thing) )
            , ( "pathPrefixName", Encode.string file.pathPrefixName )
            , ( "filePath", Encode.string file.filePath )
            , ( "provider", Encode.string file.provider )
            , ( "priority", Encode.int file.priority )
            ]


listFileDecoder : Decode.Decoder (List ThingToLoad)
listFileDecoder =
    Decode.list fileDecoder


fileDecoder : Decode.Decoder ThingToLoad
fileDecoder =
    decode (\makeThing id pathPrefix path provider priority -> makeThing (FileData id pathPrefix path provider priority))
        |> required "FileType" thingDecoder
        |> required "Id" (Decode.maybe Decode.int)
        |> required "PathPrefixName" Decode.string
        |> required "FilePath" Decode.string
        |> required "Provider" Decode.string
        |> required "Priority" Decode.int


typeIdToFileType : Int -> Result String (FileData -> ThingToLoad)
typeIdToFileType typeId =
    case typeId of
        0 ->
            Result.Ok (\file -> JavaScriptFile file)

        1 ->
            Result.Ok (\file -> CssFile file)

        _ ->
            Result.Err ("Invalid file type: " ++ (toString typeId))


fileTypeToTypeId : ThingToLoad -> Int
fileTypeToTypeId thing =
    case thing of
        JavaScriptFile file ->
            0

        CssFile file ->
            1

        Default file ->
            3


thingDecoder : Decode.Decoder (FileData -> ThingToLoad)
thingDecoder =
    Decode.customDecoder Decode.int typeIdToFileType


getFile : ThingToLoad -> FileData
getFile thing =
    case thing of
        JavaScriptFile file ->
            file

        CssFile file ->
            file

        Default file ->
            file


updateFile : (FileData -> FileData) -> ThingToLoad -> ThingToLoad
updateFile updater thing =
    case thing of
        JavaScriptFile file ->
            JavaScriptFile (updater file)

        CssFile file ->
            JavaScriptFile (updater file)

        Default file ->
            JavaScriptFile (updater file)


compareModels : Dict String Int -> Model -> Model -> Basics.Order
compareModels providers first second =
    let
        firstFile =
            getFile first.file

        secondFile =
            getFile second.file

        firstOriginalFile =
            getFile first.originalFile

        secondOriginalFile =
            getFile second.originalFile
    in
        case compareFiles providers firstFile secondFile of
            LT ->
                LT

            GT ->
                GT

            EQ ->
                compareFiles providers firstOriginalFile secondOriginalFile


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
