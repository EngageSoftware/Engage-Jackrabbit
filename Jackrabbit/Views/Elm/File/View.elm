module Views.Elm.File.View exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import String
import Views.Elm.File.Model exposing (..)
import Views.Elm.File.Msg exposing (..)
import Views.Elm.Utility exposing (localizeString)


view : Model -> Html Msg
view model =
    if model.editing then
        editFile model.file model.localization
    else
        viewFile model.file model.localization


viewFile : FileData -> Dict String String -> Html Msg
viewFile file localization =
    tr []
        [ td [ class "jackrabbit--actions" ]
            [ button [ type' "button", onClick EditFile ] [ text (localizeString "Edit" localization) ]
            , button [ type' "button", onClick DeleteFile ] [ text (localizeString "Delete" localization) ]
            ]
        , td [ class "jackrabbit--prefix" ] [ text file.pathPrefixName ]
        , td [ class "jackrabbit--path" ] [ text file.filePath ]
        , td [ class "jackrabbit--provider" ] [ text file.provider ]
        , td [ class "jackrabbit--priority" ] [ text (toString file.priority) ]
        ]


editFile : FileData -> Dict String String -> Html Msg
editFile file localization =
    tr []
        [ td [ class "jackrabbit--actions" ]
            [ button [ type' "button", onClick SaveChanges ] [ text (localizeString "Save" localization) ]
            , button [ type' "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
            ]
        , td [ class "jackrabbit--prefix" ] [ input [ type' "text", onInput UpdatePrefix, value file.pathPrefixName ] [] ]
        , td [ class "jackrabbit--path" ] [ input [ type' "text", onInput UpdatePath, value file.filePath ] [] ]
        , td [ class "jackrabbit--provider" ] [ input [ type' "text", onInput UpdateProvider, value file.provider ] [] ]
        , td [ class "jackrabbit--priority" ] [ input [ type' "text", on "input" (stringToIntDecoder UpdatePriority file.priority), value (toString file.priority) ] [] ]
        ]


stringToIntDecoder : (Int -> Msg) -> Int -> Decode.Decoder Msg
stringToIntDecoder tagger default =
    let
        stringToInt value =
            String.toInt value
                |> Result.withDefault default
    in
        Decode.map (\value -> tagger (stringToInt value)) targetValue
