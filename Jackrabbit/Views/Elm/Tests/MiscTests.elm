module Views.Elm.Tests.MiscTests exposing (tests)

import Test exposing (..)
import Expect exposing (Expectation)
import Views.Elm.File.Model exposing (..)
import Views.Elm.File.Msg exposing (..)
import Views.Elm.File.Update exposing (..)
import Fuzz as Fuzz
import Views.Elm.Tests.TestUtilities exposing (..)
import Views.Elm.Update exposing (compareFileRows)
import Views.Elm.Model exposing (FileRow, initialModel)


tests : List Test
tests =
    [ describe "Other Functions"
        [ test "can specificity to TypeId" <|
            \() ->
                let
                    specificity =
                        Latest

                    num =
                        specificityToTypeId specificity
                in
                    num
                        |> Expect.equal 0
        , test "can TypeId to specificity" <|
            \() ->
                let
                    specificity =
                        intToSpecificity 0
                in
                    case specificity of
                        Err err ->
                            Expect.fail err

                        Ok spec ->
                            spec
                                |> Expect.equal Latest
        , test "can fileType to typeId" <|
            \() ->
                let
                    file =
                        FileData (Just 1) "pathPrefix" "filePath" "Body" 222

                    jackrabbitFile =
                        JavaScriptFile file
                in
                    fileTypeToTypeId jackrabbitFile
                        |> Expect.equal 0
        , fuzz fileDataFuzzer "can get a file" <|
            \fileData ->
                let
                    jackrabbitFile =
                        JavaScriptFile fileData
                in
                    getFile jackrabbitFile
                        |> Expect.equal fileData
        , test "Compare models" <|
            \() ->
                let
                    file3 =
                        FileRow 0 (emptyFileModel (JavaScriptFile (FileData (Just 1) "sharedScripts" "test.js" "DnnPageHeaderProvider" 100)))

                    file4 =
                        FileRow 1 (emptyFileModel (JavaScriptFile (FileData (Just 2) "sharedScripts" "test1.js" "DnnPageHeaderProvider" 101)))

                    file1 =
                        FileRow 2 (emptyFileModel (CssFile (FileData (Just 3) "skinPath" "test.css" "DnnPageHeaderProvider" 50)))

                    file2 =
                        FileRow 3 (emptyFileModel (CssFile (FileData (Just 4) "skinPath" "test1.css" "DnnPageHeaderProvider" 200)))

                    file5 =
                        FileRow 4 (emptyFileModel (JavaScriptLibrary (FileData (Just 5) "Knockout" "Knockout" "DnnPageHeaderProvider" 232) (LibraryData "" "" Latest)))

                    model =
                        { initialModel | fileRows = [ file3, file4, file1, file2, file5 ] }

                    expectedModel =
                        { initialModel | fileRows = [ file1, file2, file3, file4, file5 ] }

                    sortedRows =
                        model.fileRows
                            |> List.sortWith compareFileRows

                    comparedModel =
                        { initialModel | fileRows = sortedRows }
                in
                    comparedModel
                        |> Expect.equal expectedModel
        ]
    ]
