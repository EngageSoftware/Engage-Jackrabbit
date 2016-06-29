module Views.Elm.Update exposing (update)

import Dict exposing (Dict)
import Views.Elm.Ajax exposing (HttpInfo)
import Views.Elm.Model exposing (..)
import Views.Elm.Msg exposing (..)
import Views.Elm.File.Model as File exposing (listFileDecoder, typeIdToFileType)
import Views.Elm.File.Msg as File
import Views.Elm.File.ParentMsg as ParentMsg exposing (ParentMsg)
import Views.Elm.File.Update as File
import Views.Elm.Utility exposing (unzip3, createLocalizationDict, localizeString)


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
                initializedModel ! []

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
                { model | files = newFileRow :: model.files, lastRowId = nextRowId } ! []

        FileMsg rowId msg ->
            let
                ( files, cmds, parentMsgs ) =
                    model.files
                        |> List.map (updateFile rowId msg)
                        |> unzip3

                updatedModel =
                    { model | files = files }

                modelWithParentMsgs =
                    parentMsgs
                        |> List.foldl (flip updateFromChild) updatedModel
            in
                modelWithParentMsgs ! cmds


updateFromChild : Model -> ParentMsg -> Model
updateFromChild model parentMsg =
    case parentMsg of
        ParentMsg.NoOp ->
            model

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
updateFile targetRowId msg { rowId, file } =
    let
        ( updatedRow, cmd, parentMsg ) =
            if targetRowId == rowId then
                File.update msg file
            else
                ( file, Cmd.none, ParentMsg.NoOp )
    in
        ( FileRow rowId updatedRow, Cmd.map (FileMsg rowId) cmd, parentMsg )


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
