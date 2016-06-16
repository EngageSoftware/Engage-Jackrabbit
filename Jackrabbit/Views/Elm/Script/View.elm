module Views.Elm.Script.View exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import String
import Views.Elm.Script.Model exposing (..)
import Views.Elm.Script.Msg exposing (..)
import Views.Elm.Utility exposing (localizeString)


view : Model -> Html Msg
view model =
    if model.editing then
        editScript model.script model.localization
    else
        viewScript model.script model.localization


viewScript : ScriptData -> Dict String String -> Html Msg
viewScript script localization =
    tr []
        [ td [ class "jackrabbit--actions" ]
            [ button [ type' "button", onClick EditScript ] [ text (localizeString "Edit" localization) ]
            , button [ type' "button", onClick DeleteScript ] [ text (localizeString "Delete" localization) ]
            ]
        , td [ class "jackrabbit--prefix" ] [ text script.pathPrefixName ]
        , td [ class "jackrabbit--path" ] [ text script.scriptPath ]
        , td [ class "jackrabbit--provider" ] [ text script.provider ]
        , td [ class "jackrabbit--priority" ] [ text (toString script.priority) ]
        ]


editScript : ScriptData -> Dict String String -> Html Msg
editScript script localization =
    tr []
        [ td [ class "jackrabbit--actions" ]
            [ button [ type' "button", onClick SaveChanges ] [ text (localizeString "Save" localization) ]
            , button [ type' "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
            ]
        , td [ class "jackrabbit--prefix" ] [ input [ type' "text", onInput UpdatePrefix, value script.pathPrefixName ] [] ]
        , td [ class "jackrabbit--path" ] [ input [ type' "text", onInput UpdatePath, value script.scriptPath ] [] ]
        , td [ class "jackrabbit--provider" ] [ input [ type' "text", onInput UpdateProvider, value script.provider ] [] ]
        , td [ class "jackrabbit--priority" ] [ input [ type' "text", on "input" (stringToIntDecoder UpdatePriority script.priority), value (toString script.priority) ] [] ]
        ]


stringToIntDecoder : (Int -> Msg) -> Int -> Decode.Decoder Msg
stringToIntDecoder tagger default =
    let
        stringToInt value =
            String.toInt value
                |> Result.withDefault default
    in
        Decode.map (\value -> tagger (stringToInt value)) targetValue
