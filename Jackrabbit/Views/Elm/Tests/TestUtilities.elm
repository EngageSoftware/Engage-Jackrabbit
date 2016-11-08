module Views.Elm.Tests.TestUtilities exposing (..)

import Test exposing (..)
import Fuzz as Fuzz
import Json.Encode as Json
import Views.Elm.File.Model exposing (..)
import Views.Elm.Ajax exposing (HttpInfo)
import List exposing (..)
import Dict exposing (Dict)
import Autocomplete


encodeMaybe : (a -> Json.Value) -> Maybe a -> Json.Value
encodeMaybe encoder value =
    case value of
        Nothing ->
            Json.null

        Just actualValue ->
            encoder actualValue


versionFuzzer : Fuzz.Fuzzer String
versionFuzzer =
    Fuzz.tuple3 ( (Fuzz.intRange 0 99), (Fuzz.intRange 0 32767), (Fuzz.intRange 0 32767) )
        |> Fuzz.map (\( major, minor, revision ) -> toString ((toString major) ++ "." ++ (toString minor) ++ "." ++ (toString revision)))


fileDataFuzzer : Fuzz.Fuzzer FileData
fileDataFuzzer =
    Fuzz.tuple5 ( Fuzz.int, Fuzz.string, Fuzz.string, Fuzz.string, Fuzz.int )
        |> Fuzz.map (\( id, prefix, path, provider, priority ) -> (FileData (Just id) prefix path provider priority))


initialAutocomplete : Autocomplete
initialAutocomplete =
    { autoState = Autocomplete.empty
    , query = ""
    , libraries = []
    , howManyToShow = 5
    , showMenu = False
    , selectedLibrary = Nothing
    }


basicListOfLibraries : List Library
basicListOfLibraries =
    [ (Library "Test1" "1.1.1" "Test1 1.1.1")
    , (Library "Test2" "2.2.2" "Test2 2.2.2")
    , (Library "Test3" "3.3.3" "Test3 3.3.3")
    ]


initialFileModel : Model
initialFileModel =
    Model
        basicJackrabbitFile
        basicJackrabbitFile
        False
        emptyHttpInfo
        initialLocalization
        initialAutocomplete
        initialPaths
        initialProviders


initialPaths : List String
initialPaths =
    [ "Path1", "Path2" ]


initialProviders : List String
initialProviders =
    [ "DnnBodyProvider", "DnnFormBottomProvider", "DnnPageHeaderProvider" ]


emptyHttpInfo : HttpInfo
emptyHttpInfo =
    HttpInfo
        ""
        []
        ""


initialLocalization : Dict String String
initialLocalization =
    Dict.empty


basicJackrabbitFile : JackrabbitFile
basicJackrabbitFile =
    JavaScriptFile (FileData (Just 1) "Test.js" "random/path/stuff" "DnnFormBottomProvider" 100)


basicJackrabbitLibrary : JackrabbitFile
basicJackrabbitLibrary =
    JavaScriptLibrary (FileData (Just 1) "jQuery-Migrate" "~/Resources/libraries/JQuery-Migrate/01_02_01/jquery-migrate.js" "DnnFormBottomProvider" 100) (LibraryData "jQuery-Migrate" "1.2.1" LatestMajor)


initialLibraryModel : Model
initialLibraryModel =
    Model
        basicJackrabbitLibrary
        basicJackrabbitLibrary
        False
        emptyHttpInfo
        Dict.empty
        initialAutocomplete
        initialPaths
        initialProviders


getLibrary file =
    case file of
        JavaScriptLibrary _ libraryData ->
            libraryData

        _ ->
            Debug.crash ("library expected: " ++ (toString file))
