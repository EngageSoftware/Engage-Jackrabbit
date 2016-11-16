module Views.Elm.Tests.JsonTests exposing (tests)

import Test exposing (..)
import Expect exposing (Expectation)
import Views.Elm.File.Model exposing (..)
import Fuzz as Fuzz
import Json.Encode as Json
import Json.Decode as Decode
import Views.Elm.Tests.TestUtilities exposing (encodeMaybe, versionFuzzer, fileDataFuzzer)
import Views.Elm.Decoders exposing (..)


tests : List Test
tests =
    [ describe "Decoding Functions"
        [ fuzz5 Fuzz.int Fuzz.string Fuzz.string Fuzz.string Fuzz.int "can decode Css file to CssFile with correct values" <|
            \randomId randomPrefix randomPath randomProvider randomPriority ->
                let
                    json =
                        Json.encode 0 (Json.object [ ( "FileType", Json.int 1 ), ( "Id", Json.int randomId ), ( "PathPrefixName", Json.string randomPrefix ), ( "FilePath", Json.string randomPath ), ( "Provider", Json.string randomProvider ), ( "Priority", Json.int randomPriority ) ])
                in
                    case Decode.decodeString fileDecoder json of
                        Err err ->
                            Expect.fail err

                        Ok (CssFile file) ->
                            file
                                |> Expect.equal (FileData (Just randomId) randomPrefix randomPath randomProvider randomPriority)

                        Ok _ ->
                            Expect.fail "Incorrect type"
        , fuzz5 Fuzz.int Fuzz.string Fuzz.string Fuzz.string Fuzz.int "can decode JS file to JavaScriptFile with correct values" <|
            \randomId randomPrefix randomPath randomProvider randomPriority ->
                let
                    json =
                        Json.encode 0 (Json.object [ ( "FileType", Json.int 0 ), ( "Id", Json.int randomId ), ( "PathPrefixName", Json.string randomPrefix ), ( "FilePath", Json.string randomPath ), ( "Provider", Json.string randomProvider ), ( "Priority", Json.int randomPriority ) ])
                in
                    case Decode.decodeString fileDecoder json of
                        Err err ->
                            Expect.fail err

                        Ok (JavaScriptFile file) ->
                            file
                                |> Expect.equal (FileData (Just randomId) randomPrefix randomPath randomProvider randomPriority)

                        Ok _ ->
                            Expect.fail "Incorrect type"
        , fuzz4 fileDataFuzzer Fuzz.string versionFuzzer (Fuzz.intRange 0 3) "can decode JavaScriptLibraries with correct fileData" <|
            \fileData randomLibrary randomVersion randomSpecificity ->
                let
                    json =
                        Json.encode 0
                            (Json.object
                                [ ( "FileType", Json.int 2 )
                                , ( "Id", encodeMaybe Json.int fileData.id )
                                , ( "PathPrefixName", Json.string fileData.pathPrefixName )
                                , ( "FilePath", Json.string fileData.filePath )
                                , ( "Provider", Json.string fileData.provider )
                                , ( "Priority", Json.int fileData.priority )
                                , ( "LibraryName", Json.string randomLibrary )
                                , ( "Version", Json.string randomVersion )
                                , ( "Specificity", Json.int randomSpecificity )
                                ]
                            )

                    file =
                        fileData

                    specificity =
                        intToSpecTest randomSpecificity
                in
                    case Decode.decodeString fileDecoder json of
                        Err err ->
                            Expect.fail err

                        Ok (JavaScriptLibrary fileData libraryData) ->
                            ( fileData, libraryData )
                                |> Expect.equal ( FileData file.id file.pathPrefixName file.filePath file.provider file.priority, LibraryData randomLibrary randomVersion specificity )

                        Ok _ ->
                            Expect.fail "Incorrect type"
        , test "can decode initialModel with suggestedFiles" <|
            \() ->
                let
                    json =
                        Json.object
                            [ ( "items"
                              , Json.list
                                    [ Json.object
                                        [ ( "FileType", Json.int 1 )
                                        , ( "Id", Json.int 1 )
                                        , ( "PathPrefixName", Json.string "PathName" )
                                        , ( "FilePath", Json.string "~/path/here" )
                                        , ( "Provider", Json.string "DnnFormBottomProvider" )
                                        , ( "Priority", Json.int 100 )
                                        ]
                                    ]
                              )
                            , ( "suggestions"
                              , Json.list
                                    [ (Json.string "Test.css")
                                    , (Json.string "Test2.css")
                                    ]
                              )
                            ]

                    expectedStrings =
                        [ "Test.css", "Test2.css" ]
                in
                    case Decode.decodeValue listFileDecoderandSuggestedFiles json of
                        Err err ->
                            Expect.fail err

                        Ok ( jackrabbitFiles, strings ) ->
                            case strings of
                                Just strings ->
                                    strings
                                        |> Expect.equal expectedStrings

                                Nothing ->
                                    Expect.fail "Failed to get Suggested Files"
        ]
    ]


intToSpecTest : Int -> Specificity
intToSpecTest verInt =
    case verInt of
        0 ->
            Latest

        1 ->
            LatestMajor

        2 ->
            LatestMinor

        3 ->
            Exact

        _ ->
            Debug.crash "Invalid specificity"
