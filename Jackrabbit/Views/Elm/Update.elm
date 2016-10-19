module Views.Elm.Update exposing (update)

import Dict exposing (Dict)
import Views.Elm.Ajax exposing (HttpInfo)
import Views.Elm.Model exposing (..)
import Views.Elm.Msg exposing (..)
import Views.Elm.File.Model as File exposing (listFileDecoder, typeIdToFileType)
import Views.Elm.File.Msg as File
import Views.Elm.File.ParentMsg as ParentMsg exposing (ParentMsg)
import Views.Elm.File.Update as File
import Views.Elm.Utility exposing (createLocalizationDict, localizeString)
import List.Extra exposing (..)
import Maybe.Extra exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init initialData ->
            let
                httpInfo =
                    HttpInfo initialData.httpInfo.baseUrl initialData.httpInfo.headers (localizeString "HTTP Error" localization)

                localization =
                    createLocalizationDict initialData.localization

                initializedModel =
                    let
                        initialFileToFileData file =
                            case typeIdToFileType file.fileType of
                                Err _ ->
                                    Nothing

                                Ok fileType ->
                                    Just (File.FileData fileType (Just file.id) file.pathPrefixName file.filePath file.provider file.priority)

                        ( fileRows, lastRowId ) =
                            initialData.files
                                |> List.filterMap initialFileToFileData
                                |> makeFileRows model.lastRowId httpInfo model.providers localization
                    in
                        Model fileRows
                            initialData.defaultPathPrefix
                            initialData.defaultFilePath
                            initialData.defaultProvider
                            initialData.defaultPriority
                            model.providers
                            lastRowId
                            Nothing
                            httpInfo
                            localization
                            Nothing
            in
                ( initializedModel, Cmd.none )

        AddNewFile ->
            let
                nextRowId =
                    model.lastRowId + 1

                newFile =
                    File.init File.Default
                        Nothing
                        model.defaultPathPrefix
                        model.defaultFilePath
                        model.defaultProvider
                        model.defaultPriority
                        True
                        model.httpInfo
                        model.localization

                newFileRow =
                    FileRow nextRowId newFile
            in
                ( { model | tempFileRow = Just newFileRow, lastRowId = nextRowId }, Cmd.none )

        FileMsg rowId msg ->
            let
                matchingFileRow =
                    model.files
                        |> List.Extra.find (findRow rowId)

                fileRow =
                    Maybe.oneOf [ matchingFileRow, model.tempFileRow ]

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
                                { model | tempFileRow = Just f }
                            else
                                { model | files = List.Extra.replaceIf (\fr -> fr.rowId == rowId) f model.files }

                modelWithParentMsgs =
                    fileUpdate
                        |> Maybe.map (updateFromChild updatedModel)
                        |> Maybe.withDefault model
            in
                ( modelWithParentMsgs, cmd )


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

        ParentMsg.RemoveFile ->
            let
                updatedFiles =
                    model.files
                        |> List.filter (\s -> s.rowId /= fileRow.rowId)
            in
                { model | files = updatedFiles }

        ParentMsg.SaveError errorMessage ->
            { model | errorMessage = Just errorMessage }

        ParentMsg.RefreshFiles files ->
            let
                ( fileRows, lastRowId ) =
                    files
                        |> makeFileRows model.lastRowId model.httpInfo model.providers model.localization
            in
                { model | files = fileRows, lastRowId = lastRowId }

        ParentMsg.AddTempFile file ->
            let
                newFileRow =
                    { rowId = model.lastRowId, file = file }
            in
                { model | files = newFileRow :: model.files, tempFileRow = Nothing }

        ParentMsg.CancelTempForm ->
            let
                newLastRow =
                    model.lastRowId - 1
            in
                { model | lastRowId = newLastRow, tempFileRow = Nothing }


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


makeFileRows : Int -> HttpInfo -> Dict String Int -> Dict String String -> List File.FileData -> ( List FileRow, Int )
makeFileRows lastRowId httpInfo providers localization files =
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
                        File.init file.fileType
                            file.id
                            file.pathPrefixName
                            file.filePath
                            file.provider
                            file.priority
                            False
                            httpInfo
                            localization

                    fileRow =
                        FileRow nextRowId fileModel

                    ( otherFileRows, lastRowId ) =
                        otherFiles
                            |> makeFileRows nextRowId httpInfo providers localization

                    sortedFileRows =
                        fileRow
                            :: otherFileRows
                            |> List.sortWith (compareFileRows providers)
                in
                    ( sortedFileRows, lastRowId )


compareFileRows : Dict String Int -> FileRow -> FileRow -> Basics.Order
compareFileRows providers first second =
    File.compareModels providers first.file second.file
