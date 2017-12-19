module Views.Elm.Update exposing (update, updateFromChild, compareFileRows)

import Dict exposing (Dict)
import Views.Elm.Ajax exposing (..)
import Views.Elm.Model exposing (..)
import Views.Elm.Msg exposing (..)
import Views.Elm.File.Model as File exposing (initialAutocomplete)
import Views.Elm.File.Msg as File
import Views.Elm.File.ParentMsg as ParentMsg exposing (ParentMsg)
import Views.Elm.File.Update as File exposing (createFileAjaxCmd)
import Views.Elm.Utility exposing (createLocalizationDict, localizeString)
import List.Extra exposing (..)
import Maybe.Extra exposing (..)
import Json.Decode as Decode exposing (decodeValue)
import Views.Elm.Decoders exposing (initialDataDecoder)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init initialDataJson ->
            let
                initializedModel =
                    case (Decode.decodeValue initialDataDecoder initialDataJson) of
                        Err omg ->
                            { initialModel | criticalError = True }

                        Ok initialData ->
                            let
                                httpInfo =
                                    HttpInfo initialData.httpInfo.baseUrl initialData.httpInfo.headers (localizeString "HTTP Error" localization)

                                localization =
                                    initialData.localization

                                listPathAliases =
                                    initialData.pathAliases

                                ( fileRows, lastRowId ) =
                                    initialData.files
                                        |> makeFileRows model.lastRowId httpInfo model.providers localization File.initialAutocomplete listPathAliases
                            in
                                Model fileRows
                                    ""
                                    ""
                                    "DnnFormBottomProvider"
                                    100
                                    model.providers
                                    lastRowId
                                    Nothing
                                    httpInfo
                                    localization
                                    Nothing
                                    False
                                    listPathAliases
                                    False
                                    []
                                    ""
            in
                ( initializedModel, Cmd.none )

        AddNewFile ->
            let
                nextRowId =
                    model.lastRowId + 1

                newFile =
                    File.init File.JavaScriptFile
                        Nothing
                        model.defaultPathPrefix
                        model.defaultFilePath
                        model.defaultProvider
                        model.defaultPriority
                        False
                        model.httpInfo
                        model.localization
                        model.pathAliases
                        (Dict.keys model.providers)
                        True

                newFileRow =
                    FileRow nextRowId newFile
            in
                ( { model | tempFileRow = Just newFileRow, lastRowId = nextRowId }, Cmd.none )

        DismissError ->
            ( { model | errorMessage = Nothing }, Cmd.none )

        FileMsg rowId msg ->
            let
                matchingFileRow =
                    model.fileRows
                        |> List.Extra.find (findRow rowId)

                matchingSuggestedFile =
                    model.suggestedFiles
                        |> List.Extra.find (findRow rowId)

                fileRow =
                    matchingFileRow
                        |> Maybe.Extra.orElse model.tempFileRow
                        |> Maybe.Extra.orElse matchingSuggestedFile

                fileUpdate =
                    fileRow
                        |> Maybe.map (updateFile rowId msg)

                cmd =
                    fileUpdate
                        |> Maybe.map (\( file, cmd, parentMsg ) -> cmd)
                        |> Maybe.withDefault Cmd.none

                file =
                    fileUpdate
                        |> Maybe.map (\( file, cmd, parentMsg ) -> file)

                updatedModel =
                    case file of
                        Nothing ->
                            { model | errorMessage = Just "Error: Impossible State" }

                        Just f ->
                            if Maybe.Extra.isNothing matchingFileRow then
                                if Maybe.Extra.isNothing matchingSuggestedFile then
                                    { model | tempFileRow = Just f }
                                else
                                    { model | fileRows = model.fileRows ++ [ f ] }
                            else
                                { model | fileRows = List.Extra.replaceIf (\fr -> fr.rowId == rowId) f model.fileRows }

                modelWithParentMsgs =
                    fileUpdate
                        |> Maybe.map (updateFromChild updatedModel)
                        |> Maybe.withDefault model
            in
                ( modelWithParentMsgs, cmd )

        DismissAll ->
            ( { model | suggestedFiles = [] }, Cmd.none )


findRow : Int -> FileRow -> Bool
findRow rowId fileRow =
    if fileRow.rowId == rowId then
        True
    else
        False


