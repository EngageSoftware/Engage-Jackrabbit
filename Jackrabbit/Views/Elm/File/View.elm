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


viewAddForm : Model -> Html Msg
viewAddForm model =
    addForm model.file model.localization


viewFile : FileData -> Dict String String -> Html Msg
viewFile file localization =
    tr [ classList (getRowClasses file) ]
        [ td [ class "jackrabbit-file--actions" ]
            [ button [ type' "button", onClick EditFile ] [ text (localizeString "Edit" localization) ]
            , button [ type' "button", onClick DeleteFile ] [ text (localizeString "Delete" localization) ]
            ]
        , td [ class "jackrabbit-file--prefix" ] [ text file.pathPrefixName ]
        , td [ class "jackrabbit-file--path" ] [ text file.filePath ]
        , td [ class "jackrabbit-file--provider" ] [ text file.provider ]
        , td [ class "jackrabbit-file--priority" ] [ text (toString file.priority) ]
        ]


editFile : FileData -> Dict String String -> Html Msg
editFile file localization =
    tr [ classList (getRowClasses file) ]
        [ td [ class "jackrabbit-file--actions" ]
            [ button [ type' "button", onClick SaveChanges ] [ text (localizeString "Save" localization) ]
            , button [ type' "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
            ]
        , td [ class "jackrabbit-file--prefix" ] [ input [ type' "text", onInput UpdatePrefix, value file.pathPrefixName ] [] ]
        , td [ class "jackrabbit-file--path" ] [ input [ type' "text", onInput UpdatePath, value file.filePath ] [] ]
        , td [ class "jackrabbit-file--provider" ] [ input [ type' "text", onInput UpdateProvider, value file.provider ] [] ]
        , td [ class "jackrabbit-file--priority" ] [ input [ type' "text", on "input" (stringToIntDecoder UpdatePriority file.priority), value (toString file.priority) ] [] ]
        ]


addForm : FileData -> Dict String String -> Html Msg
addForm file localization =
    if file.fileType == Default then
        div []
            [ label []
                [ text "Select the File Type:"
                , button [ type' "button", onClick (SetFileType JavaScript) ] [ text "JavaScript" ]
                , button [ type' "button", onClick (SetFileType CSS) ] [ text "CSS" ]
                ]
            ]
    else
        div []
            [ label [ class "jackrabbit--prefix" ] [ text "Path Prefix Name" ]
            , input [ type' "text", onInput UpdatePrefix, value file.pathPrefixName ] []
            , label [ class "jackrabbit--path" ] [ text "File Path" ]
            , input [ type' "text", onInput UpdatePath, value file.filePath ] []
            , label [ class "jackrabbit--provider" ] [ text "Provider" ]
            , input [ type' "text", onInput UpdateProvider, value file.provider ] []
            , label [ class "jackrabbit--priority" ] [ text "Priority" ]
            , input [ type' "text", on "input" (stringToIntDecoder UpdatePriority file.priority), value (toString file.priority) ] []
            , button [ type' "button", onClick SaveTempForm ] [ text (localizeString "Save" localization) ]
            , button [ type' "button", onClick CancelTempForm ] [ text (localizeString "Cancel" localization) ]
            ]


stringToIntDecoder : (Int -> Msg) -> Int -> Decode.Decoder Msg
stringToIntDecoder tagger default =
    let
        stringToInt value =
            String.toInt value
                |> Result.withDefault default
    in
        Decode.map (\value -> tagger (stringToInt value)) targetValue


getRowClasses : FileData -> List ( String, Bool )
getRowClasses file =
    [ ( "jackrabbit-file", True )
    , ( "jackrabbit-file__type-javascript", file.fileType == JavaScript )
    , ( "jackrabbit-file__type-css", file.fileType == CSS )
    , ( "jackrabbit-file__provider-head", file.provider == "DnnPageHeaderProvider" )
    , ( "jackrabbit-file__provider-body", file.provider == "DnnBodyProvider" )
    , ( "jackrabbit-file__provider-bottom", file.provider == "DnnFormBottomProvider" )
    ]
