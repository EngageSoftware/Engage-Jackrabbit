module Views.Elm.File.View exposing (..)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import String
import Views.Elm.File.Model exposing (..)
import Views.Elm.File.Msg exposing (..)
import Views.Elm.Utility exposing (localizeString, emptyElement, localizeStringWithDefault)
import Autocomplete


view : Model -> Html Msg
view model =
    if model.deleted then
        viewDeleted model
    else
        viewFile model


editLib : Model -> Html Msg
editLib model =
    if model.editing then
        case model.file of
            JavaScriptLibrary fileData libraryData ->
                libraryForm model

            _ ->
                editFile model
    else
        emptyElement


viewAddForm : Model -> Html Msg
viewAddForm model =
    addForm model


viewFile : Model -> Html Msg
viewFile model =
    let
        file =
            if model.editing then
                model.originalFile
            else
                model.file

        localization =
            model.localization

        fileData =
            getFile file
    in
        tr [ classList (getRowClasses model) ]
            [ td [ class "jackrabbit-file--actions" ]
                [ button [ type_ "button", onClick EditFile ] [ text (localizeString "Edit" localization) ]
                , button [ type_ "button", onClick DeleteFile ] [ text (localizeString "Delete" localization) ]
                ]
            , td [ class "jackrabbit-file--prefix" ] [ text (localizeStringWithDefault fileData.pathPrefixName localization) ]
            , td [ class "jackrabbit-file--path" ] [ text fileData.filePath ]
            , td [ class "jackrabbit-file--provider" ] [ text (localizeString fileData.provider localization) ]
            , td [ class "jackrabbit-file--priority" ] [ text (toString fileData.priority) ]
            ]


