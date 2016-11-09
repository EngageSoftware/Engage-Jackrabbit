module Views.Elm.File.Model exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, hardcoded, custom)
import Json.Encode as Encode
import Views.Elm.Ajax exposing (HttpVerb, HttpInfo)
import Autocomplete


type JackrabbitFile
    = JavaScriptFile FileData
    | JavaScriptLibrary FileData LibraryData
    | CssFile FileData


type alias LibraryData =
    { libraryName : String
    , version : String
    , specificity : Specificity
    }


type Specificity
    = Latest
    | LatestMajor
    | LatestMinor
    | Exact


type alias FileData =
    { id : Maybe Int
    , pathPrefixName : String
    , filePath : String
    , provider : String
    , priority : Int
    }


type alias Autocomplete =
    { autoState : Autocomplete.State
    , query : String
    , libraries : List Library
    , howManyToShow : Int
    , showMenu : Bool
    , selectedLibrary : Maybe Library
    }


type alias Library =
    { libName : String
    , version : String
    , name : String
    }


type alias Model =
    { file : JackrabbitFile
    , originalFile : JackrabbitFile
    , editing : Bool
    , httpInfo : HttpInfo
    , localization : Dict String String
    , autocomplete : Autocomplete
    , pathList : List String
    , providers : List String
    , choosingType : Bool
    , deleted : Bool
    }


initialAutocomplete : Autocomplete
initialAutocomplete =
    { autoState = Autocomplete.empty
    , query = ""
    , libraries = []
    , howManyToShow = 5
    , showMenu = False
    , selectedLibrary = Nothing
    }


fromJackrabbitFile : JackrabbitFile -> Bool -> HttpInfo -> Dict String String -> Autocomplete -> List String -> List String -> Bool -> Model
fromJackrabbitFile file editing httpInfo localization autocomplete pathList providers choosingType =
    Model file file editing httpInfo localization autocomplete pathList providers choosingType False


init : (FileData -> JackrabbitFile) -> Maybe Int -> String -> String -> String -> Int -> Bool -> HttpInfo -> Dict String String -> List String -> List String -> Bool -> Model
init makeJackrabbitFile id pathPrefixName filePath provider priority editing httpInfo localization pathList providers choosingType =
    let
        fileData =
            FileData
                id
                pathPrefixName
                filePath
                provider
                priority

        jackrabbitFile =
            makeJackrabbitFile fileData
    in
        fromJackrabbitFile jackrabbitFile editing httpInfo localization initialAutocomplete pathList providers choosingType


makeLibrary : String -> String -> Library
makeLibrary libName version =
    let
        name =
            libName ++ " " ++ version
    in
        Library libName version name


listLibraryDecoder : Decode.Decoder (List Library)
listLibraryDecoder =
    Decode.list libraryDecoder


libraryDecoder : Decode.Decoder Library
libraryDecoder =
    decode makeLibrary
        |> required "LibraryName" Decode.string
        |> required "Version" Decode.string


encodeFile : JackrabbitFile -> Encode.Value
encodeFile file =
    case file of
        JavaScriptLibrary fileData libraryData ->
            Encode.object
                [ ( "fileType", Encode.int (fileTypeToTypeId file) )
                , ( "libraryName", Encode.string libraryData.libraryName )
                , ( "version", Encode.string libraryData.version )
                , ( "specificity", Encode.int (specificityToTypeId libraryData.specificity) )
                ]

        CssFile fileData ->
            encodeFileData fileData (fileTypeToTypeId file)

        JavaScriptFile fileData ->
            encodeFileData fileData (fileTypeToTypeId file)


encodeFileData : FileData -> Int -> Encode.Value
encodeFileData fileData fileType =
    Encode.object
        [ ( "fileType", Encode.int fileType )
        , ( "pathPrefixName", Encode.string fileData.pathPrefixName )
        , ( "filePath", Encode.string fileData.filePath )
        , ( "provider", Encode.string fileData.provider )
        , ( "priority", Encode.int fileData.priority )
        ]


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
        fileTypeDecoder `Decode.andThen` jackrabbitFileDecoder


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


specificityToTypeId : Specificity -> Int
specificityToTypeId specificity =
    case specificity of
        Latest ->
            0

        LatestMajor ->
            1

        LatestMinor ->
            2

        Exact ->
            3


intToSpecificity : Int -> Result String Specificity
intToSpecificity versionInt =
    case versionInt of
        0 ->
            Result.Ok Latest

        1 ->
            Result.Ok LatestMajor

        2 ->
            Result.Ok LatestMinor

        3 ->
            Result.Ok Exact

        _ ->
            Result.Err ("Invalid version type: " ++ (toString versionInt))


fileTypeToTypeId : JackrabbitFile -> Int
fileTypeToTypeId file =
    case file of
        JavaScriptFile fileData ->
            0

        CssFile fileData ->
            1

        JavaScriptLibrary fileData libraryData ->
            2


getFile : JackrabbitFile -> FileData
getFile file =
    case file of
        JavaScriptFile fileData ->
            fileData

        CssFile fileData ->
            fileData

        JavaScriptLibrary fileData libraryData ->
            fileData


updateFile : (FileData -> FileData) -> JackrabbitFile -> JackrabbitFile
updateFile updater file =
    case file of
        JavaScriptFile fileData ->
            JavaScriptFile (updater fileData)

        CssFile fileData ->
            CssFile (updater fileData)

        JavaScriptLibrary fileData libraryData ->
            JavaScriptLibrary (updater fileData) libraryData


updateLibrary : (LibraryData -> LibraryData) -> JackrabbitFile -> JackrabbitFile
updateLibrary updater file =
    case file of
        JavaScriptLibrary fileData libraryData ->
            JavaScriptLibrary fileData (updater libraryData)

        _ ->
            file


compareModels : Model -> Model -> Basics.Order
compareModels first second =
    let
        firstOriginalFile =
            first.originalFile

        secondOriginalFile =
            second.originalFile
    in
        case compareFiles first.file second.file of
            LT ->
                LT

            GT ->
                GT

            EQ ->
                compareFiles firstOriginalFile secondOriginalFile


compareFiles : JackrabbitFile -> JackrabbitFile -> Basics.Order
compareFiles first second =
    let
        firstTypeId =
            fileTypeToOrderedNumber first

        secondTypeId =
            fileTypeToOrderedNumber second

        firstFile =
            getFile first

        secondFile =
            getFile second
    in
        case compare firstTypeId secondTypeId of
            LT ->
                LT

            GT ->
                GT

            EQ ->
                case compare firstFile.priority secondFile.priority of
                    LT ->
                        LT

                    GT ->
                        GT

                    EQ ->
                        compare firstFile.filePath secondFile.filePath


fileTypeToOrderedNumber : JackrabbitFile -> Int
fileTypeToOrderedNumber file =
    case file of
        JavaScriptFile fileData ->
            1

        CssFile fileData ->
            0

        JavaScriptLibrary fileData libraryData ->
            2
