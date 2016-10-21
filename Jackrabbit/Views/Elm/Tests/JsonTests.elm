module Views.Elm.Tests.JsonTests exposing (tests)

import Test exposing (..)
import Expect exposing (Expectation)
import Json.Decode as Decode
import Views.Elm.File.Model exposing (fileDecoder, ThingToLoad(..), FileData)


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
      {--
    , test "can decode CSS file" <|
        \() ->
            """\x0D
            {"FileType":1,"Id":5,"PathPrefixName":"","FilePath":"~/sddfddddd.css","Provider":"DnnFormBottomProvider","Priority":120}\x0D
            """
                |> Decode.decodeString thingDecoder
                |> Result.map CssFile
                |> Expect.equal (Ok (CssFile (FileData (Just 5) "" "~/sddfddddd.css" "DnnFormBottomProvider" 120)))
                --}
    ]
