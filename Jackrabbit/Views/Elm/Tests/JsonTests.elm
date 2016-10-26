module Views.Elm.Tests.JsonTests exposing (tests)

import Test exposing (..)
import Expect exposing (Expectation)
import Json.Decode as Decode
import Views.Elm.File.Model exposing (fileDecoder, JackRabbitFile(..), FileData, LibraryData, Specificity(..), encodeFile)


tests : List Test
tests =
    [ test "can decode JS file" <|
        \() ->
            let
                json =
                    """\x0D
                    {"FileType":0,"Id":296,"PathPrefixName":"asdf","FilePath":"sddfddddd.js","Provider":"DnnFormBottomProvider","Priority":100}\x0D
                    """
            in
                case Decode.decodeString fileDecoder json of
                    Err err ->
                        Expect.fail err

                    Ok _ ->
                        Expect.pass
    , test "can decode JS file to JavaScriptFile" <|
        \() ->
            let
                json =
                    """\x0D\x0D
                    {"FileType":0,"Id":296,"PathPrefixName":"asdf","FilePath":"sddfddddd.js","Provider":"DnnFormBottomProvider","Priority":100}\x0D\x0D
                    """
            in
                case Decode.decodeString fileDecoder json of
                    Err err ->
                        Expect.fail err

                    Ok (JavaScriptFile file) ->
                        Expect.pass

                    Ok _ ->
                        Expect.fail "Incorrect type"
    , test "can decode JS file to JavaScriptFile with correct values" <|
        \() ->
            let
                json =
                    """\x0D
                        {"FileType":0,"Id":296,"PathPrefixName":"asdf","FilePath":"sddfddddd.js","Provider":"DnnFormBottomProvider","Priority":100}\x0D
                    """
            in
                case Decode.decodeString fileDecoder json of
                    Err err ->
                        Expect.fail err

                    Ok (JavaScriptFile file) ->
                        file
                            |> Expect.equal (FileData (Just 296) "asdf" "sddfddddd.js" "DnnFormBottomProvider" 100)

                    Ok _ ->
                        Expect.fail "Incorrect type"
    , test "can decode JavaScriptLibraries with correct fileData" <|
        \() ->
            let
                json =
                    """\x0D
                        {"FileType":2,"Id":36,"PathPrefixName":"JS Library","FilePath":"blank.js","Provider":"DnnFormBottomProvider","Priority":156,"LibraryName":"html5shiv","Version":"1.8.1","VersionSpecificity":2}
                    """
            in
                case Decode.decodeString fileDecoder json of
                    Err err ->
                        Expect.fail err

                    Ok (JavaScriptLib fileData libData) ->
                        fileData
                            |> Expect.equal (FileData (Just 36) "JS Library" "blank.js" "DnnFormBottomProvider" 156)

                    --|> Expect.equal (LibraryData "JsonTests" "1.8.3" LatestMajor)
                    Ok _ ->
                        Expect.fail "Incorrect type"
    ]
