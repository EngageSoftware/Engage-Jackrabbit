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


viewFile : ThingToLoad -> Dict String String -> Html Msg
viewFile file localization =
    let
        fileData =
            getFile file
    in
        tr [ classList (getRowClasses file) ]
            [ td [ class "jackrabbit-file--actions" ]
                [ button [ type' "button", onClick EditFile ] [ text (localizeString "Edit" localization) ]
                , button [ type' "button", onClick DeleteFile ] [ text (localizeString "Delete" localization) ]
                ]
            , td [ class "jackrabbit-file--prefix" ] [ text fileData.pathPrefixName ]
            , td [ class "jackrabbit-file--path" ] [ text fileData.filePath ]
            , td [ class "jackrabbit-file--provider" ] [ text fileData.provider ]
            , td [ class "jackrabbit-file--priority" ] [ text (toString fileData.priority) ]
            ]


editFile : ThingToLoad -> Dict String String -> Html Msg
editFile file localization =
    let
        fileData =
            getFile file
    in
        tr [ classList (getRowClasses file) ]
            [ td [ class "jackrabbit-file--actions" ]
                [ button [ type' "button", onClick SaveChanges ] [ text (localizeString "Save" localization) ]
                , button [ type' "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
                ]
            , td [ class "jackrabbit-file--prefix" ] [ input [ type' "text", onInput UpdatePrefix, value fileData.pathPrefixName ] [] ]
            , td [ class "jackrabbit-file--path" ] [ input [ type' "text", onInput UpdatePath, value fileData.filePath ] [] ]
            , td [ class "jackrabbit-file--provider" ] [ input [ type' "text", onInput UpdateProvider, value fileData.provider ] [] ]
            , td [ class "jackrabbit-file--priority" ] [ input [ type' "text", on "input" (stringToIntDecoder UpdatePriority fileData.priority), value (toString fileData.priority) ] [] ]
            ]


addForm : ThingToLoad -> Dict String String -> Html Msg
addForm file localization =
    let
        fileData =
            getFile file

        fileForm =
            div []
                [ label [ class "jackrabbit--prefix" ] [ text "Path Prefix Name" ]
                , input [ type' "text", onInput UpdatePrefix, value fileData.pathPrefixName ] []
                , label [ class "jackrabbit--path" ] [ text "File Path" ]
                , input [ type' "text", onInput UpdatePath, value fileData.filePath ] []
                , label [ class "jackrabbit--provider" ] [ text "Provider" ]
                , select [ onInput UpdateProvider ]
                    [ option [] [ text "DnnPageHeaderProvider" ]
                    , option [] [ text "DnnBodyProvider" ]
                    , option [] [ text "DnnFormBottomProvider" ]
                    ]
                , label [ class "jackrabbit--priority" ] [ text "Priority" ]
                , input [ type' "text", on "input" (stringToIntDecoder UpdatePriority fileData.priority), value (toString fileData.priority) ] []
                , button [ type' "button", onClick SaveTempForm ] [ text (localizeString "Save" localization) ]
                , button [ type' "button", onClick CancelTempForm ] [ text (localizeString "Cancel" localization) ]
                ]

        libraryForm =
            div []
                [ label [ class "jackrabbit--prefix" ] [ text "Library Name" ]
                , input [ type' "text" {- add onInput -} ] []
                , label [ class "jackrabbit--prefix" ] [ text "Version" ]
                , input [ type' "text" {- add on input -} ] []
                , label [ class "jackrabbit--prefix" ] [ text "Version Specificity" ]
                , select [{- add oninput -}]
                    [ option [] [ text "Latest" ]
                    , option [] [ text "Latest Major" ]
                    , option [] [ text "Latest Minor" ]
                    , option [] [ text "Exact" ]
                    ]
                , button [ type' "button", onClick SaveTempForm ] [ text (localizeString "Save" localization) ]
                , button [ type' "button", onClick CancelTempForm ] [ text (localizeString "Cancel" localization) ]
                ]
    in
        case file of
            Default fileData ->
                div []
                    [ label []
                        [ text "Select the File Type:"
                        , button [ type' "button", onClick (SetFileType "JavaScript" file) ] [ text "JavaScript" ]
                        , button [ type' "button", onClick (SetFileType "Css" file) ] [ text "CSS" ]
                        , button [ type' "button", onClick (SetFileType "JavaScriptLibrary" file) ] [ text "JS Library" ]
                        ]
                    ]

            CssFile fileData ->
                fileForm

            JavaScriptFile fileData ->
                fileForm

            JavaScriptLib fileData ->
                libraryForm


stringToIntDecoder : (Int -> Msg) -> Int -> Decode.Decoder Msg
stringToIntDecoder tagger default =
    let
        stringToInt value =
            String.toInt value
                |> Result.withDefault default
    in
        Decode.map (\value -> tagger (stringToInt value)) targetValue


getRowClasses : ThingToLoad -> List ( String, Bool )
getRowClasses file =
    let
        oldFile =
            getFile file

        provider =
            oldFile.provider

        js =
            case file of
                JavaScriptFile fileData ->
                    True

                _ ->
                    False

        css =
            case file of
                CssFile fileData ->
                    True

                _ ->
                    False
    in
        [ ( "jackrabbit-file", True )
        , ( "jackrabbit-file__type-javascript", js )
        , ( "jackrabbit-file__type-css", css )
        , ( "jackrabbit-file__provider-head", provider == "DnnPageHeaderProvider" )
        , ( "jackrabbit-file__provider-body", provider == "DnnBodyProvider" )
        , ( "jackrabbit-file__provider-bottom", provider == "DnnFormBottomProvider" )
        ]
