module Views.Elm.Script.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import String
import Views.Elm.Script.Model exposing (..)
import Views.Elm.Script.Msg exposing (..)


view : Model -> Html Msg
view model =
    if model.editing then
        editScript model.script
    else
        viewScript model.script


viewScript : ScriptData -> Html Msg
viewScript script =
    tr []
        [ td []
            [ button [ type' "button", onClick EditScript ] [ text "Edit" ]
            , button [ type' "button", onClick DeleteScript ] [ text "Delete" ]
            ]
        , td [] [ text script.pathPrefixName ]
        , td [] [ text script.scriptPath ]
        , td [] [ text script.provider ]
        , td [] [ text (toString script.priority) ]
        ]


editScript : ScriptData -> Html Msg
editScript script =
    tr []
        [ td []
            [ button [ type' "button", onClick SaveChanges ] [ text "Save" ]
            , button [ type' "button", onClick CancelChanges ] [ text "Cancel" ]
            ]
        , td [] [ input [ type' "text", onInput UpdatePrefix, value script.pathPrefixName ] [] ]
        , td [] [ input [ type' "text", onInput UpdatePath, value script.scriptPath ] [] ]
        , td [] [ input [ type' "text", onInput UpdateProvider, value script.provider ] [] ]
        , td [] [ input [ type' "text", on "input" (stringToIntDecoder UpdatePriority script.priority), value (toString script.priority) ] [] ]
        ]

stringToIntDecoder : (Int -> Msg) -> Int -> Decode.Decoder Msg
stringToIntDecoder tagger default =
    let
        stringToInt value =
            String.toInt value
                |> Result.withDefault default
    in
        Decode.map (\value -> tagger (stringToInt value)) targetValue
