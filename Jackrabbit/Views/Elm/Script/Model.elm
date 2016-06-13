module Views.Elm.Script.Model exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Json.Encode as Encode
import Views.Elm.Ajax exposing (HttpVerb, HttpInfo)


type alias ScriptData =
    { id : Maybe Int
    , pathPrefixName : String
    , scriptPath : String
    , provider : String
    , priority : Int
    }


type alias Model =
    { script : ScriptData
    , originalScript : ScriptData
    , editing : Bool
    , httpInfo : HttpInfo
    }


init : Maybe Int -> String -> String -> String -> Int -> Bool -> HttpInfo -> Model
init id pathPrefixName scriptPath provider priority editing httpInfo =
    let
        script =
            ScriptData id
                pathPrefixName
                scriptPath
                provider
                priority
    in
        Model script
            script
            editing
            httpInfo


encodeScript : ScriptData -> Encode.Value
encodeScript script =
    Encode.object
        [ ( "pathPrefixName", Encode.string script.pathPrefixName )
        , ( "scriptPath", Encode.string script.scriptPath )
        , ( "provider", Encode.string script.provider )
        , ( "priority", Encode.int script.priority )
        ]


listScriptDecoder : Decode.Decoder (List ScriptData)
listScriptDecoder =
    Decode.list scriptDecoder


scriptDecoder : Decode.Decoder ScriptData
scriptDecoder =
    decode ScriptData
        |> required "Id" (Decode.maybe Decode.int)
        |> required "PathPrefixName" Decode.string
        |> required "ScriptPath" Decode.string
        |> required "Provider" Decode.string
        |> required "Priority" Decode.int


compareModels : Dict String Int -> Model -> Model -> Basics.Order
compareModels providers first second =
    case compareScripts providers first.script second.script of
        LT ->
            LT

        GT ->
            GT

        EQ ->
            compareScripts providers first.originalScript second.originalScript


compareScripts : Dict String Int -> ScriptData -> ScriptData -> Basics.Order
compareScripts providers first second =
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
                        compare first.scriptPath second.scriptPath