updateFromChild : Model -> ( FileRow, Cmd msg, ParentMsg ) -> Model
updateFromChild model ( fileRow, _, parentMsg ) =
    case parentMsg of
        ParentMsg.NoOp ->
            model

        ParentMsg.AddSuggestion ->
            let
                newSuggestions =
                    model.suggestedFiles
                        |> List.filter (\s -> s.rowId /= fileRow.rowId)
            in
                { model | suggestedFiles = newSuggestions }

        ParentMsg.RemoveSuggestion ->
            let
                newSuggestions =
                    model.suggestedFiles
                        |> List.filter (\s -> s.rowId /= fileRow.rowId)

                updatedFiles =
                    model.fileRows
                        |> List.filter (\s -> s.rowId /= fileRow.rowId)
            in
                { model | suggestedFiles = newSuggestions, fileRows = updatedFiles }

        ParentMsg.RemoveFile ->
            let
                updatedFiles =
                    model.fileRows
                        |> List.filter (\s -> s.rowId /= fileRow.rowId)
            in
                { model | fileRows = updatedFiles }

        ParentMsg.Error errorMessage ->
            { model | errorMessage = Just errorMessage }

        ParentMsg.RefreshFiles files suggestions ->
            let
                deletedFiles =
                    model.fileRows
                        |> List.filter isDeleted

                ( fileRows, lastRowId ) =
                    files
                        |> makeFileRows model.lastRowId model.httpInfo model.providers model.localization File.initialAutocomplete model.pathAliases

                sortedFileRows =
                    fileRows
                        ++ deletedFiles
                        |> List.sortWith compareFileRows

                finalModel =
                    case suggestions of
                        Just suggestions ->
                            let
                                suggestedFiles =
                                    suggestions
                                        |> List.map (makeSuggestedFile model)

                                ( suggestedFileRows, finalRowId ) =
                                    suggestedFiles
                                        |> makeFileRows lastRowId model.httpInfo model.providers model.localization File.initialAutocomplete model.pathAliases
                            in
                                { model
                                    | fileRows = sortedFileRows
                                    , lastRowId = finalRowId
                                    , suggestedFiles = suggestedFileRows
                                }

                        Nothing ->
                            { model
                                | fileRows = sortedFileRows
                                , lastRowId = lastRowId
                            }
            in
                finalModel

        ParentMsg.AddTempFile file ->
            let
                newFileRow =
                    { rowId = model.lastRowId, file = file }

                tempLibName =
                    case file.file of
                        File.JavaScriptLibrary filedata libdata ->
                            libdata.libraryName

                        _ ->
                            ""
            in
                { model | fileRows = newFileRow :: model.fileRows, tempFileRow = Nothing, tempLibraryName = tempLibName }

        ParentMsg.CancelTempForm ->
            let
                newLastRow =
                    model.lastRowId - 1
            in
                { model | lastRowId = newLastRow, tempFileRow = Nothing }

        ParentMsg.Editing ->
            case model.editing of
                False ->
                    { model | editing = True }

                True ->
                    { model | editing = False }


makeSuggestedFile : Model -> String -> File.JackrabbitFile
makeSuggestedFile model suggestedFile =
    (File.CssFile
        (File.FileData
            Nothing
            model.defaultPathPrefix
            suggestedFile
            "DnnPageHeaderProvider"
            model.defaultPriority
        )
    )


updateFile : Int -> File.Msg -> FileRow -> ( FileRow, Cmd Msg, ParentMsg )
updateFile targetRowId msg fileRow =
    if targetRowId /= fileRow.rowId then
        ( fileRow, Cmd.none, ParentMsg.NoOp )
    else
        let
            ( updatedRow, cmd, parentMsg ) =
                File.update msg fileRow.file
        in
            ( FileRow fileRow.rowId updatedRow, Cmd.map (FileMsg fileRow.rowId) cmd, parentMsg )


isDeleted : FileRow -> Bool
isDeleted fileRow =
    if (fileRow.file.deleted) then
        True
    else
        False


makeFileRows : Int -> HttpInfo -> Dict String Int -> Dict String String -> File.Autocomplete -> List String -> List File.JackrabbitFile -> ( List FileRow, Int )
makeFileRows lastRowId httpInfo providers localization autocomplete pathList files =
    let
        nextRowId =
            lastRowId + 1
    in
        case files of
            [] ->
                ( [], nextRowId )

            file :: otherFiles ->
                let
                    fileModel =
                        File.fromJackrabbitFile file
                            False
                            httpInfo
                            localization
                            autocomplete
                            pathList
                            (Dict.keys providers)
                            False

                    fileRow =
                        FileRow nextRowId fileModel

                    ( otherFileRows, lastRowId ) =
                        otherFiles
                            |> makeFileRows nextRowId httpInfo providers localization File.initialAutocomplete pathList

                    sortedFileRows =
                        fileRow
                            :: otherFileRows
                            |> List.sortWith compareFileRows
                in
                    ( sortedFileRows, lastRowId )


compareFileRows : FileRow -> FileRow -> Basics.Order
compareFileRows first second =
    File.compareModels first.file second.file
