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
            in
                ( initializedModel, Cmd.none )

        AddNewFile ->
            let
                nextRowId =
                    model.lastRowId + 1

                newFile =
                    File.init File.JavaScript
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
                ( { model | files = newFileRow :: model.files, lastRowId = nextRowId }, Cmd.none )

        FileMsg rowId msg ->
            let
                fileUpdates =
                    model.files
                        |> List.map (updateFile rowId msg)

                cmd =
                    fileUpdates
                        |> List.map (\( file, cmd, parentMsg ) -> cmd)
                        |> Cmd.batch

                files =
                    fileUpdates
                        |> List.map (\( file, cmd, parentMsg ) -> file)

                updatedModel =
                    { model | files = files }

                modelWithParentMsgs =
                    fileUpdates
                        |> List.foldl updateFromChild updatedModel
            in
                ( modelWithParentMsgs, cmd )


updateFromChild : ( FileRow, Cmd msg, ParentMsg ) -> Model -> Model
updateFromChild ( fileRow, _, parentMsg ) model =
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
