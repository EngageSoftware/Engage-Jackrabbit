module Views.Elm.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App
import Views.Elm.Model exposing (..)
import Views.Elm.File.View as File
import Views.Elm.File.Model as File
import Views.Elm.Msg exposing (..)
import Dict exposing (Dict)
import Views.Elm.Utility exposing (emptyElement, localizeString)
import Views.Elm.File.Model exposing (getFile)
import String as String exposing (toUpper)


view : Model -> Html Msg
view model =
    let
        itemRows provider =
            model.fileRows
                |> List.filter (\fileRow -> (getFile fileRow.file.originalFile).provider == provider)
                |> List.map viewFileRow

        itemSection ( provider, fileRows ) =
            let
                labelRow =
                    tr [ class "jackrabbit--item-section--label" ] [ td [ colspan 5 ] [ text (localizeString provider model.localization) ] ]
            in
                tbody
                    [ class ("jackrabbit--item-section jackrabbit--item-section__" ++ provider)
                    ]
                    (labelRow :: fileRows)

        itemSections =
            model.providers
                |> Dict.keys
                |> List.sortBy (\provider -> Dict.get provider model.providers |> Maybe.withDefault 0)
                |> List.map (\provider -> ( provider, itemRows provider ))
                |> List.filter (\( provider, rows ) -> List.isEmpty rows == False)
                |> List.map itemSection

        editLibForm =
            model.fileRows
                |> List.map addEditForm

        addFile =
            showAddFile model model.tempFileRow

        suggestedFiles =
            showSuggestions model

        tableHeader =
            thead
                []
                [ tr []
                    [ th [ class "jackrabbit--actions" ] []
                    , th [ class "jackrabbit--prefix" ] [ text (localizeString "Path Prefix Name.Header" model.localization) ]
                    , th [ class "jackrabbit--path" ] [ text (localizeString "File Path.Header" model.localization) ]
                    , th [ class "jackrabbit--provider" ] [ text (localizeString "Provider.Header" model.localization) ]
                    , th [ class "jackrabbit--priority" ] [ text (localizeString "Priority.Header" model.localization) ]
                    ]
                ]
    in
        if not model.criticalError then
            div []
                [ viewErrorMessage model.errorMessage model.localization
                , suggestedFiles
                , addFile
                , div []
                    editLibForm
                , table [ class "dnnTableDisplay" ]
                    (tableHeader :: itemSections)
                ]
        else
            div []
                [ criticalError ]


viewFileRow : FileRow -> Html Msg
viewFileRow { rowId, file } =
    App.map (FileMsg rowId) (File.view file)


addEditForm : FileRow -> Html Msg
addEditForm { rowId, file } =
    App.map (FileMsg rowId) (File.editLib file)


showAddFile : Model -> Maybe FileRow -> Html Msg
showAddFile model tempFile =
    case tempFile of
        Nothing ->
            case model.editing of
                False ->
                    button [ type_ "button", onClick AddNewFile ] [ text (localizeString "Add" model.localization) ]

                True ->
                    emptyElement

        Just { rowId, file } ->
            App.map (FileMsg rowId) (File.viewAddForm file)


criticalError : Html Msg
criticalError =
    --NOTE: This cannot be localized, since the parsing of the initial data (which includes the localization dictionary) failed
    div [ class "dnnFormMessage dnnFormValidationSummary" ]
        [ text "We're sorry, there was an unexpected issue loading Jackrabbit.  Try doing a hard refresh in your browser ( "
        , kbd [] [ text "Ctrl" ]
        , text " + "
        , kbd [] [ text "F5" ]
        , text " on Windows, "
        , kbd [] [ text "⌘ Cmd" ]
        , text " + "
        , kbd [] [ text "⇧ Shift" ]
        , text " + "
        , kbd [] [ text "R" ]
        , text " on macOS)."
        ]


showSuggestions : Model -> Html Msg
showSuggestions model =
    let
        files =
            model.suggestedFiles
                |> List.map (suggestedFilesRow model)

        capitalizedTempLibName =
            String.toUpper model.tempLibraryName
    in
        case model.suggestedFiles of
            [] ->
                emptyElement

            _ ->
                div []
                    [ text ((localizeString "Your Library" model.localization) ++ capitalizedTempLibName ++ (localizeString "Suggestions" model.localization))
                    , button [ type_ "button", onClick DismissAll ] [ text (localizeString "Dismiss All" model.localization) ]
                    , div [] files
                    ]


suggestedFilesRow : Model -> FileRow -> Html Msg
suggestedFilesRow model { rowId, file } =
    App.map (FileMsg rowId) (File.suggestedFileView file)


viewErrorMessage : Maybe String -> Dict String String -> Html Msg
viewErrorMessage errorMessage localization =
    case errorMessage of
        Nothing ->
            emptyElement

        Just message ->
            div [ class "dnnFormMessage dnnFormValidationSummary" ] [ text message, button [ type_ "button", onClick DismissError ] [ text (localizeString "Dismiss Error" localization) ] ]
