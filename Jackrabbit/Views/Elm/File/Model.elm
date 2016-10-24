module Views.Elm.File.Model exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Json.Encode as Encode
import Views.Elm.Ajax exposing (HttpVerb, HttpInfo)


type JackRabbitFile
    = JavaScriptFile FileData
    | JavaScriptLib FileData LibraryData
    | CssFile FileData
    | Default FileData


type alias LibraryData =
    { libraryName : String
    , version : String
    , versionSpecificity : Specificity
    }


type Specificity
    = Exact
    | LatestMinor
    | LatestMajor
    | Latest


type alias FileData =
    { id : Maybe Int
    , pathPrefixName : String
    , filePath : String
    , provider : String
    , priority : Int
    }


type alias Model =
    { file : JackRabbitFile
    , originalFile : JackRabbitFile
    , editing : Bool
    , httpInfo : HttpInfo
    , localization : Dict String String
    }


fromJRFile : JackRabbitFile -> Bool -> HttpInfo -> Dict String String -> Model
fromJRFile file editing httpInfo localization =
    Model file file editing httpInfo localization


init : (FileData -> JackRabbitFile) -> Maybe Int -> String -> String -> String -> Int -> Bool -> HttpInfo -> Dict String String -> Model
init makeJRFile id pathPrefixName filePath provider priority editing httpInfo localization =
    let
        fileData =
            FileData
                id
                pathPrefixName
                filePath
                provider
                priority

        jackRabbitFile =
            makeJRFile fileData
    in
        fromJRFile jackRabbitFile editing httpInfo localization


encodeFile : JackRabbitFile -> Encode.Value
encodeFile file =
    let
        typeId =
            fileTypeToTypeId file

        fileData =
            getFile file
    in
        if typeId == 2 then
            let
                libFile =
                    getLibrary file
            in
                Encode.object
                    [ ( "fileType", Encode.int (fileTypeToTypeId file) )
                    , ( "libraryName", Encode.string libFile.libraryName )
                    , ( "version", Encode.string libFile.version )
                    , ( "specificity", Encode.int (specificityToTypeId libFile.versionSpecificity) )
                    ]
        else
            Encode.object
                [ ( "fileType", Encode.int (fileTypeToTypeId file) )
                , ( "pathPrefixName", Encode.string file.pathPrefixName )
                , ( "filePath", Encode.string file.filePath )
                , ( "provider", Encode.string file.provider )
                , ( "priority", Encode.int file.priority )
                ]


listFileDecoder : Decode.Decoder (List JackRabbitFile)
listFileDecoder =
    Decode.list fileDecoder


fileDecoder : Decode.Decoder JackRabbitFile
fileDecoder =
    let
        fileTypeDecoder =
            decode identity
                |> required "FileType" Decode.int
    in
        fileTypeDecoder `Decode.andThen` jackRabbitFileDecoder


jackRabbitFileDecoder : Int -> Decode.Decoder JackRabbitFile
jackRabbitFileDecoder typeId =
    case typeId of
        0 ->
            decode (\id pathPrefix path provider priority -> JavaScriptFile (FileData id pathPrefix path provider priority))
                |> required "Id" (Decode.maybe Decode.int)
                |> required "PathPrefixName" Decode.string
                |> required "FilePath" Decode.string
                |> required "Provider" Decode.string
                |> required "Priority" Decode.int

        1 ->
            decode (\id pathPrefix path provider priority -> CssFile (FileData id pathPrefix path provider priority))
                |> required "Id" (Decode.maybe Decode.int)
                |> required "PathPrefixName" Decode.string
                |> required "FilePath" Decode.string
                |> required "Provider" Decode.string
                |> required "Priority" Decode.int

        2 ->
            decode (\id pathPrefix path provider priority libraryName version versionSpecificity -> JavaScriptLib (FileData id pathPrefix path provider priority) (LibraryData libraryName version versionSpecificity))
                |> required "Id" (Decode.maybe Decode.int)
                |> required "PathPrefixName" Decode.string
                |> required "FilePath" Decode.string
                |> required "Provider" Decode.string
                |> required "Priority" Decode.int
                |> required "LibraryName" Decode.string
                |> required "Version" Decode.string
                |> required "VersionSpecificity" versionDecoder

        _ ->
            Decode.fail ("Invalid file type: " ++ (toString typeId))


versionDecoder : Decode.Decoder Specificity
versionDecoder =
    Decode.customDecoder Decode.int intToVersionSpecificity


specificityToTypeId : Specificity -> Int
specificityToTypeId specificity =
    case specificity of
        Exact ->
            0

        LatestMinor ->
            1

        LatestMajor ->
            2

        Latest ->
            3


intToVersionSpecificity : Int -> Result String Specificity
intToVersionSpecificity versionInt =
    case versionInt of
        0 ->
            Result.Ok Exact

        1 ->
            Result.Ok LatestMinor

        2 ->
            Result.Ok LatestMajor

        3 ->
            Result.Ok Latest

        _ ->
            Result.Err ("Invalid version type: " ++ (toString versionInt))


fileTypeToTypeId : JackRabbitFile -> Int
fileTypeToTypeId file =
    case file of
        JavaScriptFile fileData ->
            0

        CssFile fileData ->
            1

        JavaScriptLib fileData libFile ->
            2

        Default fileData ->
            3


getFile : JackRabbitFile -> FileData
getFile file =
    case file of
        JavaScriptFile fileData ->
            fileData

        CssFile fileData ->
            fileData

        JavaScriptLib fileData libFile ->
            fileData

        Default fileData ->
            fileData


getLibrary : JackRabbitFile -> LibraryData
getLibrary file =
    case file of
        JavaScriptLib fileData libFile ->
            libFile

        _ ->
            Debug.crash "Impossible state achieved"


updateFile : (FileData -> FileData) -> JackRabbitFile -> JackRabbitFile
updateFile updater file =
    case file of
        JavaScriptFile fileData ->
            JavaScriptFile (updater fileData)

        CssFile fileData ->
            CssFile (updater fileData)

        JavaScriptLib fileData libFile ->
            JavaScriptLib (updater fileData) libFile

        Default fileData ->
            Default (updater fileData)


updateLibrary : (LibraryData -> LibraryData) -> JackRabbitFile -> JackRabbitFile
updateLibrary updater file =
    case file of
        JavaScriptLib fileData libFile ->
            JavaScriptLib fileData (updater libFile)

        _ ->
            file


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
