module Views.Elm.File.View exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App as Html
import Html.Events exposing (..)
import Json.Decode as Decode
import String
import Views.Elm.File.Model exposing (..)
import Views.Elm.File.Msg exposing (..)
import Views.Elm.Utility exposing (localizeString, emptyElement)
import Autocomplete


view : Model -> Html Msg
view model =
    if model.editing then
        viewFile model.originalFile model.localization
    else
        viewFile model.file model.localization


editLib : Model -> Html Msg
editLib model =
    if model.editing then
        case model.file of
            JavaScriptLibrary fileData libFile ->
                libraryForm model

            _ ->
                editFile model
    else
        emptyElement


viewAddForm : Model -> Html Msg
viewAddForm model =
    addForm model


viewFile : JackRabbitFile -> Dict String String -> Html Msg
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


editFile : Model -> Html Msg
editFile model =
    let
        fileData =
            getFile model.file

        localization =
            model.localization
    in
        div []
            [ label [ class "jackrabbit--prefix" ] [ text (localizeString "Path Prefix Name" localization) ]
            , makeDropDown model.pathList model.file
            , label [ class "jackrabbit--path" ] [ text (localizeString "File Path" localization) ]
            , input [ type' "text", onInput UpdatePath, value fileData.filePath ] []
            , label [ class "jackrabbit--provider" ] [ text (localizeString "Provider" localization) ]
            , showProviderMenu model.file model.localization model.providers
            , label [ class "jackrabbit--priority" ] [ text (localizeString "Priority" localization) ]
            , input [ type' "text", on "input" (stringToIntDecoder UpdatePriority fileData.priority), value (toString fileData.priority) ] []
            , button [ type' "button", onClick SaveFileChanges ] [ text (localizeString "Save" localization) ]
            , button [ type' "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
            ]


showProviderMenu : JackRabbitFile -> Dict String String -> List String -> Html Msg
showProviderMenu file localization providers =
    let
        fileData =
            getFile file

        options =
            providers
                |> List.map (\provider -> option [ selected (fileData.provider == provider), value provider ] [ text (localizeString provider localization) ])
    in
        select [ onInput UpdateProvider ] options


libraryForm : Model -> Html Msg
libraryForm model =
    let
        localization =
            model.localization

        file =
            model.file

        libraryData =
            getLibrary file

        inputWithAutocomplete =
            autoCompleteInput model
    in
        div []
            [ label [ class "jackrabbit--prefix" ] [ text (localizeString "Library Name" localization) ]
            , autoCompleteInput model
            , label [ class "jackrabbit--prefix" ] [ text (localizeString "Version" localization) ]
            , input [ type' "text", onInput UpdateVersion, value libraryData.version ] []
            , label [ class "jackrabbit--prefix" ] [ text (localizeString "Version Specificity" localization) ]
            , select [ onInput UpdateSpecificity ]
                [ option [ value "Latest", selected (libraryData.specificity == Latest) ] [ text (localizeString "Latest" localization) ]
                , option [ value "LatestMajor", selected (libraryData.specificity == LatestMajor) ] [ text (localizeString "Latest Major" localization) ]
                , option [ value "LatestMinor", selected (libraryData.specificity == LatestMinor) ] [ text (localizeString "Latest Minor" localization) ]
                , option [ value "Exact", selected (libraryData.specificity == Exact) ] [ text (localizeString "Exact" localization) ]
                ]
            , button [ type' "button", onClick SaveLibraryChanges ] [ text (localizeString "Save" localization) ]
            , button [ type' "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
            ]


autoCompleteInput : Model -> Html Msg
autoCompleteInput model =
    let
        autoComplete =
            model.autocomplete

        options =
            { preventDefault = True, stopPropagation = False }

        dec =
            (Decode.customDecoder keyCode
                (\code ->
                    if code == 38 || code == 40 then
                        Ok NoOp
                    else if code == 27 then
                        Ok HandleEscape
                    else
                        Err "not handling that key"
                )
            )

        --DropDown of autocomplete options?
        menu =
            if autoComplete.showMenu then
                [ viewMenu model ]
            else
                case autoComplete.query of
                    "" ->
                        []

                    _ ->
                        case autoComplete.selectedLibrary of
                            Nothing ->
                                [ div [] [ text (localizeString "No Results" model.localization) ]
                                ]

                            _ ->
                                [ emptyElement ]

        query =
            case autoComplete.selectedLibrary of
                Just library ->
                    library.name

                Nothing ->
                    autoComplete.query

        activeDescendant attributes =
            case autoComplete.selectedLibrary of
                Just library ->
                    (attribute "aria-activedescendant"
                        library.name
                    )
                        :: attributes

                Nothing ->
                    attributes
    in
        div []
            (List.append
                [ input
                    (activeDescendant
                        [ onInput SetQuery
                        , onFocus OnFocus
                        , onWithOptions "keydown" options dec
                        , value (setValue model query)
                        , id "library-input"
                        , class "autocomplete-input"
                        , autocomplete False
                        , attribute "aria-owns" "list-of-libraries"
                        , attribute "aria-expanded" <| String.toLower <| toString autoComplete.showMenu
                        , attribute "aria-haspopup" <| String.toLower <| toString autoComplete.showMenu
                        , attribute "role" "combobox"
                        , attribute "aria-autocomplete" "list"
                        ]
                    )
                    []
                ]
                menu
            )


setValue : Model -> String -> String
setValue model query =
    let
        selectedLibrary =
            model.autocomplete.selectedLibrary
    in
        case model.editing of
            False ->
                case selectedLibrary of
                    Just selectedLibrary ->
                        selectedLibrary.libName

                    Nothing ->
                        query

            True ->
                (getLibrary model.file).libraryName


viewMenu : Model -> Html Msg
viewMenu model =
    let
        autocomplete =
            model.autocomplete
    in
        div []
            [ Html.map SetAutoState
                (Autocomplete.view
                    viewConfig
                    autocomplete.howManyToShow
                    autocomplete.autoState
                    (acceptableLibraries
                        autocomplete.query
                        autocomplete.libraries
                    )
                )
            ]


viewConfig : Autocomplete.ViewConfig Library
viewConfig =
    let
        customizedLi keySelected mouseSelected library =
            { attributes =
                [ classList [ ( "autocomplete-item", True ), ( "key-selected", keySelected || mouseSelected ) ]
                , id library.name
                ]
            , children = [ Html.text library.name ]
            }
    in
        Autocomplete.viewConfig
            { toId = .name
            , ul = [ class "autocomplete-list" ]
            , li = customizedLi
            }


acceptableLibraries : String -> List Library -> List Library
acceptableLibraries query libraries =
    let
        lowerQuery =
            String.toLower query
    in
        List.filter (String.contains lowerQuery << String.toLower << .name) libraries


addForm : Model -> Html Msg
addForm model =
    let
        file =
            model.file

        localization =
            model.localization

        fileData =
            getFile file

        fileForm =
            div []
                [ label [ class "jackrabbit--prefix" ] [ text (localizeString "Path Prefix Name" localization) ]
                , makeDropDown model.pathList model.file
                , label [ class "jackrabbit--path" ] [ text (localizeString "File Path" localization) ]
                , input [ type' "text", onInput UpdatePath, value fileData.filePath ] []
                , label [ class "jackrabbit--provider" ] [ text (localizeString "Provider" localization) ]
                , showProviderMenu model.file model.localization model.providers
                , label [ class "jackrabbit--priority" ] [ text (localizeString "Priority" localization) ]
                , input [ type' "text", on "input" (stringToIntDecoder UpdatePriority fileData.priority), value (toString fileData.priority) ] []
                , button [ type' "button", onClick SaveFileChanges ] [ text (localizeString "Save" localization) ]
                , button [ type' "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
                ]
    in
        case file of
            Default fileData ->
                div []
                    [ label []
                        [ text "Select the File Type:"
                        , button [ type' "button", onClick (SetFileType "JavaScript" file) ] [ text (localizeString "JavaScript" localization) ]
                        , button [ type' "button", onClick (SetFileType "Css" file) ] [ text (localizeString "Css" localization) ]
                        , button [ type' "button", onClick (SetLibrary file) ] [ text (localizeString "JSLibrary" localization) ]
                        ]
                    ]

            CssFile fileData ->
                fileForm

            JavaScriptFile fileData ->
                fileForm

            JavaScriptLibrary fileData libData ->
                libraryForm model


stringToIntDecoder : (Int -> Msg) -> Int -> Decode.Decoder Msg
stringToIntDecoder tagger default =
    let
        stringToInt value =
            String.toInt value
                |> Result.withDefault default
    in
        Decode.map (\value -> tagger (stringToInt value)) targetValue


getRowClasses : JackRabbitFile -> List ( String, Bool )
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

                JavaScriptLibrary fileData libData ->
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


makeDropDown : List String -> JackRabbitFile -> Html Msg
makeDropDown paths jackrabbitFile =
    let
        file =
            getFile jackrabbitFile

        generateOptions =
            paths
                |> List.map (makeOption file.pathPrefixName)

        options =
            option [ value "" ] [ text "No default prefix" ] :: generateOptions
    in
        select [ onInput UpdatePrefix ] options


makeOption : String -> String -> Html Msg
makeOption pathPrefixName string =
    option [ value string, selected (pathPrefixName == string) ] [ text (string) ]