viewDeleted : Model -> Html Msg
viewDeleted model =
    let
        file =
            model.file

        localization =
            model.localization

        fileData =
            getFile file
    in
        tr [ classList (getRowClasses model) ]
            [ td [ class "jackrabbit-file--actions" ]
                --TODO Undo Button functionality
                [ button [ type_ "button", onClick UndoDelete ] [ text (localizeString "Undo" localization) ]
                ]
            , td [ class "jackrabbit-file--prefix" ] [ text (localizeStringWithDefault fileData.pathPrefixName localization) ]
            , td [ class "jackrabbit-file--path" ] [ text fileData.filePath ]
            , td [ class "jackrabbit-file--provider" ] [ text (localizeString fileData.provider localization) ]
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
            , makeDropDown model.pathList model.file localization
            , label [ class "jackrabbit--path" ] [ text (localizeString "File Path" localization) ]
            , input [ type_ "text", onInput UpdatePath, value fileData.filePath ] []
            , label [ class "jackrabbit--provider" ] [ text (localizeString "Provider" localization) ]
            , showProviderMenu model.file model.localization model.providers
            , label [ class "jackrabbit--priority" ] [ text (localizeString "Priority" localization) ]
            , input [ type_ "text", on "input" (stringToIntDecoder UpdatePriority fileData.priority), value (toString fileData.priority) ] []
            , button [ type_ "button", onClick SaveChanges ] [ text (localizeString "Save" localization) ]
            , button [ type_ "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
            ]


showProviderMenu : JackrabbitFile -> Dict String String -> List String -> Html Msg
showProviderMenu file localization providers =
    let
        fileData =
            getFile file

        sortedProviders =
            providers
                |> List.sortBy orderProvider

        options =
            sortedProviders
                |> List.map (\provider -> option [ selected (fileData.provider == provider), value provider ] [ text (localizeString provider localization) ])
    in
        select [ onInput UpdateProvider ] options


orderProvider : String -> Int
orderProvider provider =
    case provider of
        "DnnPageHeaderProvider" ->
            1

        "DnnBodyProvider" ->
            2

        "DnnFormBottomProvider" ->
            3

        _ ->
            0


libraryForm : Model -> Html Msg
libraryForm model =
    case model.file of
        JavaScriptLibrary _ libraryData ->
            let
                localization =
                    model.localization
            in
                div []
                    [ label [ class "jackrabbit--prefix" ] [ text (localizeString "Library Name" localization) ]
                    , autoCompleteInput model
                    , label [ class "jackrabbit--prefix" ] [ text (localizeString "Version" localization) ]
                    , input [ type_ "text", onInput UpdateVersion, value libraryData.version ] []
                    , label [ class "jackrabbit--prefix" ] [ text (localizeString "Version Specificity" localization) ]
                    , select [ onInput UpdateSpecificity ]
                        [ option [ value "Latest", selected (libraryData.specificity == Latest) ] [ text (localizeString "Latest" localization) ]
                        , option [ value "LatestMajor", selected (libraryData.specificity == LatestMajor) ] [ text (localizeString "Latest Major" localization) ]
                        , option [ value "LatestMinor", selected (libraryData.specificity == LatestMinor) ] [ text (localizeString "Latest Minor" localization) ]
                        , option [ value "Exact", selected (libraryData.specificity == Exact) ] [ text (localizeString "Exact" localization) ]
                        ]
                    , button [ type_ "button", onClick SaveChanges ] [ text (localizeString "Save" localization) ]
                    , button [ type_ "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
                    ]

        _ ->
            emptyElement


suggestedFileView : Model -> Html Msg
suggestedFileView model =
    let
        fileData =
            getFile model.file

        filePath =
            fileData.filePath

        localization =
            model.localization
    in
        div []
            [ button [ type_ "button", onClick AddSuggestedFile ] [ text (localizeString "Add" localization) ]
            , button [ type_ "button", onClick DismissSuggestedFile ] [ text (localizeString "Dismiss" localization) ]
            , text (fileDisplay filePath)
            ]


fileDisplay : String -> String
fileDisplay filePath =
    let
        pathList =
            List.reverse (String.split "\\" filePath)

        file =
            case List.head pathList of
                Nothing ->
                    filePath

                Just string ->
                    string
    in
        file


autoCompleteInput : Model -> Html Msg
autoCompleteInput model =
    let
        autoComplete =
            model.autocomplete

        options =
            { preventDefault = True, stopPropagation = False }

        dec =
            keyCode
                |> Json.andThen
                    (\code ->
                        if code == 38 || code == 40 then
                            Json.succeed NoOp
                        else if code == 27 then
                            Json.succeed HandleEscape
                        else
                            Json.fail "not handling that key"
                    )

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
    if model.editing then
        case model.file of
            JavaScriptLibrary fileData libraryData ->
                libraryData.libraryName

            _ ->
                query
    else
        case model.autocomplete.selectedLibrary of
            Just selectedLibrary ->
                selectedLibrary.libName

            Nothing ->
                query


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
                , makeDropDown model.pathList model.file localization
                , label [ class "jackrabbit--path" ] [ text (localizeString "File Path" localization) ]
                , input [ type_ "text", onInput UpdatePath, value fileData.filePath ] []
                , label [ class "jackrabbit--provider" ] [ text (localizeString "Provider" localization) ]
                , showProviderMenu model.file model.localization model.providers
                , label [ class "jackrabbit--priority" ] [ text (localizeString "Priority" localization) ]
                , input [ type_ "text", on "input" (stringToIntDecoder UpdatePriority fileData.priority), value (toString fileData.priority) ] []
                , button [ type_ "button", onClick SaveChanges ] [ text (localizeString "Save" localization) ]
                , button [ type_ "button", onClick CancelChanges ] [ text (localizeString "Cancel" localization) ]
                ]
    in
        if model.choosingType then
            div []
                [ label []
                    [ text (localizeString "Select the File Type:" localization)
                    , button [ type_ "button", onClick (SetFileType "JavaScript" file) ] [ text (localizeString "JavaScript" localization) ]
                    , button [ type_ "button", onClick (SetFileType "Css" file) ] [ text (localizeString "Css" localization) ]
                    , button [ type_ "button", onClick (SetLibrary file) ] [ text (localizeString "JSLibrary" localization) ]
                    ]
                ]
        else
            case file of
                CssFile fileData ->
                    fileForm

                JavaScriptFile fileData ->
                    fileForm

                JavaScriptLibrary fileData libData ->
                    libraryForm model


stringToIntDecoder : (Int -> Msg) -> Int -> Json.Decoder Msg
stringToIntDecoder tagger default =
    let
        stringToInt value =
            String.toInt value
                |> Result.withDefault default
    in
        Json.map (\value -> tagger (stringToInt value)) targetValue


getRowClasses : Model -> List ( String, Bool )
getRowClasses model =
    let
        file =
            model.file

        fileData =
            getFile file

        provider =
            fileData.provider

        fileType =
            if model.deleted then
                "Deleted"
            else
                case file of
                    JavaScriptFile fileData ->
                        "Javascript"

                    JavaScriptLibrary fileData libData ->
                        "Javascript"

                    _ ->
                        "Css"
    in
        [ ( "jackrabbit-file", True )
        , ( "jackrabbit-file__type-javascript", fileType == "Javascript" )
        , ( "jackrabbit-file__type-css", fileType == "Css" )
        , ( "jackrabbit-file__provider-head", provider == "DnnPageHeaderProvider" )
        , ( "jackrabbit-file__provider-body", provider == "DnnBodyProvider" )
        , ( "jackrabbit-file__provider-bottom", provider == "DnnFormBottomProvider" )
        , ( "jackrabbit-file__deleted", fileType == "Deleted" )
        ]


makeDropDown : List String -> JackrabbitFile -> Dict String String -> Html Msg
makeDropDown paths jackrabbitFile localization =
    let
        file =
            getFile jackrabbitFile

        generateOptions =
            paths
                |> List.map (makeOption file.pathPrefixName localization)

        options =
            option [ value "" ] [ text (localizeString "No default prefix" localization) ] :: generateOptions
    in
        select [ onInput UpdatePrefix ] options


makeOption : String -> Dict String String -> String -> Html Msg
makeOption pathPrefixName localization string =
    option [ value string, selected (pathPrefixName == string) ] [ text (localizeStringWithDefault string localization) ]
