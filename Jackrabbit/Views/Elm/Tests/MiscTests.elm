module Views.Elm.Tests.MiscTests exposing (tests)

import Test exposing (..)
import Expect exposing (Expectation)
import Views.Elm.File.Model exposing (..)
import Views.Elm.File.Msg exposing (..)
import Views.Elm.File.Update exposing (..)
import Fuzz as Fuzz
import Views.Elm.Tests.TestUtilities exposing (initialFileModel, fileDataFuzzer)


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

                    jackRabbitFile =
                        JavaScriptFile file
                in
                    fileTypeToTypeId jackRabbitFile
                        |> Expect.equal 0
        , fuzz fileDataFuzzer "can get a file" <|
            \fileData ->
                let
                    jackRabbitFile =
                        JavaScriptFile fileData
                in
                    getFile jackRabbitFile
                        |> Expect.equal fileData
        ]
    ]
